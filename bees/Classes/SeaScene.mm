//
//  HelloWorldScene.mm
//  bees
//
//  Created by macbook white on 7/18/11.
//  Copyright nincs 2011. All rights reserved.
//


// Import the interfaces
#import "SeaScene.h"
#import "LevelManager.h"
#import "beesAppDelegate.h"
#define rad2Deg 57.2957795

#define leftEdge 10.0f
#define bottomEdge 0.0f
#define topEdge 310.0f
#define rightEdge 465.0f

#define IGNORE 1.0f

#define kFilteringFactor 0.05


@implementation SeaScene
@synthesize  currentTouch = _currentTouch;
@synthesize attackEnabled = _attackEnabled;
@synthesize evadeEnabled = _evadeEnabled;
@synthesize paused = _paused;
@synthesize attackBoostIntensity = _attackBoostIntensity;
@synthesize evadeBoostIntensity = _evadeBoostIntensity;
@synthesize level = _level;
@synthesize comboFinisher = _comboFinisher;
@synthesize comboFinishers = _comboFinishers;
@synthesize pauseLayer = _pauseLayer;
@synthesize hudLayer = _hudLayer;
@synthesize messageLayer = _messageLayer;
@synthesize updateBox = _updateBox;
@synthesize harvesterLayer = _harvesterLayer;
@synthesize island = _island;

static double UPDATE_INTERVAL = 1/30.0f;
static double MAX_CYCLES_PER_FRAME = 1;
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
    
    HarvesterLayer* harvesterLayer = [HarvesterLayer node];
    [scene addChild:harvesterLayer z:2];
	
	// 'layer' is an autorelease object.
	SeaScene *layer =  [[[SeaScene alloc] initWithLayers:hud pause:pauseLayer message:messageLayer harvester:harvesterLayer] autorelease];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (ccColor4F)randomBrightColor {
    while (true) {
        float requiredBrightness = 192;
        ccColor4B randomColor = 
		ccc4(arc4random() % 255,
			 arc4random() % 255, 
			 arc4random() % 255, 
			 255);
        if (randomColor.r > requiredBrightness || 
            randomColor.g > requiredBrightness ||
            randomColor.b > requiredBrightness) {
            return ccc4FFromccc4B(randomColor);
        }        
    }
}

- (ccColor4F)randomBlueColor {
    while (true) {
        float requiredBrightness = 230;
		float maxBrightness = 200;
        ccColor4B randomColor = 
		ccc4(arc4random() % 255,
			 arc4random() % 255,
			 255, 
			 255);
        if (randomColor.g > requiredBrightness - 50 &&
			randomColor.r < maxBrightness) {
            return ccc4FFromccc4B(randomColor);
        }        
    }
}

- (ccColor4F)randomGreenColor {
    while (true) {
        float requiredBrightness = 250;
		float maxBrightness = 40;
        ccColor4B randomColor = 
		ccc4(arc4random() % 255,
			 arc4random() % 255,
			 arc4random() % 255, 
			 255);
        if (randomColor.r > maxBrightness && 
            randomColor.b > maxBrightness &&
            randomColor.g > requiredBrightness) {
            return ccc4FFromccc4B(randomColor);
        }        
    }
}



-(CCSprite *)spriteWithColor:(ccColor4F)bgColor textureSize:(float)textureSize withNoise:(NSString*)inNoise withGradientAlpha:(float)gradientAlpha{
    // 1: Create new CCRenderTexture
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureSize height:textureSize];
	
    // 2: Call CCRenderTexture:begin
    [rt beginWithClear:bgColor.r g:bgColor.g b:bgColor.b a:bgColor.a];
	
    // 3: Draw into the texture
    // We'll add this later
	CCSprite *noise = [CCSprite spriteWithFile:inNoise];
	//	[noise setBlendFunc:(ccBlendFunc){GL_DST_COLOR, GL_ZERO}];
	noise.position = ccp(textureSize/2, textureSize/2);
	[noise visit];
	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	CGPoint vertices[4];
	ccColor4F colors[4];
	int nVertices = 0;
	
	vertices[nVertices] = CGPointMake(0, 0);
	colors[nVertices++] = (ccColor4F){0, 0, 0, 0 };
	vertices[nVertices] = CGPointMake(textureSize, 0);
	colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
	vertices[nVertices] = CGPointMake(0, textureSize);
	colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
	vertices[nVertices] = CGPointMake(textureSize, textureSize);
	colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glColorPointer(4, GL_FLOAT, 0, colors);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nVertices);
	
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	
	// 4: Call CCRenderTexture:end
	[rt end];
	
	
	// 5: Create a new Sprite from the texture
    return [CCSprite spriteWithTexture:rt.sprite.texture];
}

-(void) optionsButtonTapped:(id)sender{
	
}

-(void) storeButtonTapped:(id)sender{
	
}

-(void) quitButtonTapped:(id)sender{
	
}

-(void) createPauseMenu{
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	CCMenuItemImage *button1 = [CCMenuItemImage 
								itemFromNormalImage:@"resume.png" selectedImage:@"resumeTapped.png" 
								target:self selector:@selector(switchPause:)];
	
	CCMenuItemImage *button2 = [CCMenuItemImage 
								itemFromNormalImage:@"optionsResume.png" selectedImage:@"optionsResumeTapped.png" 
								target:self selector:@selector(optionsButtonTapped:)];
	CCMenuItemImage *button3 = [CCMenuItemImage 
								itemFromNormalImage:@"restart.png" selectedImage:@"restartTapped.png" 
								target:self selector:@selector(storeButtonTapped:)];
	
	CCMenuItemImage *button4 = [CCMenuItemImage
								itemFromNormalImage:@"quit.png" selectedImage:@"quitTapped.png"
								target:self selector:@selector(quitButtonTapped:)];
	
	
	_pausedMenu = [CCMenu menuWithItems:button1, button2, button3, button4, nil];
	[self addChild:_pausedMenu z:5000 tag:2];
	
	_pausedMenu.position =  ccp( _player.position.x, _player.position.y);
	[_pausedMenu alignItemsVerticallyWithPadding:20];
	[_pausedMenu runAction:[CCFadeIn actionWithDuration:0.3]];
}

- (void)genBackground {
	CGSize winSize = [CCDirector sharedDirector].winSize;
	_backGround = [CCSprite spriteWithFile:@"blue.png"];
	_backGround.position = _player.position;
	[self addChild:_backGround z:-1 tag:1];
}



#pragma mark particles
-(void) generateParticle:(int)type{
	_emitter = [CCParticleSystemQuad particleWithFile:@"fallingDown.plist"];
	_emitter.scale = 0.3;
}

/*
 -(void) updateParticles{
 CGSize screenSize = [CCDirector sharedDirector].winSize;
 if (_particleCurrentlyActive == NO){
 float rndDistanceMultiplierX = 1 + 2 * (arc4random() % 4);
 int maxYMultiplier = screenSize.height - 100;
 float rndDistanceMultiplierY = arc4random() % maxYMultiplier;
 _particleNode.position = ccp(_player.position.x + screenSize.width * rndDistanceMultiplierX, screenSize.height - rndDistanceMultiplierY);
 //modify this later for random types depending on level ...etc
 [self generateParticle:ATKA];
 _particleCurrentlyActive = YES;
 }else {
 //check if particle is already out of the scene
 float multiplier = _isCombatMode ? 1.4f : 1.0f;
 if (_particleNode.position.x  < _player.position.x - screenSize.width * multiplier){
 [_particleNode removeChild:_emitter cleanup:YES];
 _particleCurrentlyActive = NO;
 }
 
 }
 }*/



-(void) removeOutOfScreenPoints{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	for (Points* point in _points){
		if (point.sprite.position.x + point.sprite.contentSize.width/2 * point.sprite.scale < _player.position.x - screenSize.width/2){
            [point.sprite stopAllActions];
            [self movePointToNewPosition:point];
            [point startRotate];
            point.moveDone = NO;
            point.moving = NO;
		}
	}

}

