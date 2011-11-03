//
//  DesertScene.m
//  bees
//
//  Created by Mihaly Rendes on 10/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DesertScene.h"
#import "DesertBackgroundLayer.h"
#import "beesAppDelegate.h"

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
@synthesize snake = _snake;
@synthesize scarabs = _scarabs;

static double UPDATE_INTERVAL = 1.0f/30.0f;
static double MAX_CYCLES_PER_FRAME = 1;
static double timeAccumulator = 0;
static bool   box2dRunning = NO;
static bool   _evilAppearDone = NO;


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

-(void)generateEnemy{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    for (int i = 0; i < 6; i++){
        Predator* predator = [Predator spriteWithSpriteFrameName:@"skarabeus.png"];
        predator.doRotation = YES; 
        predator.isOutOfScreen = NO;
        float predatorSpeed = 1.2;
        _predatorCurrentSpeed = predatorSpeed;
        
        [predator setSpeedMax:predatorSpeed withRandomRangeOf:0.2f andSteeringForceMax:1 withRandomRangeOf:0.15f];
        [predator setWanderingRadius: 16.0f lookAheadDistance: 40.0f andMaxTurningAngle:0.2f];
        [predator setEdgeBehavior: EDGE_NONE];
        [predator setOpacity:250];
        [_batchNode addChild:predator z:101 tag:1];
        
        float randY = randRange(1, 4);
        [predator setPos:ccp(_player.position.x + screenSize.width, randY * screenSize.height/5)];
        predator.life = 1;
        predator.stamina = 800;
        predator.doRotation = YES;
        predator.scale = 0.5;
        [predator createBox2dBodyDefinitions:_world];
        [_scarabs addObject:predator];
    }
    
    if (self.snake == nil && _timeSinceEnemy2 >= _timeUntilEnemy2){
        _timeSinceEnemy2 = 0;
        self.snake = [[Snake alloc] initForDesertNode:_batchNode];
        self.snake.sprite.position = ccp (_player.position.x + screenSize.width, 60);
        [self.snake createBox2dBodyDefinitions:_world];
    }
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

-(void) updateEnemy:(ccTime)dt{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    if ([_scarabs count] > 0){
        for (Predator* scarab in _scarabs){
            [scarab wander: 0.15f];
            [self separateScarab:scarab withSeparationDistance:40.0f usingMultiplier:0.2f];
            [self alignScarab:scarab withAlignmentDistance:30.0f usingMultiplier:0.4f];
            [self cohesionScarab:scarab withNeighborDistance:40.0f usingMultiplier:0.2f];
            if (scarab.position.x < _player.position.x - screenSize.width/4 || [_scarabs count] < 6){
                scarab.target = ccp(_player.position.x - screenSize.width, _player.position.y);
            }else{
                scarab.target = _slowestBoid.position;
            }
            [scarab update:dt];
            if (scarab.position.x + scarab.contentSize.width/2 * scarab.scale < _player.position.x - screenSize.width/2 && scarab.isOutOfScreen == NO){
                scarab.isOutOfScreen = YES;
            }
        }
    }else{
        _timeUntilScarabs += dt;
        if (_timeUntilScarabs > 2){
            _timeUntilScarabs = 0;
            [self generateEnemy];
        }
    }
    
    if (self.snake == nil){
        if (_timeSinceEnemy2 >= _timeUntilEnemy2){
            _timeSinceEnemy2 = 0;
            //generate enemy2
        }else{
            _timeSinceEnemy2 += dt;
        }
    }else{
        if (self.snake.sprite.position.x + self.snake.sprite.contentSize.width/2 * self.snake.sprite.scale < _player.position.x - screenSize.width/2){
            self.snake.isOnScreen = NO;
        }else if (self.snake.sprite.position.x - self.snake.sprite.contentSize.width/2 * self.snake.sprite.scale < _player.position.x + screenSize.width/2){
            self.snake.isOnScreen = YES;
        }
    }
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
    _timeUntilScarabs = 0;
    
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
	
	_batchNode = [CCSpriteBatchNode batchNodeWithFile:@"beeSpritesDesert_high.pvr.ccz"]; // 1
	[self addChild:_batchNode z:500 tag:500]; // 2
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"beeSpritesDesert_high.plist" textureFile:@"beeSpritesDesert_high.pvr.ccz"];
    
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
    
    self.scarabs = [[NSMutableArray alloc] init];
    [self generateEnemy];
    
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
    [self.harvesterLayer initWithWorld:_world];
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


-(void) updateCurrentDifficulty{
	if (_totalTimeElapsed - 10 * _currentDifficulty >= 10) {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        //time to increase the difficulty
		_currentDifficulty++;
		//increase the playeracceleration if it is not at the maximum
        if (_playerAcceleration.x <= 3.0){
            _playerAcceleration.x += 0.05;
            self.bgLayer.forSpeed = -_playerAcceleration.x;
        }
        
        //increase the boid speed, if it is not at the maximum
        if (_boidCurrentSpeed < 4.0f){
            _boidCurrentSpeed+=0.05;
            for (Boid* bee in _bees){
                [bee setSpeedMax:_boidCurrentSpeed  withRandomRangeOf:0.2f andSteeringForceMax:(_boidCurrentSpeed / 2.5) * 1.8f * 1.5f withRandomRangeOf:0.25f];
                bee.startMaxSpeed = _boidCurrentSpeed;
            }
        }
        
        if (_predatorCurrentSpeed < 3.0){
            _predatorCurrentSpeed += 0.025;
            for (Predator* predator in _scarabs){
                [predator setSpeedMax:_predatorCurrentSpeed andSteeringForceMax:1.0f];     
            }
        }
	}
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



-(void) gameOverRestartTapped:(id)sender{
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    _currentDifficulty  = 1;
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.5 scene:[CampaignScene scene] withColor:ccBLACK]];
}

