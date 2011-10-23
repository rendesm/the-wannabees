//
//  DesertScene.m
//  bees
//
//  Created by Mihaly Rendes on 10/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DesertScene.h"
#import "DesertBackgroundLayer.h"

#define rad2Deg 57.2957795

#define leftEdge 10.0f
#define bottomEdge 0.0f
#define topEdge 310.0f
#define rightEdge 465.0f

#define IGNORE 1.0f

#define kFilteringFactor 0.05

@implementation DesertScene
@synthesize bees = _bees, deadBees = _deadBees, points = _points, takenPoints = _takenPoints;
@synthesize messageLayer = _messageLayer, harvesterLayer = _harvesterLayer, pauseLayer = _pauseLayer, hudLayer = _hudLayer, bgLayer = _bgLayer;
@synthesize level = _level;
@synthesize currentTouch = _currentTouch;

static double UPDATE_INTERVAL = 1.0f/30.0f;
static double MAX_CYCLES_PER_FRAME = 2;
static double timeAccumulator = 0;

+(id)scene{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	HUDLayer *hud = [HUDLayer node];
    [scene addChild:hud z:3];
    
    PauseLayer* pauseLayer = [PauseLayer node];
    [scene addChild:pauseLayer z:5];
	
    MessageLayer* messageLayer = [MessageLayer node];
    [scene addChild:messageLayer z:4];
    
    HillsBackgroundLayer* bgLayer = [DesertBackgroundLayer node];
    [scene addChild:bgLayer z: 0];

    
    HarvesterLayer* harvesterLayer = [HarvesterLayer node];
    [scene addChild:harvesterLayer z:2];
	
	// 'layer' is an autorelease object.
	DesertScene *layer =  [[[DesertScene alloc] initWithLayers:hud pause:pauseLayer message:messageLayer harvester:harvesterLayer background:bgLayer] autorelease];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}



-(void)setViewpointCenter:(CGPoint) position{
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
    int x = MAX(position.x, winSize.width / 2);
    //int y = MAX(position.y, winSize.height / 2);
	int y = winSize.height/2;
    CGPoint actualPosition = ccp(x, y);
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    self.position = viewPoint;	
}	


-(void) movePointToNewPosition:(Points*) point{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	float rnd = randRange(1, 4);
	if (_lastPointLocation.x  < _player.position.x + screenSize.width/2){
		_lastPointLocation = ccp(_player.position.x + screenSize.width/2, 0);
	}
	point.sprite.position  = ccp(_lastPointLocation.x + screenSize.width/4 + screenSize.width/4 * rnd/10, 
								 rnd * screenSize.height/5 );	
	_lastPointLocation = point.sprite.position;
}


-(void) generateNextPoint:(int)types{
	Points* point = nil;	
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
	if (types == YELLOW_SLOT){
		//but right now just add a point to a random location
		point =	[[Points alloc] initWithFileName:@"yellowFlower.png" withValue:1];
		[point createBox2dBodyDefinitions:_world];
		point.type = GOLD;
		[self.points addObject:point];
		[_batchNode addChild:point.sprite z:50 tag:5];
	}else if (types == RED_SLOT){
		//but right now just add a point to a random location
		point =	[[Points alloc] initWithFileName:@"redFlower.png" withValue:1];
		[point createBox2dBodyDefinitions:_world];
		point.type = ATTACK_BOOST;
		[self.points addObject:point];
		[_batchNode addChild:point.sprite z:50 tag:5];
	}else if (types == BLUE_SLOT){
		//but right now just add a point to a random location
		point =	[[Points alloc] initWithFileName:@"blueFlower.png" withValue:1];
		[point createBox2dBodyDefinitions:_world];
        point.type = EVADE_BOOST;
		[self.points addObject:point];
		[_batchNode addChild:point.sprite z:50 tag:5];
	}
	
	[self movePointToNewPosition:point];
}


-(void) displayNoBonus{
    int rnd = floor(randRange(1, 8));
    NSString* message;
    switch (rnd) {
        case 1:
            message = @"Oh no...";
            break;
        case 2:
            message = @"Focus!!!";
            break;
        case 3:
            message = @"Nevermind...";
            break;
        case 4:
            message = @"Try again!";
            break;
        case 5:
            message = @"Not this time";
            break;
        case 6:
            message = @"You can do this";
            break;
        case 7:
            message = @"Yarrrggh";
        default:
            break;
    }    [self.messageLayer displayMessage:message];				   
}