-(void) removeOutOfScreenCombos{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	for (ComboFinisher* point in _comboFinishers){
		if (point.sprite.position.x + point.sprite.contentSize.width/2 * point.sprite.scale < _player.position.x - screenSize.width/2){
			[self moveComboToNewPosition:point];
		}
	}
}

-(void) removeOutOfScreenItems{
	[self removeOutOfScreenSpore];
	[self removeOutOfScreenAtka];
	[self removeOutOfScreenPoints];
//	[self removeOutOfScreenCombos];
}

#pragma mark speeds
-(void) setBoostSpeed{
	_playerAcceleration = _boostSpeed;
	_illnessTimeLeft = 0;
}


-(void) setNormalSpeed{
	_playerAcceleration = _normalSpeed;
	_illnessTimeLeft = 0;
	_boostTimeLeft = 0;
}

-(void) setSickSpeed{
	_playerAcceleration = _sickSpeed;
	_boostTimeLeft = 0;
}

-(void) increaseSpeed:(CGPoint) incr{
	_normalSpeed = ccpAdd(_normalSpeed, incr);
	_boostSpeed = ccpAdd(_boostSpeed, incr);
	_sickSpeed = ccpAdd(_sickSpeed, incr);
}


-(void) generateNextPoint:(int)types{
	Points* point = nil;	
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	if (types == YELLOW_SLOT){
		//but right now just add a point to a random location
		point =	[[Points alloc] initWithFileName:@"yellowFlower.png" withValue:1];
		[point createBox2dBodyDefinitions:_world];
		point.type = GOLD;
		[_points addObject:point];
		[_batchNode addChild:point.sprite z:50 tag:5];
	}else if (types == RED_SLOT){
		//but right now just add a point to a random location
		point =	[[Points alloc] initWithFileName:@"redFlower.png" withValue:1];
		[point createBox2dBodyDefinitions:_world];
		point.type = ATTACK_BOOST;
		[_points addObject:point];
		[_batchNode addChild:point.sprite z:50 tag:5];
	}else if (types == BLUE_SLOT){
		//but right now just add a point to a random location
		point =	[[Points alloc] initWithFileName:@"blueFlower.png" withValue:1];
		[point createBox2dBodyDefinitions:_world];
		point.type = EVADE_BOOST;
		[_points addObject:point];
		[_batchNode addChild:point.sprite z:50 tag:5];
	}
	
	[self movePointToNewPosition:point];
}


-(void) generateNextFinisher:(int) type{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];	
	ComboFinisher* point = nil;
	if (type == 0){
		point =	[[ComboFinisher alloc] initWithFileName:@"bombButton.png"];
		point.type = BOMB_SLOT;
	}else if (type == 1){
		point =	[[ComboFinisher alloc] initWithFileName:@"speedButton.png"];
		point.type = SPEED_SLOT;
	}else if (type == 2){
		point =	[[ComboFinisher alloc] initWithFileName:@"respawnButton.png"];
		point.type = REVIVER_SLOT;
	}
	[_batchNode addChild:point.sprite z:50 tag:5];
	
	float rnd = randRange(1, 1.5);
	float rndY = randRange(1, 3);
	point.sprite.position = ccp(_lastComboFinisher.x + _normalSpeed.x * 60 * 20 * rnd * type + 1, 
								rndY * screenSize.height/4);
	_lastComboFinisher = point.sprite.position;
	
	[point createBox2dBodyDefinitions:_world];
	[_comboFinishers addObject:point];
	
	point.taken = NO;
}


-(void) generateNextScreen{
	float rnd = randRange(1,4);
	
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	//determine a random possibility for spore, now I use 0.2;
	float rndSpore = CCRANDOM_0_1();
	
	if (_level.sporeAvailable){
		if (rndSpore <= 0.0005 && _sporeOutOfScreen == YES){
			_fireBall.sprite.position =  ccp(_player.position.x + screenSize.width/2 + screenSize.width/4, 
											 _slowestBoid.position.y );
			_sporeOutOfScreen = NO;
		}
	}
	
	if (_level.trapAvailable){
		if (rndSpore >= 0.0005 &&  rndSpore <= 0.001 && _atkaOutOfScreen == YES){
			_atka.sprite.position =  ccp(_player.position.x + screenSize.width/2 + screenSize.width/4, 
										 rnd * screenSize.height/6 );
		}
	}
}

/*
 -(void) generateNextScreen{
 //[self generatePredators];
 //divide the screen into 4 portions vertically
 //for each part, generate one object depending on the distance
 float rnd = randRange(1,4);
 
 CGSize screenSize = [[CCDirector sharedDirector] winSize];
 
 float rndType = CCRANDOM_0_1();
 
 if (rndType < 0.8){
 //but right now just add a point to a random location
 Points* point =	[[Points alloc] initWithFileName:@"yellowFlower.png" withValue:1];
 point.sprite.position  = ccp(_player.position.x + screenSize.width/2 + screenSize.width/4, 
 rnd * screenSize.height/5 );
 [point scaleSprite:0.5];
 [point createBox2dBodyDefinitions:_world];
 point.type = GOLD;
 [_points addObject:point];
 [_batchNode addChild:point.sprite z:50 tag:5];
 }else if (rndType > 1-(_attackBoostIntensity + _evadeBoostIntensity) &&
 rndType < 1 - _evadeBoostIntensity){
 //but right now just add a point to a random location
 Points* point =	[[Points alloc] initWithFileName:@"redFlower.png" withValue:1];
 point.sprite.position  = ccp(_player.position.x + screenSize.width/2 + screenSize.width/4, 
 rnd * screenSize.height/5 );
 [point scaleSprite:0.5];
 [point createBox2dBodyDefinitions:_world];
 point.type = ATTACK_BOOST;
 [_points addObject:point];
 [_batchNode addChild:point.sprite z:50 tag:5];
 }else if (rndType > 1 - _evadeBoostIntensity){
 //but right now just add a point to a random location
 Points* point =	[[Points alloc] initWithFileName:@"blueFlower.png" withValue:1];
 point.sprite.position  = ccp(_player.position.x + screenSize.width/2 + screenSize.width/4, 
 rnd * screenSize.height/5 );
 [point scaleSprite:0.5];
 [point createBox2dBodyDefinitions:_world];
 point.type = EVADE_BOOST;
 [_points addObject:point];
 [_batchNode addChild:point.sprite z:50 tag:5];
 }
 
 
 //determine a random possibility for spore, now I use 0.2;
 float rndSpore = CCRANDOM_0_1();
 if (rndSpore <= 0.1 && _sporeOutOfScreen == YES){
 _fireBall.sprite.position =  ccp(_player.position.x + screenSize.width/2 + screenSize.width/4, 
 _slowestBoid.position.y );
 _sporeOutOfScreen = NO;
 }
 
 
 if (rndSpore >= 0.2 &&  rndSpore <= 0.3 && _atkaOutOfScreen == YES){
 if (_atka == nil){
 _atka = [[[Atka alloc] initForNode:_batchNode] retain];
 [_atka createBox2dBodyDefinitions:_world];
 _atka.sprite.position =  ccp(_player.position.x + screenSize.width/2 + screenSize.width/4, 
 rnd * screenSize.height/5 );
 }else{
 _atka.sprite.position =  ccp(_player.position.x + screenSize.width/2 + screenSize.width/4, 
 rnd * screenSize.height/6 );
 }
 _atkaOutOfScreen = NO;
 }
 }
 */

-(void) updateLabels:(ccTime)dt{
	_backGround.position = ccp(_backGround.position.x + _playerAcceleration.x * dt * 60, _backGround.position.y);	
	_pauseButton.position = ccp(_pauseButton.position.x + _playerAcceleration.x * dt * 60, _pauseButton.position.y);	
    [self.hudLayer updatePoints:_pointsGathered];
}