-(void) gameOverExitTapped:(id)sender{
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    _currentDifficulty = 1;
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.0 scene:[LevelSelectScene scene] withColor:ccBLACK]];
}

-(void) gameOver{
    [self unschedule:@selector(update:)];
    NSLog(@"gameover");
    [self removeChild:_pauseMenu cleanup:YES];
    if (_newHighScore){
        [self saveLevelPerformance];    
    }
    [self.pauseLayer gameOver:_pointsGathered withHighScore:self.level.highScorePoints];
}

-(void) detectGameConditions{
	//first check for gameOver
	if (_pointsGathered > _level.highScorePoints && _newHighScore == NO){
		_newHighScore = YES;
		if (_level.highScorePoints > 0)
			[self displayHighScore];
	}	
	
	if ([_bees count] == 0){
		//Game Over
		_isGameOver = YES;
		[self gameOver];
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
            [self detectGameConditions];
            [self updateLabels];
            [self beeMovement:dt];
            [self updatePoints];
            [self setViewpointCenter:_player.position];
            [self.bgLayer updateBackground:dt];
            [self.bgLayer respawnContinuosBackGround];
            [self.harvesterLayer update:dt];
            [self updateEnemy:dt];
            
            if (self.harvesterLayer.moveInParticle && !_evilAppearDone){
                [self.messageLayer displayWarning:@"It is coming"];
                _evilAppearDone = YES;
                [self.bgLayer fadeInOverlay];
            }else if (self.harvesterLayer.moveOutParticle && _evilAppearDone){
                _evilAppearDone = NO;
                [self.bgLayer fadeOutOverlay];
            }
            
            if (box2dRunning == NO){
                box2dRunning = YES;
                [self updateBox2DWorld:dt];
                box2dRunning = NO;
            }
            [self updateCurrentDifficulty];
            [self detectBox2DCollisions];
            [self detectGameConditions];
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
            }else if ([b->GetUserData() isKindOfClass:[Bullet class]]){
                Bullet *bullet = (Bullet *)b->GetUserData();
                CGPoint location = [self convertToNodeSpace:bullet.sprite.position ];
                if (bullet.isOutOfScreen){
                    b->SetAwake(false);
                    b->SetActive(false);
                }else{
                    b->SetAwake(true);
                    b->SetActive(true);
                }
                b2Vec2 b2Position = b2Vec2(location.x/PTM_RATIO,
                                           location.y/PTM_RATIO);
                float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(bullet.sprite.rotation);
                b->SetTransform(b2Position, b2Angle);
            }else if ([b->GetUserData() isKindOfClass:[Snake class]]){
                Snake *snake = (Snake *)b->GetUserData();
                if (snake.isOnScreen){
                    b->SetAwake(true);
                    b->SetActive(true);
                }else if (self.snake.sprite.position.x + self.snake.sprite.contentSize.width/2 * self.snake.sprite.scale < _player.position.x - screenSize.width/2){
                    NSLog(@"removing snake body");
                    [_batchNode removeChild:self.snake.sprite cleanup:YES];
                    toDestroy.push_back(b);
                    self.snake = nil;
                }else{
                    b->SetAwake(false);
                    b->SetActive(false);
                }
                b2Vec2 b2Position = b2Vec2(snake.sprite.position.x/PTM_RATIO,
                                           snake.sprite.position.y/PTM_RATIO);
                float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(snake.sprite.rotation);
                b->SetTransform(b2Position, b2Angle);
            }else if ([b->GetUserData() isKindOfClass:[NSString class]]){
                CCSprite *sprite = self.harvesterLayer.harvesterSprite;
                CGPoint point = [self convertToNodeSpace:self.harvesterLayer.harvesterSprite.position];
                b2Vec2 b2Position = b2Vec2(point.x/PTM_RATIO,
                                           point.y/PTM_RATIO);
                float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(sprite.rotation);
                b->SetTransform(b2Position, b2Angle);
            }else if ([b->GetUserData() isKindOfClass:[Predator class]]){
                Predator *sprite = (Predator *)b->GetUserData();
                b2Vec2 b2Position = b2Vec2(sprite.position.x/PTM_RATIO,
                                               sprite.position.y/PTM_RATIO);
                float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(sprite.rotation);
                b->SetTransform(b2Position, b2Angle);
                if (sprite.isOutOfScreen){
                    toDestroy.push_back(b);
                    [_batchNode removeChild:sprite cleanup:YES];
                    [self.scarabs removeObject:sprite];
                }
            }else if ([b->GetUserData() isKindOfClass:[Boid class]] && ![b->GetUserData() isKindOfClass:[Predator class]]){
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
       //  toDestroy.clear();
        _world->Step(UPDATE_INTERVAL, 0, 2);
    }
}