-(void) displayHighScore{
    [self.messageLayer displayMessage:@"High Score"];
}


-(void) displayBonus{
	NSString* tmpStr = [[[NSString alloc] initWithFormat:@"%ix Bonus", _bonusCount] autorelease];
    [self.messageLayer displayMessage:tmpStr];
}



#pragma mark sounds
-(void) playDeadBeeSound{
	if ([[ConfigManager sharedManager] sounds]){
		if (_auEffectLeft == 0){
			[[SimpleAudioEngine sharedEngine] playEffect:@"au.wav"];
			_auEffectLeft = 0.4;
		}
	}
}

-(void) playComboSuccessSound{
	if ([[ConfigManager sharedManager] sounds]){
		[[SimpleAudioEngine sharedEngine] playEffect:@"woohooo.wav"];
	}
}


-(void) switchPause:(id)sender{
	if (_paused == NO){
		[self unschedule:@selector(update:)];
        [self.pauseLayer switchPause];
		_paused = YES;
	}else{
		_paused = NO;
        [self.pauseLayer switchPause];
		[self schedule: @selector(update:)];
	}
}


-(void) initLabels{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];	
	[self.hudLayer initLabels];
    _pauseButton = [CCMenuItemImage		itemFromNormalImage:@"pauseButton.png" selectedImage:@"pauseButton.png" 
												  target:self selector:@selector(switchPause:)];
	
	
	_pauseMenu = [CCMenu menuWithItems:_pauseButton, nil];
	_pauseMenu.position = ccp(screenSize.width - _pauseButton.contentSize.width * 2, _pauseButton.contentSize.height + 32);
	[self addChild:_pauseMenu z:100 tag:100];	
}

-(id) initWithLayers:(HUDLayer *)hudLayer pause:(PauseLayer *)pauseLayer message:(MessageLayer *)messageLayer harvester:(HarvesterLayer*)harvesterLayer background:(HillsBackgroundLayer *)background{
	if ((self = [super init])){
		self.hudLayer = hudLayer;
        self.pauseLayer = pauseLayer;
        self.messageLayer = messageLayer;
        self.harvesterLayer = harvesterLayer;
        self.bgLayer = background;
        pauseLayer.gameScene = self;
		self.level = (Level*)[[LevelManager sharedManager] selectedLevel];
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		_gameIsReady = NO;
		_gameStarted = NO;
		_paused = NO;
        
        //pausemenu
        [self schedule: @selector(loadingTextures) interval: 0.25];
	}
	return self;
}



-(void) loadingTextures{
    //fist stop the music and load some ambience
    [self unschedule:@selector(loadingTextures)];
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
    
	_bonusCount = 1;
    _currentDifficulty = 1;
    
    _bees = [[[NSMutableArray alloc] init] retain];
	_deadBees = [[[NSMutableArray alloc] init] retain];
    self.points = [[NSMutableArray alloc] init];
    
    _currentTouch = CGPointZero;
	
	_player = [[CCSprite alloc] init];
	_player.position = ccp(screenSize.width/2 , screenSize.height/2);
	_player.opacity = 0;
	
	_currentTouch = _player.position;
    
    
    

	[[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:NO];
	self.isTouchEnabled = YES;
	
	_batchNode = [CCSpriteBatchNode batchNodeWithFile:@"beeSprites2_high.pvr.ccz"]; // 1
	[self addChild:_batchNode z:500 tag:500]; // 2
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"beeSprites2_high.plist" textureFile:@"beeSprites2_high.pvr.ccz"];
    
	//init the box2d world
	b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
	bool doSleep = true;
	_world = new b2World(gravity, doSleep);
    
	_contactListener = new MyContactListener();
	//set the contactListener for the world
	_world->SetContactListener(_contactListener);


    Boid* boid;
	float count = 15;
	for (int i = 0; i < count; i++) 
	{
		boid = [Boid spriteWithSpriteFrameName:@"bee4.png"];
		[_bees addObject:boid];
		
		boid.doRotation = YES;
		boid.damage = 1;
		
		// Initialize behavior properties for this boid
		// You want the flock to behavior basically the same, but have a TINY variation among members
		boid.startMaxForce = 0;
		boid.startMaxSpeed = 0;
        [boid setSpeedMax:2.5f  withRandomRangeOf:0.2f andSteeringForceMax:1.8f * 1.5f  withRandomRangeOf:0.25f];
        _boidCurrentSpeed = 2.5f;
        _boidCurrentTurn = 1.8f;
        
		
		[boid setWanderingRadius: 20.0f lookAheadDistance: 40.0f andMaxTurningAngle:0.3f];
		[boid setEdgeBehavior: EDGE_WRAP];
		
		if (_slowestBoid == nil){
			_slowestBoid = boid;
		}else {
			if (boid.maxSpeed < _slowestBoid.maxSpeed){
				_slowestBoid = boid;
			}
		}
		[boid setScale: randRange(0.3,0.5)];
		[boid setPos: ccp( randRange(0.5, 1.0) * screenSize.width/3,  screenSize.height / 2)];
		// Color
		[boid setOpacity:220];
		[boid createBox2dBodyDefinitions:_world];
		[_batchNode addChild:boid z:100 tag:1];
		[boid update];
	}
    
    for (int i = 0; i < 6; i++) {
		[self generateNextPoint: (i % 3)+1];
	}
    
    
	_playerAcceleration = ccp(1.5,0);
	_pointsGathered = 0;
    
    [self initLabels];

    [self schedule:@selector(loadingTerrain)];
}