-(void)resetButtonTapped:(id)sender{
	[_alchemy clearItems];
	[self clearItems];
}

-(void) initLabels{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];	
	[self.hudLayer initLabels];
    _pauseButton = [CCMenuItemImage		itemFromNormalImage:@"pauseButton.png" selectedImage:@"pauseButton.png" 
												  target:self selector:@selector(switchPause:)];
	
	
	CCMenu* _pauseMenu = [CCMenu menuWithItems:_pauseButton, nil];
	_pauseMenu.position = ccp(screenSize.width - _pauseButton.contentSize.width * 2, _pauseButton.contentSize.height);
	[self addChild:_pauseMenu z:502 tag:100];	
}

-(bool) isOnScreen:(CCSprite*) sprite{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	bool retVal = NO;
	if (sprite.position.x - sprite.contentSize.width/2 * sprite.scale < _player.position.x + screenSize.width/2 &&
		sprite.position.x + sprite.contentSize.width/2 * sprite.scale > _player.position.x - screenSize.width/2 &&
		sprite.position.y - sprite.contentSize.height/2 * sprite.scale < _player.position.y + screenSize.height/2 &&
		sprite.position.y + sprite.contentSize.height/2 * sprite.scale > _player.position.y - screenSize.height/2){
		retVal = YES;
	}
	return retVal;
}



#pragma mark effects for alchemy

-(void) bombEffect{
	
}


-(void) speedEffect{
	if (_boostTimeLeft == 0){
		for (Boid* bee in _bees){
			[bee boost:1.4 withForce:1.8];
		}	
	}
	_boostTimeLeft += EVADE_BOOST_TIME;
	[self setBoostSpeed];
}


-(void) normalEffect{
	for (Boid* bee in _bees){
		[bee cure];
	}
}

-(void) diseaseEffect{
	if (_illnessTimeLeft == 0){
		for (Boid* bee in _bees){
			[bee boost:0.6 withForce:0.7];
		}	
	}
	_illnessTimeLeft += EVADE_BOOST_TIME;
	[self setSickSpeed];
}

-(void) shrinkEffect{
	if (_shrinked == NO){
		for (Boid* bee in _bees){
			CCAction* shrinkAction = [CCScaleTo actionWithDuration:0.2 scale:bee.scale * 0.5];
			[bee runAction:shrinkAction];
		}
	}
	_shrinked = YES;
	_sizeModTimeLeft += EVADE_BOOST_TIME;
}

-(void) shrinkEffectDone{
	for (Boid* bee in _bees){
		CCAction* growAction = [CCScaleTo actionWithDuration:0.2 scale:bee.scale * 2];
		[bee runAction:growAction];
	}
	_shrinked = NO;
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
	
	if (_level.distanceToGoal < 0){
		if (self.comboFinisher != nil){
			if (self.comboFinisher.type == BOMB_SLOT){
				[self bombEffect];
			}else if (self.comboFinisher.type == SPEED_SLOT){
				[self speedEffect];
			}else if (self.comboFinisher.type == REVIVER_SLOT){
			}
			
			/*else if (effect == DISEASE_EFFECT){
			 [self diseaseEffect];
			 }else if (effect == SHRINK_EFFECT){
			 [self shrinkEffect];
			 }*/
		}
	}
}