-(void)detectBox2DCollisions{
	//	std::vector<b2Body *>toDestroy; 
	std::vector<MyContact>::iterator pos;
	std::vector<b2Body *>toDestroy; 
    ConfigManager* sharedManager = [ConfigManager sharedManager];
	_takenPoints = [[NSMutableArray alloc] init];
    _deadBees = [[NSMutableArray alloc] init];
    NSMutableArray* _deadPredators = [[NSMutableArray alloc] init];
    CCSprite* deadSprite = nil;
	for(pos = _contactListener->_contacts.begin(); 
		pos != _contactListener->_contacts.end(); ++pos) {
		MyContact contact = *pos;
		b2Body *bodyA = contact.fixtureA->GetBody();
		b2Body *bodyB = contact.fixtureB->GetBody();
		if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
            if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && [bodyB->GetUserData() isKindOfClass:[Predator class]] ){
				Boid *boid = (Boid *) bodyA->GetUserData();
				if ([bodyA->GetUserData() isKindOfClass:[Predator class]] == NO){
					Predator *predator = (Predator *) bodyB->GetUserData();
					//if it is dead already dont do anything with it
					if (predator.life > 0 && ![_deadBees containsObject:boid] && ![_deadPredators containsObject:predator]){
						[self playDeadBeeSound];
                        [_deadBees addObject:boid];
                        toDestroy.push_back(bodyA);
                        --predator.life;
						//if it is dead, do not iterate over this
						if (predator.life <= 0){
                            [_deadPredators addObject:predator];
                            toDestroy.push_back(bodyB);
						}
					}
				}
			}else if ([bodyB->GetUserData() isKindOfClass:[Boid class]] && [bodyA->GetUserData() isKindOfClass:[Predator class]] ){
				Boid *boid = (Boid *) bodyB->GetUserData();
				if ([bodyB->GetUserData() isKindOfClass:[Predator class]] == NO){
					Predator *predator = (Predator *) bodyA->GetUserData();
					//if it is dead already dont do anything with it
					if (predator.life > 0 && ![_deadBees containsObject:boid] && ![_deadPredators containsObject:predator]){
						[self playDeadBeeSound];
                        [_deadBees addObject:boid];
                        toDestroy.push_back(bodyA);
						//if it is dead, do not iterate over this
                        --predator.life;
						if (predator.life <= 0){
                            [_deadPredators addObject:predator];
                            toDestroy.push_back(bodyB);
						}
					}
				}
			}
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
            else if ([bodyB->GetUserData() isKindOfClass:[Boid class]] && [bodyA->GetUserData() isKindOfClass:[NSString class]]
                     && ([bodyB->GetUserData() isKindOfClass:[Predator class]] == NO)) {
                Boid *boid = (Boid *) bodyB->GetUserData();
                [self playDeadBeeSound];
                [_deadBees addObject:boid];
                toDestroy.push_back(bodyB);
            }
            else if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && [bodyB->GetUserData() isKindOfClass:[NSString class]]
                     && ([bodyA->GetUserData() isKindOfClass:[Predator class]] == NO)) {
                Boid *boid = (Boid *) bodyA->GetUserData();
                [self playDeadBeeSound];
                [_deadBees addObject:boid];
                toDestroy.push_back(bodyA);
            } //Bullet
			else if ([bodyB->GetUserData() isKindOfClass:[Boid class]] && ([bodyA->GetUserData() isKindOfClass:[Bullet class]] || [bodyA->GetUserData() isKindOfClass:[Snake class]] )
					 && ([bodyB->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Boid *) bodyB->GetUserData();
				[self playDeadBeeSound];
				[_deadBees addObject:boid];
                toDestroy.push_back(bodyB);
			}
			else if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && ([bodyB->GetUserData() isKindOfClass:[Bullet class]] || [bodyB->GetUserData() isKindOfClass:[Snake class]]) 
					 && ([bodyA->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Boid *) bodyA->GetUserData();
				[self playDeadBeeSound];
				[_deadBees addObject:boid];
                toDestroy.push_back(bodyA);
			}
        }
        //bullet
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
        [_takenPoints release];
    }
    
    for (Boid* predator in _deadBees) {
        CCAction* actionScaleIn = [CCScaleTo actionWithDuration:0.3f scale:1.0] ;
        CCAction* actionScaleDone = [CCCallFuncN actionWithTarget:self 
                                                         selector:@selector(actionMoveFinished:)];
        [_bees removeObject:predator];
        if ([_bees count] == 0){
            [self detectGameConditions];
        }
		if ([_slowestBoid isEqual:predator]){
			_slowestBoid = nil;
		}

        CCSprite* deadSprite = [CCSprite spriteWithSpriteFrameName:@"beeDies.png"];
        deadSprite.position = predator.position;
        deadSprite.scale = 0.3;
        [_batchNode addChild:deadSprite z:300 tag:predator.tag];
        [deadSprite runAction:[CCSequence actions:actionScaleIn, actionScaleDone, nil]];	
        [_batchNode removeChild:predator cleanup:YES];
    }

    for (Predator* predator in _deadPredators) {
        CCAction* actionScaleIn = [CCScaleTo actionWithDuration:0.3f scale:1.0] ;
        CCAction* actionScaleDone = [CCCallFuncN actionWithTarget:self 
                                                         selector:@selector(actionMoveFinished:)];
        [_scarabs removeObject:predator];
        CCSprite* deadSprite = [CCSprite spriteWithSpriteFrameName:@"beeDies.png"];
        deadSprite.position = predator.position;
        deadSprite.scale = 0.3;
        [_batchNode addChild:deadSprite z:300 tag:predator.tag];
        [deadSprite runAction:[CCSequence actions:actionScaleIn, actionScaleDone, nil]];	
        [_batchNode removeChild:predator cleanup:YES];
    }
    
    
    std::vector<b2Body *>::iterator pos2;
    for(pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
        b2Body *body = *pos2;     
        _world->DestroyBody(body);
    }
    [_deadBees removeAllObjects];
    [_deadPredators removeAllObjects];
    toDestroy.clear();
     _contactListener->_contacts.clear();
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
        //detect the slowest boid
        if (_slowestBoid == nil){
            _slowestBoid = bee;
        }else if (bee.maxSpeed < _slowestBoid.maxSpeed){
          _slowestBoid = bee;
        }
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