-(void) loadingTerrain{
    [self unschedule:@selector(loadingTerrain)];
    [self.bgLayer genBackground];
    [self.bgLayer createBackground];
    for (Fish* fish in self.bgLayer.fish){
        [fish createBox2dBodyDefinitions:_world];
    }
    self.bgLayer.forSpeed = -_playerAcceleration.x;
    [self schedule:@selector(loadingSounds)];
}

-(void) loadingSounds{
    [self unschedule:@selector(loadingSounds)];
    
    [self schedule:@selector(loadingDone)];
}

-(void) loadingDone{
    [self unschedule:@selector(loadingDone)];
    [self.pauseLayer loadingFinished];
    _gameIsReady = YES;
    _alchemy = [[[Alchemy alloc]init] retain];
    _alchemy.world = self;
}



-(void) updateLabels{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
	_pauseButton.position = ccp(_pauseButton.position.x + _playerAcceleration.x, _pauseButton.position.y);	
    [self.hudLayer updatePoints:_pointsGathered];
}



-(void) updatePoints{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    int rnd = floor(CCRANDOM_0_1() * 3 + 1);
    if (rnd == 4){
        rnd = 3;
    }
    
    if ([self.points count] < 6){
        [self generateNextPoint:rnd];
    }
    
	for (Points* point in _points){
		if ((point.sprite.position.x - point.sprite.contentSize.width/2 * point.sprite.scale > _player.position.x + screenSize.width/2) && 
            point.sprite.position.x < _lastPointLocation.x){
		}else if(point.sprite.position.x + point.sprite.contentSize.width/2 * point.sprite.scale < _player.position.x - screenSize.width/2){
            point.taken = YES;
        }
        
        if (_currentDifficulty > 10 && point.sprite.position.x < _player.position.x + screenSize.width/2 && point.moving == NO){
            [point update];
        }
	}
}



-(void)update:(ccTime)dt{
	float tickTime = 1.0f/60.0f;
	_totalTimeElapsed += tickTime;
	if (_totalTimeElapsed > 0.7){
		if (_gameStarted){
            if (_touchEnded){
                _currentTouch = ccp(_currentTouch.x + _playerAcceleration.x, _currentTouch.y);
            }
            
            _player.position = ccpAdd(_player.position, _playerAcceleration);
            [self updateLabels];
            [self beeMovement:dt];
            [self updatePoints];
            [self setViewpointCenter:_player.position];
            [self.bgLayer updateBackground:dt];
            [self.bgLayer respawnContinuosBackGround];

            [self updateBox2DWorld:dt];
            [self detectBox2DCollisions];
        }
    }
}