-(void) clearItems{
	[self.hudLayer clearItems];
	[self clearItemValues];
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

#pragma mark out of screen stuff

-(void) removeOutOfScreenSpore{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	if (_fireBall != nil && _fireBall.sprite.position.x < _player.position.x - screenSize.width/2 - _fireBall.sprite.contentSize.width &&
		_sporeOutOfScreen == NO){
		_sporeOutOfScreen = YES;
	}
}


-(void) removeOutOfScreenAtka{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	if (_atka.sprite.position.x < _player.position.x - screenSize.width/2 - _atka.sprite.contentSize.width && _atkaOutOfScreen == NO){
		_atkaOutOfScreen = YES;
	}
}

-(bool)addItemValue:(int)value{
	if (_item1Value == 0){
		if (value == _goal1) {
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


-(void)moveComboToNewPosition:(ComboFinisher*) point{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	float rndY = randRange(1, 4);
	float rndX = randRange(1, 2);
	if (_lastComboFinisher.x  < _player.position.x + screenSize.width/2){
		_lastComboFinisher = ccp(_player.position.x + screenSize.width/2, 0);
	}
	
	point.sprite.position  = ccp(_lastComboFinisher.x + _playerAcceleration.x * 60 * 20 * rndX, 
								 rndY * screenSize.height/5 );	
	_lastComboFinisher = point.sprite.position;
	point.taken = YES;	
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
	point.taken = YES;
}


-(void) movePredatorToNewPosition:(Fish*) predator{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	float rnd = randRange(1, 4);
	if (_lastPredatorLocation.x  < _player.position.x + screenSize.width/2){
		_lastPredatorLocation = ccp(_player.position.x + screenSize.width/2, 10);
	}
    predator.sprite.position = ccp(_lastPredatorLocation.x + screenSize.width *randRange(0.5, 1),10);	
	_lastPredatorLocation = predator.sprite.position;
    predator.isJumping = NO;
    predator.isDead = NO;
}

-(void) moveToCemetery:(Boid *)sprite{	
	sprite.position = ccp(_player.position.x - 500, _player.position.y-500);
	[_cemeteryBees addObject:sprite];
	[_bees removeObject:sprite];
	[sprite clearEffects];
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


-(void) removeDeadItems{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	for (Points* point in _takenPoints){
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
            [point startRotate];
        }
		[self movePointToNewPosition:point];
	}
	[_takenPoints removeAllObjects];	
	for (ComboFinisher* finisher in _takenCombos) {
		PointTaken* actionMoveUp = [PointTaken actionWithDuration:0.4 moveTo:ccp(finisher.sprite.position.x - _playerAcceleration.x * 5,
																				 finisher.sprite.position.y + finisher.sprite.contentSize.height * finisher.sprite.scale)];
		CCAction* actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(actionMoveFinished:)];
		CCSprite* deadSprite = nil;		
		
		self.comboFinisher = finisher;
		if (finisher.type == BOMB_SLOT) {
			deadSprite = [CCSprite spriteWithSpriteFrameName:@"bombButton.png"];
		}else if (finisher.type == SPEED_SLOT){
			deadSprite = [CCSprite spriteWithSpriteFrameName:@"speedButton.png"];
		}else if (finisher.type == REVIVER_SLOT){
			deadSprite = [CCSprite spriteWithSpriteFrameName:@"respawnButton.png"];
		}
		
		[_batchNode addChild:deadSprite z:300 tag:300];
		deadSprite.position = finisher.sprite.position;
		deadSprite.scale = 0.1;
		[deadSprite runAction:[CCSequence actions:actionMoveUp, actionMoveDone, nil]];
		
		[self moveComboToNewPosition:finisher];		
	}
	[_takenCombos removeAllObjects];
	
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
		//[_batchNode removeChild:boid cleanup:YES];
		[self moveToCemetery:boid];
		//check if it was the slowest
		if ([_slowestBoid isEqual:boid]){
			_slowestBoid = nil;
		}
	}
	[_deadBees removeAllObjects];
	
	for (Fish* predator in _deadFish){
        if (predator.isDead){
            if ([self isOnScreen:predator.sprite]){
                CCAction* actionScaleIn = [CCScaleTo actionWithDuration:0.3f scale:1.3];
                CCAction* actionScaleDone = [CCCallFuncN actionWithTarget:self 
                                                                 selector:@selector(actionMoveFinished:)];
                CCSprite* deadSprite = [CCSprite spriteWithSpriteFrameName:@"beeDies.png"];
                deadSprite.position = predator.sprite.position;
                deadSprite.scale = 0.6;
                [deadSprite runAction:[CCSequence actions:actionScaleIn, actionScaleDone, nil]];	
                [_batchNode addChild:deadSprite z:299 tag:100];
            }
            [self movePredatorToNewPosition:predator];
        }
	}
	[_deadFish removeAllObjects];
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


#pragma mark collision detection


-(void) addRockHitEmitter:(CGPoint)location{
	_emitter = [CCParticleSystemQuad particleWithFile:@"watersplash.plist"];
	_emitter.position = location;
	_emitter.scale = 0.5;
	[self addChild:_emitter z:600 tag:600];
	_emitter.autoRemoveOnFinish = YES;
}


-(void)detectBox2DCollisions{
	//	std::vector<b2Body *>toDestroy; 
	std::vector<MyContact>::iterator pos;
	ConfigManager* sharedManager = [ConfigManager sharedManager];
	
	for(pos = _contactListener->_contacts.begin(); 
		pos != _contactListener->_contacts.end(); ++pos) {
		MyContact contact = *pos;
		b2Body *bodyA = contact.fixtureA->GetBody();
		b2Body *bodyB = contact.fixtureB->GetBody();
		if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
			if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && [bodyB->GetUserData() isKindOfClass:[Fish class]] ){
                Fish *predator = (Fish *) bodyB->GetUserData();
                if (!predator.isDead){
                    Boid *boid = (Boid *) bodyA->GetUserData();        
                    [self playDeadBeeSound];
                    [_deadBees addObject:boid];
                    [_deadFish addObject:predator];
                    predator.isDead = YES;
                    [predator.sprite stopAllActions];
                }
			}else if ([bodyB->GetUserData() isKindOfClass:[Boid class]] && [bodyA->GetUserData() isKindOfClass:[Fish class]] ){
                Fish *predator = (Fish *) bodyA->GetUserData();
                if (!predator.isDead){
                    Boid *boid = (Boid *) bodyB->GetUserData();
                    [self playDeadBeeSound];
                    [_deadBees addObject:boid];
                    [_deadFish addObject:predator];
                    predator.isDead = YES;
                    [predator.sprite stopAllActions];
                }
			}else if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && [bodyB->GetUserData() isKindOfClass:[Points class]] 
					  && ([bodyA->GetUserData() isKindOfClass:[Predator class]] == NO)){
				Points* point = (Points*) bodyB->GetUserData();
				if (point.taken == NO){
					point.taken = YES;
					_pointsGathered += point.value * _bonusCount;
					[_takenPoints addObject:point];
				}
			}else if ([bodyB->GetUserData() isKindOfClass:[Boid class]] && [bodyA->GetUserData() isKindOfClass:[Points class]]
					  && ([bodyB->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Points* point = (Points*) bodyA->GetUserData();
				if (point.taken == NO){
					point.taken = YES;
					[_takenPoints addObject:point];
				}
			}
			//ComboFinisher
			else if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && [bodyB->GetUserData() isKindOfClass:[ComboFinisher class]] 
					 && ([bodyA->GetUserData() isKindOfClass:[Predator class]] == NO)){
				ComboFinisher* point = (ComboFinisher*) bodyB->GetUserData();
				if (point.taken == NO){
					point.taken = YES;
					[_takenCombos addObject:point];
				}
			}else if ([bodyB->GetUserData() isKindOfClass:[Boid class]] && [bodyA->GetUserData() isKindOfClass:[ComboFinisher class]]
					  && ([bodyB->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				ComboFinisher* point = (ComboFinisher*) bodyA->GetUserData();
				if (point.taken == NO){
					point.taken = YES;
					[_takenCombos addObject:point];
				}
			}
			//SPORE
			else if ([bodyB->GetUserData() isKindOfClass:[Boid class]] && [bodyA->GetUserData() isKindOfClass:[Spore class]]
					 && ([bodyB->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Boid *) bodyB->GetUserData();
				[self playDeadBeeSound];
				[_deadBees addObject:boid];
				//		toDestroy.push_back(bodyB);
			}
			else if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && [bodyB->GetUserData() isKindOfClass:[Spore class]]
					 && ([bodyA->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Boid *) bodyA->GetUserData();
				[self playDeadBeeSound];
				[_deadBees addObject:boid];
				//		toDestroy.push_back(bodyA);
			}
			else if ([bodyA->GetUserData() isKindOfClass:[Fish class]] && [bodyB->GetUserData() isKindOfClass:[Spore class]]) {
				Fish *predator = (Fish *) bodyA->GetUserData();
				if ([self isOnScreen:predator.sprite]){
					[_deadFish addObject:predator];
				}
				//	toDestroy.push_back(bodyA);
			}
			else if ([bodyB->GetUserData() isKindOfClass:[Fish class]] && [bodyA->GetUserData() isKindOfClass:[Spore class]]) {
				Fish *predator = (Fish *) bodyB->GetUserData();
				if ([self isOnScreen:predator.sprite]){
					[_deadFish addObject:predator];
				}
				//	toDestroy.push_back(bodyB);
			}
			
			//ATKA
			else if ([bodyB->GetUserData() isKindOfClass:[Boid class]] && [bodyA->GetUserData() isKindOfClass:[Atka class]]
					 && ([bodyB->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Predator *) bodyB->GetUserData();
				[boid makeSick:0.5 withForce:0.5];
				_illnessTimeLeft = 2.0f;
				[self setSickSpeed];
			}
			else if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && [bodyB->GetUserData() isKindOfClass:[Atka class]]
					 && ([bodyA->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Predator *) bodyA->GetUserData();
				[boid  makeSick:0.5 withForce:0.5];
				_illnessTimeLeft = 2.0f;
				[self setSickSpeed];
			}
			else if ([bodyA->GetUserData() isKindOfClass:[Predator class]] && [bodyB->GetUserData() isKindOfClass:[Atka class]]) {
				Predator *predator = (Predator *) bodyA->GetUserData();
				[predator makeSick:0.5 withForce:0.5];
			}
			else if ([bodyB->GetUserData() isKindOfClass:[Predator class]] && [bodyA->GetUserData() isKindOfClass:[Atka class]]) {
				Predator *predator = (Predator *) bodyB->GetUserData();
				[predator makeSick:0.5 withForce:0.5];
			}
			//SEA
			else if ([bodyB->GetUserData() isKindOfClass:[Boid class]] && [bodyA->GetUserData() isKindOfClass:[Sea class]]
					 && ([bodyB->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Boid *) bodyB->GetUserData();
				[self playDeadBeeSound];
				[_deadBees addObject:boid];
				if (sharedManager.particles){
					[self addRockHitEmitter:boid.position];
				}
			}
			else if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && [bodyB->GetUserData() isKindOfClass:[Sea class]]
					 && ([bodyA->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Boid *) bodyA->GetUserData();
				[self playDeadBeeSound];
				[_deadBees addObject:boid];
				if (sharedManager.particles){
					[self addRockHitEmitter:boid.position];
				}
			} 
            //Harvester
			else if ([bodyB->GetUserData() isKindOfClass:[Boid class]] && [bodyA->GetUserData() isKindOfClass:[NSString class]]
					 && ([bodyB->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Boid *) bodyB->GetUserData();
				[self playDeadBeeSound];
				[_deadBees addObject:boid];
                //		toDestroy.push_back(bodyB);
			}
			else if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && [bodyB->GetUserData() isKindOfClass:[NSString class]]
					 && ([bodyA->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Boid *) bodyA->GetUserData();
				[self playDeadBeeSound];
				[_deadBees addObject:boid];
                //		toDestroy.push_back(bodyA);
			}
            
            //Bullet
			else if ([bodyB->GetUserData() isKindOfClass:[Boid class]] && [bodyA->GetUserData() isKindOfClass:[Bullet class]]
					 && ([bodyB->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Boid *) bodyB->GetUserData();
				[self playDeadBeeSound];
				[_deadBees addObject:boid];
                //		toDestroy.push_back(bodyB);
			}
			else if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && [bodyB->GetUserData() isKindOfClass:[Bullet class]]
					 && ([bodyA->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Boid *) bodyA->GetUserData();
				[self playDeadBeeSound];
				[_deadBees addObject:boid];
                //		toDestroy.push_back(bodyA);
			}
            else if ([bodyB->GetUserData() isKindOfClass:[Fish class]] && [bodyA->GetUserData() isKindOfClass:[Bullet class]]) {
                Fish *predator = (Fish *) bodyB->GetUserData();
				if (!predator.isDead && [self isOnScreen:predator.sprite]){
                    [_deadFish addObject:predator];
                    predator.isDead = YES;
                    [predator.sprite stopAllActions];
                }
			}
			else if ([bodyA->GetUserData() isKindOfClass:[Fish class]] && [bodyB->GetUserData() isKindOfClass:[Bullet class]]) {
                Fish *predator = (Fish *) bodyA->GetUserData();
				if (!predator.isDead && [self isOnScreen:predator.sprite]){
                    [_deadFish addObject:predator];
                    predator.isDead = YES;
                    [predator.sprite stopAllActions];
                }
                //		toDestroy.push_back(bodyA);
			}
		}   
	}
	
	/*
	 std::vector<b2Body *>::iterator pos2;
	 for(pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
	 b2Body *body = *pos2;     
	 _world->DestroyBody(body);
	 }	*/
	
}

-(void) actionMoveFinished:(id)sender{
	[_batchNode removeChild:(CCSprite*)sender cleanup:YES];
}


-(void) actionBonusFinished:(id)sender{
	[self removeChild:(CCLabelTTF*)sender cleanup:YES];
}

-(void) loadingTextures{
    //fist stop the music and load some ambience
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
	_bonusCount = 1;
    _currentDifficulty = 1;
    _minBirdDistance = 1300;
	[self unschedule:@selector(loadingTextures)];
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	[[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:NO];
	self.isTouchEnabled = YES;
	
	_batchNode = [CCSpriteBatchNode batchNodeWithFile:@"seaSheet_Untitled.pvr.ccz"]; // 1
	[self addChild:_batchNode z:500 tag:500]; // 2
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"seaSheet_Untitled.plist" textureFile:@"seaSheet_Untitled.pvr.ccz"];
	
	//init the box2d world
	b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
	bool doSleep = true;
	_world = new b2World(gravity, doSleep);
	
	_contactListener = new MyContactListener();
	//set the contactListener for the world
	_world->SetContactListener(_contactListener);
	
	//	_contactFilter = new MyContactFilter();
	//	_world->SetContactFilter(_contactFilter);
	
	_atkaOutOfScreen = YES;
	_sporeOutOfScreen = NO;
    
    _maxFishJump = screenSize.height/4;
	
	//box2d end
	_beeSick = NO;
	//set the speeds 
	
	if (_level.difficulty == EASY){
		_normalSpeed = ccp(1.5,0);	
		_boostSpeed = ccp(2.0,0);
		_sickSpeed = ccp(1.0,0);
	}else if (_level.difficulty == NORMAL){
		_normalSpeed = ccp(2.0,0);
		_boostSpeed = ccp(3.0,0);
		_sickSpeed = ccp(1.5,0);
	}else if (_level.difficulty == HARD){
		_normalSpeed = ccp(3,0);
		_boostSpeed = ccp(4.5,0);
		_sickSpeed = ccp(1.5,0);
	}
	_playerAcceleration = _normalSpeed;
	_pointsGathered = 0;
	_boostTimeLeft = 0;
	_lastPointLocation = ccp(screenSize.width, 0);
	_lastPredatorLocation = ccp(screenSize.width, 0);
	_lastComboFinisher = ccp(screenSize.width, 0);
	_distanceTravelled = 0;
	
	_totalTimeElapsed = 0;
	
	_points = [[[NSMutableArray alloc] init]retain];
	_takenPoints = [[[NSMutableArray alloc] init]retain];
	_takenCombos = [[[NSMutableArray alloc] init] retain];
	_bees = [[[NSMutableArray alloc] init] retain];
	_deadBees = [[[NSMutableArray alloc] init] retain];
	_fish = [[[NSMutableArray alloc] init]retain];
	_deadFish = [[[NSMutableArray alloc] init]retain];
	_cemeteryBees = [[[NSMutableArray alloc] init] retain];
	_particleNode = [[CCNode alloc] init];
    _birds = [[[NSMutableArray alloc] init] retain];
	_particleNode.position = ccp(0,0);
	
	CGRect boidRect = CGRectMake(0,0, 16, 16);
	
	_currentTouch = CGPointZero;
	
	_player = [[CCSprite alloc] init];
	_player.position = ccp(screenSize.width/2 , screenSize.height/2);
	_player.opacity = 0;
	
	_currentTouch = _player.position;
	
	[self addChild:_player z:110 tag:2];
	[self setViewpointCenter:_player.position];
	
	float randomDist = randRange(1, 4);
	float randomY = randRange(0.2, 0.5);
		
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
		
		if (_level.difficulty == EASY){
			[boid setSpeedMax:2.5f  withRandomRangeOf:0.2f andSteeringForceMax:1.8f  withRandomRangeOf:0.25f];
			_boidCurrentSpeed = 2.5f;
			_boidCurrentTurn = 1.8f;
		}else if (_level.difficulty == NORMAL){
			[boid setSpeedMax:3.0f  withRandomRangeOf:0.2f andSteeringForceMax:1.8f * 1.5f withRandomRangeOf:0.25f];
			_boidCurrentSpeed = 3.0f;
			_boidCurrentTurn = 2.7f;
		}else if (_level.difficulty == HARD) {
			[boid setSpeedMax:4.0f  withRandomRangeOf:0.2f andSteeringForceMax:1.8f * 1.5f withRandomRangeOf:0.25f];
			_boidCurrentSpeed = 4.0f;
			_boidCurrentTurn = 2.7f;
		} 		
		
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
	
	for (int i = 0; i < 12; i++) {
		[self generateNextPoint: (i % 3)+1];
	}
	
 
    //testpredator
    _minFishDistance = screenSize.width * 2;
    for (int i = 0; i < 3; i++){
        Fish* fish = [[Fish alloc] initForNode:_batchNode];
        fish.sprite.position = ccp(_minFishDistance * (i + 1), 10);
        _lastPredatorLocation = fish.sprite.position;
        [_fish addObject:fish];
        [fish createBox2dBodyDefinitions:_world];
    }
    
    for (int i = 0; i < 2; i++){
        Spore* bird = [[Spore alloc] initForSeaNode:_batchNode];
        [bird createBox2dBodyDefinitionsSeaBird:_world];
        [_birds addObject:bird];
        bird.sprite.position = ccp((i+10) * _minBirdDistance, 240);
    }
	
	//init the array for clouds
	_clouds = [[NSMutableArray alloc] init];
	//init the clouds
	CCSprite* bgCloud;
	for (int i= 0; i <3; i++){
		bgCloud = [CCSprite spriteWithSpriteFrameName:@"cloudsmall.png"];
		bgCloud.scale = randRange(0.2, 0.5);
		bgCloud.opacity = 220;
		[_clouds addObject:bgCloud];
	}
	
	// init the parallax node 
	_backGroundNode = [CCParallaxNode node];
	[self addChild:_backGroundNode z:2];
	CGPoint bgSpeed = ccp(0.1, 0.0);
	_backGroundNode.position = _player.position;
	
	// init the background
	[self genBackground];
	
	for (CCSprite* cloud in _clouds) {
		float rnd = randRange(0.1, 1.0);
		float rndOffset = randRange(400, 1000);
		CGPoint positionOffsetForCloud = ccp(screenSize.width - cloud.contentSize.width * cloud.scale + rndOffset, 
											 screenSize.height - cloud.contentSize.height * cloud.scale);
		[_backGroundNode addChild:cloud z:2 parallaxRatio:ccp(rnd*0.5/4,0) positionOffset:positionOffsetForCloud];
	}
	[self initLabels];	
	[self schedule:@selector(loadingTerrain)];
}


-(void) loadingTerrain{
	[self unschedule:@selector(loadingTerrain)];
    [self.harvesterLayer initWithWorld:_world];
	_topSea = [[[NSMutableArray alloc] init] retain];
	_bottomSea = [[[NSMutableArray alloc] init] retain];
	
    Sea* bottomSea1 = [[Sea alloc] initForNode:_batchNode];
    CCSprite* topSea1 = [CCSprite spriteWithSpriteFrameName:@"tengerTop2.png"];
    [bottomSea1.sprite.texture setAliasTexParameters];
    [topSea1.texture setAliasTexParameters];

    Sea* bottomSea2 = [[Sea alloc] initForNode:_batchNode];
    CCSprite* topSea2 = [CCSprite spriteWithSpriteFrameName:@"tengerTop2.png"];
    [bottomSea2.sprite.texture setAliasTexParameters];
    [topSea2.texture setAliasTexParameters];

    bottomSea1.sprite.position = ccp(bottomSea1.sprite.contentSize.width/2 * bottomSea1.sprite.scale, bottomSea1.sprite.contentSize.height/2 * bottomSea1.sprite.scale - 30);
    bottomSea2.sprite.position = ccp(bottomSea2.sprite.contentSize.width/2 * bottomSea2.sprite.scale * 3 - 3, bottomSea2.sprite.contentSize.height/2 * bottomSea2.sprite.scale - 30);
    topSea1.position = ccp(topSea1.contentSize.width/2, topSea1.contentSize.height/2 + bottomSea1.sprite.contentSize.height/3 * bottomSea1.sprite.scale - 70);
    topSea2.position = ccp(topSea2.contentSize.width/2 * 3 - 3, topSea2.contentSize.height/2 + bottomSea2.sprite.contentSize.height/3 * bottomSea2.sprite.scale - 70);
    [bottomSea1 createBox2dBodyDefinitions:_world];
    [bottomSea2 createBox2dBodyDefinitions:_world];
    [_batchNode addChild:topSea1 z:2 tag:50];
    [_batchNode addChild:topSea2 z:2 tag:50];
    [_topSea addObject:topSea1];
    [_topSea addObject:topSea2];
    [_bottomSea addObject:bottomSea1];
    [_bottomSea addObject:bottomSea2];
    
 //   self.island = [CCSprite spriteWithSpriteFrameName:@"island.png"];
 //   [_batchNode addChild:self.island z:1];
 //   self.island.scale = 0.8;
 //   self.island.position = ccp(500,self.island.contentSize.height * 0.6);
    	
	[self schedule:@selector(loadingSounds)];
}

-(void) loadingSounds{
	[self unschedule:@selector(loadingSounds)];
	_auEffectLeft = 0;
	ConfigManager* sharedManager = [ConfigManager sharedManager];
	if (sharedManager.sounds){
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"au.wav"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"woohoo.wav"];
	}
    if (sharedManager.music){
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"seamusic.mp3"];
    }
	[self schedule:@selector(loadingDone)];
}

-(void) loadingDone{
	[self unschedule:@selector(loadingDone)];
    [self.pauseLayer loadingFinished];
	_gameIsReady = YES;
	//add some tap to start
	_alchemy = [[[Alchemy alloc]init] retain];
	_alchemy.world = self;
}

-(id) initWithLayers:(HUDLayer *)hudLayer pause:(PauseLayer *)pauseLayer message:(MessageLayer *)messageLayer harvester:(HarvesterLayer*)harvesterLayer{
	if ((self = [super init])){
		self.hudLayer = hudLayer;
        self.pauseLayer = pauseLayer;
        self.messageLayer = messageLayer;
        self.harvesterLayer = harvesterLayer;
        pauseLayer.gameScene = self;
		self.level = (Level*)[[LevelManager sharedManager] selectedLevel];
		_distanceToGoal = _level.distanceToGoal;
		if (_level.difficulty == EASY && _distanceToGoal != -1){
			_distanceToGoal = _distanceToGoal/2;
		}else if (_level.difficulty == NORMAL && _distanceToGoal != -1){
			_distanceToGoal = _distanceToGoal/3*2;
		}
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		_gameIsReady = NO;
		_gameStarted = NO;
		_paused = NO;
        
        //pausemenu
        [self schedule: @selector(loadingTextures) interval: 0.25];
	}
	return self;
}

-(void) updateBox2DWorld:(ccTime)dt{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    timeAccumulator+=dt;
    if (timeAccumulator > (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL)){
        timeAccumulator = UPDATE_INTERVAL;
    }
    
    while (timeAccumulator >= UPDATE_INTERVAL){
        timeAccumulator -= UPDATE_INTERVAL;
    	
        for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
            if ([b->GetUserData() isKindOfClass:[Spore class]]){
                Spore *spore = (Spore *)b->GetUserData();
                b2Vec2 b2Position = b2Vec2(spore.sprite.position.x/PTM_RATIO,
                                           spore.sprite.position.y/PTM_RATIO);
                float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(spore.sprite.rotation);
                b->SetTransform(b2Position, b2Angle);
            }else if ([b->GetUserData() isKindOfClass:[Atka class]]){
                Atka *atka = (Atka *)b->GetUserData();
                b2Vec2 b2Position = b2Vec2(atka.sprite.position.x/PTM_RATIO,
                                           atka.sprite.position.y/PTM_RATIO);
                float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(atka.sprite.rotation);
                b->SetTransform(b2Position, b2Angle);
            }else if ([b->GetUserData() isKindOfClass:[Points class]]){
                Points *point = (Points *)b->GetUserData();
                b2Vec2 b2Position = b2Vec2(point.sprite.position.x/PTM_RATIO,
                                           point.sprite.position.y/PTM_RATIO);
                float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(point.sprite.rotation);
                b->SetTransform(b2Position, b2Angle);
            }else if ([b->GetUserData() isKindOfClass:[ComboFinisher class]]){
                ComboFinisher *point = (ComboFinisher *)b->GetUserData();
                b2Vec2 b2Position = b2Vec2(point.sprite.position.x/PTM_RATIO,
                                           point.sprite.position.y/PTM_RATIO);
                float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(point.sprite.rotation);
                b->SetTransform(b2Position, b2Angle);
            }else if ([b->GetUserData() isKindOfClass:[Sea class]]){
                Sea *sea = (Sea *)b->GetUserData();
                b2Vec2 b2Position = b2Vec2(sea.sprite.position.x/PTM_RATIO,
                                           sea.sprite.position.y/PTM_RATIO);
                float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(sea.sprite.rotation);
                b->SetTransform(b2Position, b2Angle);			
            }else if ([b->GetUserData() isKindOfClass:[Fish class]]){
                Fish *fish = (Fish *)b->GetUserData();
                b2Vec2 b2Position = b2Vec2(fish.sprite.position.x/PTM_RATIO,
                                           fish.sprite.position.y/PTM_RATIO);
                if  (fish.sprite.position.x + fish.sprite.contentSize.width/2 * fish.sprite.scale < _player.position.x + screenSize.width/2){
                    b->SetAwake(true);
                    b->SetActive(true);
                }else{
                    b->SetAwake(false);
                    b->SetActive(false);
                }
                float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(fish.sprite.rotation);
                b->SetTransform(b2Position, b2Angle);			
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
            }else if ([b->GetUserData() isKindOfClass:[NSString class]]){
                CCSprite *sprite = self.harvesterLayer.harvesterSprite;
                CGPoint point = [self convertToNodeSpace:self.harvesterLayer.harvesterSprite.position];
                b2Vec2 b2Position = b2Vec2(point.x/PTM_RATIO,
                                           point.y/PTM_RATIO);
                float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(sprite.rotation);
                b->SetTransform(b2Position, b2Angle);
            }else{
                CCSprite *sprite = (CCSprite *)b->GetUserData();
                b2Vec2 b2Position = b2Vec2(sprite.position.x/PTM_RATIO,
                                           sprite.position.y/PTM_RATIO);
                float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(sprite.rotation);
                b->SetTransform(b2Position, b2Angle);
            }
        }	
        _world->Step(UPDATE_INTERVAL, 0, 2);
    }
}


-(void)respawnCloud{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	for (CCSprite *background in _clouds) {
		if ([_backGroundNode convertToWorldSpace:background.position].x < -background.contentSize.width) {
			[_backGroundNode incrementOffset:ccp(screenSize.width + background.contentSize.width * 2,0) forChild:background];
			background.scale = randRange(0.1, 0.8);
		}
	}
}

-(void) updateTerrain{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	float moveX = _playerAcceleration.x * 0.4;
	for (CCSprite* sea in _topSea) {
		sea.position = ccpAdd(sea.position, ccp(-moveX * 0.1, 0));
		if (sea.position.x + sea.contentSize.width/2 * sea.scale < _player.position.x - screenSize.width/2){
			sea.position = ccp(sea.position.x + sea.contentSize.width * ([_bottomSea count]) - 6, sea.position.y);
		}
	}
	
	for (Sea* sea in _bottomSea) {
		sea.sprite.position = ccpAdd(sea.sprite.position, ccp(-moveX, 0));
		if (sea.sprite.position.x + sea.sprite.contentSize.width/2 * sea.sprite.scale < _player.position.x - screenSize.width/2){
			sea.sprite.position = ccp(sea.sprite.position.x + sea.sprite.contentSize.width * 2 * sea.sprite.scale - 6, sea.sprite.position.y);
		}
	}
    
    if (self.island.position.x + self.island.contentSize.width/2 < _player.position.x - screenSize.width/2){
        self.island.position = ccp(_player.position.x + screenSize.width/2 + self.island.contentSize.width * 3, self.island.position.y);
    }else{
        self.island.position = ccpAdd(self.island.position, ccp(_playerAcceleration.x - 0.05, 0));
    }
}

-(void)selectTarget:(Predator*)predator{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	predator.target = _slowestBoid.position;
}


-(void) gameOverRestartTapped:(id)sender{
    if (_newHighScore && _distanceToGoal < 0){
        [self saveLevelPerformance];
    }
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.0 scene:[SeaScene scene] withColor:ccBLACK]];
}

-(void) gameOverExitTapped:(id)sender{
    if (_newHighScore && _distanceToGoal < 0){
        [self saveLevelPerformance];
    }
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.0 scene:[LevelSelectScene scene] withColor:ccBLACK]];
}

-(void) gameOver{
    [self unschedule:@selector(update:)];
    [self removeChild:_pauseMenu cleanup:YES];
    if (_newHighScore && _distanceToGoal < 0){
        [self saveLevelPerformance];    
    }
    
      [self.pauseLayer gameOver:_pointsGathered withHighScore:self.level.highScorePoints];
}

-(void) levelDone{
	[self unschedule:@selector(update:)];
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	CCSprite* gameOverSprite = [CCSprite spriteWithFile:@"gameOverOverlay.png"];
	gameOverSprite.position = _player.position;
	gameOverSprite.scaleX = 1.8f;
	gameOverSprite.opacity = 0;
	[self addChild:gameOverSprite z:599 tag:299];
	[gameOverSprite runAction:[CCFadeIn actionWithDuration:0.2]];
	
	CCLabelTTF* gameOverLabel = [[CCLabelTTF alloc] initWithString:@"Level Complete" fontName:@"Marker Felt" fontSize:32];
	[self addChild:gameOverLabel z:600 tag:10];
	gameOverLabel.position = ccpAdd(_player.position, ccp(0, screenSize.height/5));
	//gameOverLabel.opacity = 0;
	
	CCLabelTTF* scoreLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"Points:  %i", _pointsGathered] fontName:@"Marker Felt" fontSize:14];	
	if (_newHighScore) {
		_level.highScorePoints = _pointsGathered;
	}
	
	CCLabelTTF* highscoreLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"HighScore:  %i", _level.highScorePoints]  fontName:@"Marker Felt" fontSize:14];	
	
	scoreLabel.position = _player.position;
	[self addChild:scoreLabel z:600 tag:600];
	
	highscoreLabel.position = ccpAdd(scoreLabel.position, ccp(0, -screenSize.height/5));
	[self addChild:highscoreLabel z:600 tag:600];
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
	}else if(_distanceTravelled >= _distanceToGoal && _distanceToGoal > 0){
		[self levelDone];
		_isLevelDone = YES;
	}
}