/// scarab boid


-(void) separateScarab:(Predator*)bee withSeparationDistance:(float)separationDistance usingMultiplier:(float)multiplier
{
	CGPoint		force = CGPointZero;
	CGPoint		difference = CGPointZero;
	int			count = 0;
	float		distance;
	float		distanceSQ;
	float		separationDistanceSQ = separationDistance * separationDistance;
	
	for(Predator* otherBee in _scarabs)
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

-(void) alignScarab:(Predator*)bee withAlignmentDistance:(float)neighborDistance usingMultiplier:(float)multiplier
{
	CGPoint		force = CGPointZero;
	int			count = 0;
	float		distanceSQ;
	float		neighborDistanceSQ = neighborDistance * neighborDistance;
	
	for(Boid* otherBee in _scarabs)
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




-(void) cohesionScarab:(Predator*)bee withNeighborDistance:(float)neighborDistance usingMultiplier:(float)multiplier
{
	CGPoint		force = CGPointZero;
	int			count = 0;
	float		distanceSQ;
	float		neighborDistanceSQ = neighborDistance * neighborDistance;
	
	for(Boid* otherBee in _scarabs)
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


///


-(void) actionMoveFinished:(id)sender{
	[_batchNode removeChild:(CCSprite*)sender cleanup:YES];
}


-(void) actionBonusFinished:(id)sender{
	[self removeChild:(CCLabelTTF*)sender cleanup:YES];
}

/*
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
*/

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





-(void) presentGameCenter{
    if ([GameCenterHelper sharedInstance].gameCenterAvailable) { 
        //send the score
        [[GameCenterHelper sharedInstance] reportScore:@"21" score:_pointsGathered];
        
        GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
        if (leaderboardController != NULL) { 
            leaderboardController.category = @"21";
			leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;  
            leaderboardController.leaderboardDelegate = self;
            beesAppDelegate *delegate = [UIApplication sharedApplication].delegate; [delegate.viewController presentModalViewController:leaderboardController animated:YES]; 
        }
        
    }
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController { 
    beesAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.viewController dismissModalViewControllerAnimated: YES]; 
    [viewController release]; 
}


-(void)dealloc{
    self.pauseLayer = nil;
    self.hudLayer = nil;
    self.messageLayer = nil;
    self.harvesterLayer = nil;
    self.bgLayer = nil;
    
    //other objects
    self.level = nil;
    
    _pauseButton = nil;
	_pauseMenu = nil;
    
    self.bees = nil;
    self.deadBees = nil;
    self.points = nil;
    self.takenPoints = nil;
    _slowestBoid = nil;
    _player = nil;
    _world = nil;
    _contactListener = nil;
    _batchNode = nil;
    [_alchemy release];
    _alchemy = nil;
    [super dealloc];
}


@end