-(void) updateBox2DWorld:(ccTime)dt{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    std::vector<b2Body *>toDestroy; 
    
    timeAccumulator+=dt;
    if (timeAccumulator > (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL)){
        timeAccumulator = UPDATE_INTERVAL;
    }
    
    while (timeAccumulator >= UPDATE_INTERVAL){
        timeAccumulator -= UPDATE_INTERVAL;
    	int i = 0;
        for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
            if ([b->GetUserData() isKindOfClass:[Points class]]){
                Points *point = (Points *)b->GetUserData();
                if (point.taken == NO){
                    b2Vec2 b2Position = b2Vec2(point.sprite.position.x/PTM_RATIO,
                                               point.sprite.position.y/PTM_RATIO);
                    float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(point.sprite.rotation);
                    b->SetTransform(b2Position, b2Angle);
                }else{
                    //remove the point
                    [_batchNode removeChild:point.sprite cleanup:YES];
                    [self.points removeObject:point];
                    [point release];
                    toDestroy.push_back(b);
                }
            }if ([b->GetUserData() isKindOfClass:[Fish class]]){
                Points *point = (Points *)b->GetUserData();
                b2Vec2 b2Position = b2Vec2(point.sprite.position.x/PTM_RATIO,
                                           point.sprite.position.y/PTM_RATIO);
                float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(point.sprite.rotation);
                b->SetTransform(b2Position, b2Angle);
            }else if ([b->GetUserData() isKindOfClass:[CCSprite class]]){
                CCSprite *sprite = (CCSprite *)b->GetUserData();
                b2Vec2 b2Position = b2Vec2(sprite.position.x/PTM_RATIO,
                                           sprite.position.y/PTM_RATIO);
                float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(sprite.rotation);
                b->SetTransform(b2Position, b2Angle);
                i++;
            }
        }	
        
        std::vector<b2Body *>::iterator pos2;
        for(pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
            b2Body *body = *pos2;     
            _world->DestroyBody(body);
        }
        
        _world->Step(UPDATE_INTERVAL, 3, 2);
    }
}


-(void)detectBox2DCollisions{
	//	std::vector<b2Body *>toDestroy; 
	std::vector<MyContact>::iterator pos;
	std::vector<b2Body *>toDestroy; 
    ConfigManager* sharedManager = [ConfigManager sharedManager];
	_takenPoints = [[NSMutableArray alloc] init];
	for(pos = _contactListener->_contacts.begin(); 
		pos != _contactListener->_contacts.end(); ++pos) {
		MyContact contact = *pos;
		b2Body *bodyA = contact.fixtureA->GetBody();
		b2Body *bodyB = contact.fixtureB->GetBody();
		if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
			if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && [bodyB->GetUserData() isKindOfClass:[Points class]]){
				Points* point = (Points*) bodyB->GetUserData();
                if (point.taken == NO){
                    point.taken = YES;
                    _pointsGathered += point.value * _bonusCount;
					[_takenPoints addObject:point];
                    toDestroy.push_back(bodyB);	
                }
			}else if ([bodyB->GetUserData() isKindOfClass:[Boid class]] && [bodyA->GetUserData() isKindOfClass:[Points class]]){
				Points* point = (Points*) bodyA->GetUserData();
                if (point.taken == NO){
                    point.taken = YES;
                    _pointsGathered += point.value * _bonusCount;
					[_takenPoints addObject:point];
                    toDestroy.push_back(bodyA);
                }
			}
        }
    }
    
    if ([_takenPoints count] > 0){        
        for (Points* point in _takenPoints){
            [self.points removeObject:point];
            PointTaken* actionMoveUp = [PointTaken actionWithDuration:0.4 moveTo:ccp(point.sprite.position.x - _playerAcceleration.x * 5,
                                                                                     point.sprite.position.y + point.sprite.contentSize.height * point.sprite.scale)];
            CCAction* actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(actionMoveFinished:)];
            CCSprite* deadSprite = nil;
            bool goodForCombo = [self addItemValue:point.type];
            if (!goodForCombo){
                if (!self.harvesterLayer.isIn && !self.harvesterLayer.moveOutParticle && !self.harvesterLayer.moveInParticle){
                    self.harvesterLayer.timeElapsed += 10;
                }
                [_alchemy clearItems];
                [self clearItems];
                [self clearGoals];
                _bonusCount = 1;
                [self displayNoBonus];				
                [self generateGoals];
            }
            if (point.type == ATTACK_BOOST){
                if (goodForCombo) {
                    [self.hudLayer addItem:@"redFlower.png"];
                    [_alchemy addItem:RED_SLOT];
                }
                deadSprite = [CCSprite spriteWithSpriteFrameName:@"redFlower.png"];
            }else if (point.type == GOLD){
                if (goodForCombo) {
                    [self.hudLayer addItem:@"yellowFlower.png"];
                    [_alchemy addItem:YELLOW_SLOT];
                }
                deadSprite = [CCSprite spriteWithSpriteFrameName:@"yellowFlower.png"];
            }else if (point.type == EVADE_BOOST){
                if (goodForCombo){
                    [self.hudLayer addItem:@"blueFlower.png"];
                    [_alchemy addItem:BLUE_SLOT];
                }
                deadSprite = [CCSprite spriteWithSpriteFrameName:@"blueFlower.png"];			
            }
            [_batchNode addChild:deadSprite z:300 tag:300];
            deadSprite.position = point.sprite.position;
            deadSprite.scale = 0.1;
            [deadSprite runAction:[CCSequence actions:actionMoveUp, actionMoveDone, nil]];
            if (point.moving){
                [point.sprite stopAllActions];
                point.moving = NO;
                point.moveDone = NO;
            }
            [_batchNode removeChild:point.sprite cleanup:YES];
            [point release];
        }
        [_takenPoints removeAllObjects];
        [_takenPoints release];
    }

    std::vector<b2Body *>::iterator pos2;
    for(pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
        b2Body *body = *pos2;     
        _world->DestroyBody(body);
    }
}