-(void) beeDefaultMovement:(Boid*) bee withDt:(ccTime)dt{
	[bee wander:0.1];
	[self separate:bee withSeparationDistance:40.0f usingMultiplier:0.4f];
	[self align:bee withAlignmentDistance:30.0f usingMultiplier:0.2f];
	[self cohesion:bee withNeighborDistance:40.0f usingMultiplier:0.1f];	
}

-(void) beeMovement:(ccTime)dt{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	bool tmpSick = NO;
	for (Boid* bee in _bees){
		bee.leftEdgePosition = ccp(_player.position.x - screenSize.width/2+ 10, _player.position.y);
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
	
	if (tmpSick) {
		_beeSick = YES;
	}else{
		_beeSick = NO;
	}
}

-(void) updateCurrentDifficulty{
	if (_totalTimeElapsed - 10 * _currentDifficulty >= 10) {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        float rndChange = randRange(1, 6);
        int change = floor(rndChange);
        bool changeWasEnough = NO;
        //time to increase the difficulty
		_currentDifficulty++;
		//increase the playeracceleration if it is not at the maximum
        
        if (_normalSpeed.x <= 3.0){
            _normalSpeed.x += 0.05;
            _sickSpeed.x += 0.025;
            _boostSpeed.x += 0.1;
            
            if (_normalSpeed.x > 2.0f && _normalSpeed.x < 3.0f){
                _level.difficulty = NORMAL;
            }else if (_normalSpeed.x > 3.0f){
                _level.difficulty = HARD;
            }
            
            //	if (_illnessTimeLeft > 0 || _boostTimeLeft > 0){
            //		_playerAcceleration.x += 0.05;
            //	}else {
            _playerAcceleration.x += 0.05;
            //	}
        }
        
        //increase the boid speed, if it is not at the maximum
        if (_boidCurrentSpeed < 4.0f){
            changeWasEnough = YES;
            _boidCurrentSpeed+=0.05;
            for (Boid* bee in _bees){
                [bee setSpeedMax:_boidCurrentSpeed  withRandomRangeOf:0.2f andSteeringForceMax:1.8f * 1.5f withRandomRangeOf:0.25f];
                bee.startMaxSpeed = _boidCurrentSpeed;
            }
        }
        
        
        if ( _maxFishJump < screenSize.height/4 * 3){
            _maxFishJump += 2;
        }
              
        if (change == 1 || changeWasEnough == NO){
            if (_fishJumpTime < 1.0f){
                _fishJumpTime -= 0.1;
            }
        }

		//increase the chance of spore if it is not at the maximum
		
		//increase the chance of atka if it is not at the maximum
		
		//decrease the distance between the predators if it is not at the minimum
		
		
	}
}


-(void) updatePoints{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
	for (Points* point in _points){
		if ((point.sprite.position.x > _player.position.x + screenSize.width/2) && 
            point.sprite.position.x < _lastPointLocation.x){
			point.taken = NO;
		}
        if (_currentDifficulty > 10 && point.sprite.position.x < _player.position.x + screenSize.width/2 && point.moving == NO){
            [point update];
        }
	}
    
    /*
	for (ComboFinisher* point in _comboFinishers){
		if (![self isOnScreen:point.sprite]){
			point.taken = NO;
		}
	}*/
}


-(void)updateSounds:(ccTime)dt{
	if (_auEffectLeft > 0){
		_auEffectLeft-=dt;
		if (_auEffectLeft < 0){
			_auEffectLeft = 0;
		}
	}
}


-(void) updateFish{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    for (Fish* fish in _fish){
        if (fish.sprite.position.x + fish.sprite.contentSize.width/2 * fish.sprite.scale < _player.position.x - screenSize.width/2 && fish.isJumping == NO){
            //respawn the fish
            [self movePredatorToNewPosition:fish];
        }else if (!fish.isJumping){
            if (fish.sprite.position.x - fish.sprite.contentSize.width/2 * fish.sprite.scale <= _player.position.x + screenSize.width/2 ){
                [fish.sprite stopAllActions];
                [fish.sprite runAction:fish.animation];
                CCAction* jump = [CCJumpTo actionWithDuration:4 position:ccp(fish.sprite.position.x - screenSize.width, fish.sprite.position.y) height:_maxFishJump jumps:2];
                CCAction* jumpDone = [CCCallFunc actionWithTarget:fish selector:@selector(jumpDone:)];
                [fish.sprite runAction:[CCSequence actions:jump, jumpDone, nil]];
                fish.isJumping = YES;
            }
        }
    }
}


-(void) updateBird:(ccTime)dt{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    for (Spore* bird in _birds){
        if (bird.sprite.position.x + bird.sprite.contentSize.width * bird.sprite.scale < _player.position.x - screenSize.width){
            //respawn the bird
            bird.sprite.position = ccp(_player.position.x + screenSize.width/2 + _minBirdDistance, bird.sprite.position.y);
        }else{
            //move the bird
            bird.sprite.position = ccp(bird.sprite.position.x - 2 * dt * 60, bird.sprite.position.y);
        }
    }
}


-(void)update:(ccTime)dt{
	float tickTime = 1.0f/60.0f;
	_totalTimeElapsed += tickTime;
	if (_totalTimeElapsed > 0.7){
		if (_gameStarted){
			if (_updateBox == NO) {
				_updateBox = YES;
			}			
			_totalTimeElapsed += tickTime;
			[self updateCurrentDifficulty];
			
			if (_isGameOver == NO && _isLevelDone == NO){
                [self removeDeadItems];
				//decrease boost, enemy, and illnesstimes
				if (_boostTimeLeft > 0){
					_boostTimeLeft -= tickTime;
					if (_boostTimeLeft <= 0){
						[self setNormalSpeed];
						[self normalEffect];
						_boostTimeLeft = 0;;
					}
				}	
				
				if (_illnessTimeLeft > 0){
					_illnessTimeLeft -= tickTime;
					if (_illnessTimeLeft <= 0){
						[self setNormalSpeed];
						[self normalEffect];
						_illnessTimeLeft = 0;;
					}
				}
				
				if (_sizeModTimeLeft > 0){
					_sizeModTimeLeft -= dt;
					if (_sizeModTimeLeft <= 0){
						if (_shrinked){
							[self shrinkEffectDone];
						}
						_illnessTimeLeft = 0;;
					}
				}
                
				if (_touchEnded){
					_currentTouch = ccp(_currentTouch.x + _playerAcceleration.x, _currentTouch.y);
				}
				if (_fireBall != nil){
					_fireBall.sprite.position = ccpAdd(_fireBall.sprite.position, ccp(0,0));
				}
                
				//parallaxNode
				CGPoint backgroundScrollVel = ccp(-10, 0);
				_backGroundNode.position = ccpAdd(_backGroundNode.position, backgroundScrollVel);
				//ccpMult(backgroundScrollVel, dt));
				CGSize screenSize = [[CCDirector sharedDirector] winSize];
				
				_player.position = ccpAdd(_player.position, ccp(_playerAcceleration.x * dt * 60, _playerAcceleration.y * dt * 60));
                [self setViewpointCenter:_player.position];
				[self updateLabels:dt];
				for (Boid* boid in _bees){
					if (_slowestBoid == nil){
						_slowestBoid = boid;
					}else {
						if (boid.maxSpeed < _slowestBoid.maxSpeed){
							_slowestBoid = boid;
						}
					}
				}
                
                if (self.harvesterLayer.moveInParticle && !_evilAppearDone){
                    [self.messageLayer displayWarning:@"It is coming"];
                    _evilAppearDone = YES;
                }else if (self.harvesterLayer.moveOutParticle && _evilAppearDone){
                    _evilAppearDone = NO;
                }
				
				[self beeMovement:dt];
                [self updateFish];	
                [self updateBird:dt];
				[self removeOutOfScreenItems];
                [self updateTerrain];
				//update terrain, tell it how far we have proceeded
				//[_terrain setOffsetX:_playerAcceleration.x];
				//respawn the clouds if needed
				[self respawnCloud];
				if (_updateBox) {
					_updateBox = NO;
					[self updateBox2DWorld:dt];
				}
				
				//detect the collisions
				[self detectBox2DCollisions];
				[self detectGameConditions];
				_distanceTravelled = _player.position.x /3 ;
				if (_level.sporeAvailable || _level.trapAvailable){
					[self generateNextScreen];
				}
                [self.harvesterLayer update:dt];
				[self updatePoints];
				[self updateSounds:dt];
			}
		}
	}
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

-(void) align:(Boid*)bee withAlignmentDistance:(float)neighborDistance usingMultiplier:(float)multiplier;
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

-(void) switchPause:(id)sender{
	if (_paused == NO){
		[self unschedule:@selector(update:)];
        [self.pauseLayer switchPause];
		_paused = YES;
	}else{
		_paused = NO;
        [self.pauseLayer switchPause];
        self.updateBox = 0;
		[self schedule: @selector(update:)];
        _pausedMenu = nil;
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
	if (_gameIsReady && _gameStarted == NO && _isLevelDone == NO){
		CGSize screenSize = [CCDirector sharedDirector].winSize;
        [self.pauseLayer startGame];
        _gameStarted = YES;
        if ([[ConfigManager sharedManager] music]){
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"seamusic.mp3" loop:YES];
        }
		[self schedule: @selector(update:)];
		[self generateGoals];
        return NO;
	}else if (_gameIsReady && _gameStarted){
		self.currentTouch = [self convertTouchToNodeSpace: touch];
		self.currentTouch = ccp(self.currentTouch.x - 10, self.currentTouch.y);
		if (_isGameOver){
            return NO;
		}else if (_isLevelDone) {
			[self saveLevelPerformance];
            [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
			[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.0 scene:[MainMenuScene scene] withColor:ccBLACK]];
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




-(void) saveLevelPerformance{
	NSLog(@"saving level performance");
	LevelManager* sharedManager = [LevelManager sharedManager];
	if (_newHighScore){
		sharedManager.selectedLevel.highScorePoints = _pointsGathered;
	}
	sharedManager.selectedLevel.completed = YES;
	
	[sharedManager saveSelectedLevel];
	
}




-(void) dealloc{	
	[super dealloc];
    self.messageLayer = nil;
    self.pauseLayer = nil;
    self.hudLayer = nil;
	[_bees release];
	_bees = nil;
	[_fish removeAllObjects];
    [_deadFish removeAllObjects];
    _deadFish = nil;
	_fish = nil;
	[_clouds release];
	_clouds = nil;
	[_level release];
	_level = nil;
	_fireBall = nil;
	_atka = nil;
	[_alchemy release];
	_alchemy = nil;
	
	_pointsSprite = nil;
	_batchNode = nil;
	_loadingScreen = nil;
	_tapToStartSprite = nil;
	_particleNode = nil;
	_emitter = nil;
	_slowestBoid = nil;
	_terrain = nil;
	_backGround = nil;
	[_cemeteryBees release];
	_cemeteryBees = nil;
    _harvesterLayer = nil;
//	[_comboFinishers release];
//	_comboFinishers = nil;
//	[_comboFinisher release];
}	


@end