-(void) beeDefaultMovement:(Boid*) bee withDt:(ccTime)dt{
	[bee wander: 0.05f];
	[self separate:bee withSeparationDistance:40.0f usingMultiplier:0.2f];
	[self align:bee withAlignmentDistance:30.0f usingMultiplier:0.4f];
	[self cohesion:bee withNeighborDistance:40.0f usingMultiplier:0.2f];	
}

-(void) beeMovement:(ccTime)dt{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	bool tmpSick = NO;
	for (Boid* bee in _bees){
		bee.leftEdgePosition = ccp(_player.position.x - screenSize.width/2 + 10, _player.position.y);
		[self beeDefaultMovement:bee withDt:dt];
		if (!CGPointEqualToPoint(_currentTouch , CGPointZero)){
			[bee seek:_currentTouch usingMultiplier:0.15f];
		}else{
			[bee seek:_player.position usingMultiplier:0.15f];
		}
		[bee update:dt];
		if (bee.hasDisease){
			tmpSick = YES;
		}
	}

}


- (void)onEnter
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (void)onExit
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
	
}



- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (_gameIsReady && _gameStarted == NO){
		CGSize screenSize = [CCDirector sharedDirector].winSize;
        [self.pauseLayer startGame];
        _gameStarted = YES;
        if ([[ConfigManager sharedManager] music]){
          //  [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"cave.mp3" loop:YES];
        }
		[self schedule: @selector(update:)];
		[self generateGoals];
        return NO;
	}else if (_gameIsReady && _gameStarted){
		self.currentTouch = [self convertTouchToNodeSpace: touch];
		self.currentTouch = ccp(self.currentTouch.x - 10, self.currentTouch.y);
		if (_isGameOver){
            return NO;
            /*
             if (_newHighScore && _distanceToGoal < 0){
             [self saveLevelPerformance];
             }
             [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
             [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.0 scene:[LevelSelectScene scene] withColor:ccBLACK]];
             */
		}
	}
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	self.currentTouch = [self convertTouchToNodeSpace: touch];
	self.currentTouch = ccp(self.currentTouch.x - 10, self.currentTouch.y);
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	_touchEnded = YES;
	//self.currentTouch = CGPointZero;
}


inline CGPoint normalize(CGPoint point)
{
	float length = sqrtf(point.x*point.x + point.y*point.y);
	if (length < FLT_EPSILON) length = 0.001f; // prevent divide by zero
	
	float invLength = 1.0f / length;
	point.x *= invLength;
	point.y *= invLength;
	
	return point;
}
//#define distanceSquared(__X__, __Y__) ccpLengthSQ( ccpSub(__X__, __Y__) )

inline float getDistanceSquared( CGPoint pointA, CGPoint pointB )
{
	float deltaX = pointB.x - pointA.x;
	float deltaY = pointB.y - pointA.y;
	return (deltaX * deltaX) + (deltaY * deltaX);
}

inline float getDistance( CGPoint pointA, CGPoint pointB )
{
	return sqrtf( getDistanceSquared(pointA, pointB) );
}

inline float randRange(float min,float max)
{
	return CCRANDOM_0_1() * (max-min) + min;
}




-(void) saveLevelPerformance{
	NSLog(@"saving level performance");
	LevelManager* sharedManager = [LevelManager sharedManager];
	if (_newHighScore){
		sharedManager.selectedLevel.highScorePoints = _pointsGathered;
	}
	sharedManager.selectedLevel.completed = YES;
	
	[sharedManager saveSelectedLevel];
	
}


-(void) separate:(Boid*)bee withSeparationDistance:(float)separationDistance usingMultiplier:(float)multiplier
{
	CGPoint		force = CGPointZero;
	CGPoint		difference = CGPointZero;
	int			count = 0;
	float		distance;
	float		distanceSQ;
	float		separationDistanceSQ = separationDistance * separationDistance;
	
	for(Boid* otherBee in _bees)
	{
		if (otherBee != bee){
			distanceSQ = getDistanceSquared(bee->_internalPosition, otherBee->_internalPosition);
			
			if(distanceSQ > 0.1f && distanceSQ < separationDistanceSQ)
			{
				distance = sqrtf(distanceSQ);
				
				difference = ccpSub(bee->_internalPosition, otherBee->_internalPosition);
				difference = normalize(difference);
				difference = ccpMult(difference, 1.0f / distance );
				
				force = ccpAdd(force, difference);
				count++;
			}
		}
	}
	
	// Average
	if(count > 0)
		force = ccpMult(force, 1.0f / (float) count);
	
	// apply 
	if(multiplier != IGNORE)
		force = ccpMult(force, multiplier);
	
	bee.acceleration = ccpAdd(bee.acceleration, force);
}

-(void) align:(Boid*)bee withAlignmentDistance:(float)neighborDistance usingMultiplier:(float)multiplier
{
	CGPoint		force = CGPointZero;
	int			count = 0;
	float		distanceSQ;
	float		neighborDistanceSQ = neighborDistance * neighborDistance;
	
	for(Boid* otherBee in _bees)
	{
		if (otherBee != bee){
			distanceSQ = getDistance(bee->_internalPosition, otherBee->_internalPosition);
			if(distanceSQ > 0.1f && distanceSQ < neighborDistanceSQ)
			{			
				force = ccpAdd(force, otherBee->_velocity);
				count++;
			}	
		}
	}
	
	if(count > 0)
	{
		force = ccpMult(force, 1.0f / (float)count );
		float forceLengthSquared = ccpLengthSQ(force);
		
		if(forceLengthSquared > bee->_maxForceSQ)
		{
			force = normalize(force);
			force = ccpMult(force, bee->_maxForce);
		}
	}
	
	if(multiplier != IGNORE)
		force = ccpMult(force, multiplier);
	
	bee.acceleration = ccpAdd(bee.acceleration, force);
}




-(void) cohesion:(Boid*)bee withNeighborDistance:(float)neighborDistance usingMultiplier:(float)multiplier
{
	CGPoint		force = CGPointZero;
	int			count = 0;
	float		distanceSQ;
	float		neighborDistanceSQ = neighborDistance * neighborDistance;
	
	for(Boid* otherBee in _bees)
	{	
		if (otherBee != bee){
			distanceSQ = getDistanceSquared(bee->_internalPosition, otherBee->_internalPosition);
			if(distanceSQ > 0.1f && distanceSQ < neighborDistanceSQ)
			{			
				force = ccpAdd(force, otherBee->_internalPosition);
				count++;
			}	
		}
	}
	
	if(count > 0)
	{
		force = ccpMult(force, (1.0f / (float) count));
		force = [bee steer:force easeAsApproaching:NO withEaseDistance:IGNORE];
	}
	
	if(multiplier != IGNORE)
		force = ccpMult(force, multiplier);
	
	bee.acceleration = ccpAdd(bee.acceleration, force);
}


-(void) actionMoveFinished:(id)sender{
	[_batchNode removeChild:(CCSprite*)sender cleanup:YES];
}


-(void) actionBonusFinished:(id)sender{
	[self removeChild:(CCLabelTTF*)sender cleanup:YES];
}


-(void) removeDeadItems{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	
	//remove the dead objects
	for (Boid* boid in _deadBees){
		CCAction* actionScaleIn = [CCScaleTo actionWithDuration:0.3f scale:1.0] ;
		CCAction* actionScaleDone = [CCCallFuncN actionWithTarget:self 
														 selector:@selector(actionMoveFinished:)];
		//add the deadAnimation
		CCSprite* deadSprite = [CCSprite spriteWithSpriteFrameName:@"beeDies.png"];
		deadSprite.position = boid.position;
		deadSprite.scale = 0.3;
		[_batchNode addChild:deadSprite z:300 tag:boid.tag-1];
		[deadSprite runAction:[CCSequence actions:actionScaleIn, actionScaleDone, nil]];	
		[_bees removeObject:boid];
		//check if it was the slowest
		if ([_slowestBoid isEqual:boid]){
			_slowestBoid = nil;
		}
	}
	[_deadBees removeAllObjects];
}


#pragma mark goals 

-(bool)addItemValue:(int)value{
	if (_item1Value == 0){
		if (value == _goal1){
			_item1Value = value;
			return YES;
		}
	}else if(_item2Value == 0){
		if (value == _goal2){
			_item2Value = value;
			return YES;
		}
	}else if (_item3Value == 0) {
		if (value == _goal3){
			_item3Value = value;
			return YES;
		}
	}
	return NO;
}


-(void) clearItemValues{
	if (_item1Value != 0){
		_item1Value = 0;
	}
	if (_item2Value != 0){
		_item2Value = 0;
	}
	if (_item3Value != 0){
		_item3Value = 0;
	}
}

-(void) clearItems{
	[self.hudLayer clearItems];
	[self clearItemValues];
}



-(void) clearGoals{
	[self.hudLayer clearGoals];
	_goal1 = 0;
	_goal2 = 0;
	_goal3 = 0;
}


-(bool) checkGoals{
	if (_item1Value == _goal1 && _item2Value == _goal2 && _item3Value == _goal3) {
		return YES;
	}else {
		return NO;
	}
}


-(void) calculateAndApplyBonus{
	//*16 is the maximum bonus
	switch (_level.difficulty) {
		case EASY:
			if (_bonusCount <=2){
				_bonusCount *=2;
			}
			break;
		case NORMAL:
			if (_bonusCount <=4){
				_bonusCount *=2;
			}
			break;
		case HARD:
			if (_bonusCount <=8){
				_bonusCount *=2;
			}
			break;
		default:
			break;
	}
	//show a label for the current bonus
	[self displayBonus];
}


-(void) generateGoals{
	float maxNumber = 3;
	float minTime = 0;
	float maxTime = 0;
	
	if (_level.difficulty == EASY){
		minTime = 25;
		maxTime = 30;
	}else if (_level.difficulty == NORMAL){
		minTime = 15;
		maxTime = 20;
	}else if (_level.difficulty == HARD){
		minTime = 10;
		maxTime = 15;
	}
	
	_goal1 = ceil(randRange(0, maxNumber));
	_goal2 = ceil(randRange(0, maxNumber));
	_goal3 = ceil(randRange(0, maxNumber));
	
    NSMutableArray* goalsForHud = [[[NSMutableArray alloc] init] autorelease];
	[goalsForHud addObject:[NSNumber numberWithInt:_goal1]];
	[goalsForHud addObject:[NSNumber numberWithInt:_goal2]];
	[goalsForHud addObject:[NSNumber numberWithInt:_goal3]];
	self.hudLayer.goals = goalsForHud;
	[self.hudLayer createGoalSpritesForGoals];
}


-(void) applyEffect:(int)effect{
	//check for completion
	if ([self checkGoals]){
		[self playComboSuccessSound];
		[self calculateAndApplyBonus];
		[self clearGoals];
		[self generateGoals];
        if (self.harvesterLayer.isIn){
            [self.harvesterLayer sendItBack];
        }
	}
	//clear the items
	[_alchemy clearItems];
	[self clearItems];
	[self clearItemValues];
}




@end
