//
//  HelloWorldScene.mm
//  bees
//
//  Created by macbook white on 7/18/11.
//  Copyright nincs 2011. All rights reserved.
//


// Import the interfaces
#import "CampaignScene.h"
#import "LevelManager.h"

#define rad2Deg 57.2957795

#define leftEdge 0.0f
#define bottomEdge 0.0f
#define topEdge 320.0f
#define rightEdge 480.0f

#define IGNORE 1.0f

#define kFilteringFactor 0.05


@implementation CampaignScene
@synthesize  currentTouch = _currentTouch;
@synthesize attackEnabled = _attackEnabled;
@synthesize evadeEnabled = _evadeEnabled;
@synthesize paused = _paused;
@synthesize attackBoostIntensity = _attackBoostIntensity;
@synthesize evadeBoostIntensity = _evadeBoostIntensity;
@synthesize level = _level;
@synthesize comboFinisher = _comboFinisher;
@synthesize comboFinishers = _comboFinishers;
@synthesize hudLayer = _hudLayer;
@synthesize pauseLayer = _pauseLayer;


+(id)scene{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	HUDLayer *hud = [HUDLayer node];
    [scene addChild:hud z:1];
    
    PauseLayer* pauseLayer = [PauseLayer node];
    [scene addChild:pauseLayer z:2];
	
	
	// 'layer' is an autorelease object.
	CampaignScene *layer =  [[[CampaignScene alloc] initWithLayers:hud pause:pauseLayer] autorelease];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}



-(void) optionsButtonTapped:(id)sender{
	
}

-(void) storeButtonTapped:(id)sender{
	
}

-(void) quitButtonTapped:(id)sender{
	
}

- (void)genBackground {
	/*
	//   [_backGround removeFromParentAndCleanup:YES];
    ccColor4F bgColor = ccc4FFromccc4B(ccc4(106,254,255,255));  
	//ccColor4F bgColor = [self randomBlueColor];
	
    CGSize winSize = [CCDirector sharedDirector].winSize;
	_backGround = [self spriteWithColor:bgColor textureSize:512 withNoise:@"noise9.png" withGradientAlpha:0.4f];
	//_backGround = [self spriteWithColor:bgColor textureSize:512 withNoise:@"noise1.png" withGradientAlpha:0.8f];
    _backGround.position = ccp(_backGround.contentSize.width/2, _backGround.contentSize.height/2); 
	ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
	[_backGround.texture setTexParameters:&tp];
    [self addChild:_backGround z:-1];
	 */
	CGSize winSize = [CCDirector sharedDirector].winSize;
	_backGround = [CCSprite spriteWithFile:_level.backgroundImage];
	_backGround.position = _player.position;
//	[_backGroundNode addChild:_backGround z:-2 parallaxRatio:ccp(0.01,0) positionOffset:ccp(_backGround.contentSize.width/2, winSize.height/2)];
	
//	_backGround2 = [CCSprite spriteWithFile:@"bg2.png"];
//	[_backGroundNode addChild:_backGround2 z:-2 parallaxRatio:ccp(0.01,0) positionOffset:ccp(_backGround.position.x + _backGround.contentSize.width/2 + _backGround2.contentSize.width/2 - _backGroundNode.position.x * 0.01 -2,
//																							winSize.height/2)];

//	_backGround3 = [CCSprite spriteWithFile:@"bg3.png"];
//	[_backGroundNode addChild:_backGround3 z:-2 parallaxRatio:ccp(0.01,0) positionOffset:ccp(_backGround2.position.x + _backGround2.contentSize.width/2 + _backGround3.contentSize.width/2 - _backGroundNode.position.x * 0.01 - 2,
//																							winSize.height/2)];
	[self addChild:_backGround z:-1 tag:1];
}



#pragma mark particles
-(void) generateParticle:(int)type{
	_emitter = [CCParticleSystemQuad particleWithFile:@"fallingDown.plist"];
	[_tree  addChild:_emitter z:-1 tag:100];
	_emitter.scale = 0.3;
}


-(void) removeOutOfScreenPoints{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	for (Points* point in _points){
		if (point.sprite.position.x + point.sprite.contentSize.width/2 * point.sprite.scale < _player.position.x - screenSize.width/2){
				[self movePointToNewPosition:point];
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

-(void) removeOutOfScreenPredators{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	for (Predator* predator in _predators){
		if (predator.position.x + predator.contentSize.width/2 *predator.scale < _player.position.x - screenSize.width/2){
			[self movePredatorToNewPosition:predator];
		}else if (predator.position.x - predator.contentSize.width/2 *predator.scale > _player.position.x + screenSize.width/2){
			//revive
			predator.stamina = 800;
			predator.life = _maxPredatorLife;
		}
	}
}

-(void) removeOutOfScreenItems{
	[self removeOutOfScreenSpore];
	[self removeOutOfScreenAtka];
	[self removeOutOfScreenPoints];
	[self removeOutOfScreenCombos];
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
		if (rndSpore <= _fireBallChance && _sporeOutOfScreen == YES){
			_fireBall.sprite.position =  ccp(_player.position.x + screenSize.width/2 + screenSize.width/4, 
											 _slowestBoid.position.y );
			_sporeOutOfScreen = NO;
		}
	}
	
    float rndAtka = randRange(0, 1);
	if (_level.trapAvailable){
		if (rndAtka <= _atkaChance && _atkaOutOfScreen == YES){
			_atka.sprite.position =  ccp(_player.position.x + screenSize.width, 
											 rnd * screenSize.height/6 );
            _atkaOutOfScreen = NO;
		}
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
				
        if (change == 1){
            if (_normalSpeed.x <= 4.0){
                _normalSpeed.x += 0.1;
                _sickSpeed.x += 0.05;
                _boostSpeed.x += 0.2;
                
                if (_normalSpeed.x > 2.0f && _normalSpeed.x < 3.0f){
                    _level.difficulty = NORMAL;
                }else if (_normalSpeed.x > 3.0f){
                    _level.difficulty = HARD;
                }
                
                //	if (_illnessTimeLeft > 0 || _boostTimeLeft > 0){
                //		_playerAcceleration.x += 0.05;
                //	}else {
                _playerAcceleration.x += 0.1;
                //	}
            }

            //increase the boid speed, if it is not at the maximum
            if (_boidCurrentSpeed < 5.0f){
                _boidCurrentSpeed+=0.1;
                for (Boid* bee in _bees){
                    [bee setSpeedMax:_boidCurrentSpeed  withRandomRangeOf:0.2f andSteeringForceMax:1.8f * 1.5f withRandomRangeOf:0.25f];
                    bee.startMaxSpeed = _boidCurrentSpeed;
                }
                changeWasEnough = YES;
            }
        }
        if(change == 2 || changeWasEnough == NO){
            //increase the predatorSpeed if it is not at the maximum
            if (_minPredatorDistance > screenSize.width/3 ){
                _minPredatorDistance -= 10;
                changeWasEnough = YES;
            }
        }
        if (change ==3  || changeWasEnough == NO){
            if (_predatorCurrentSpeed < 4.0){
                _predatorCurrentSpeed += 0.05;
                for (Predator* predator in _predators){
                    [predator setSpeedMax:_predatorCurrentSpeed andSteeringForceMax:1.0f];     
                }
                changeWasEnough = YES;
            }
        }
        if (change == 4  || changeWasEnough == NO){
            if (_currentDifficulty > 10){
                //atka time
                if (_atkaChance < 0.3){
                    _atkaChance += 0.05;
                    changeWasEnough = YES;
                }
            }else {
                // increase player difficulty
                if (_normalSpeed.x <= 4.0){
                    _normalSpeed.x += 0.1;
                    _sickSpeed.x += 0.05;
                    _boostSpeed.x += 0.2;
                    
                    if (_normalSpeed.x > 2.0f && _normalSpeed.x < 3.0f){
                        _level.difficulty = NORMAL;
                    }else if (_normalSpeed.x > 3.0f){
                        _level.difficulty = HARD;
                    }
                    
                    //	if (_illnessTimeLeft > 0 || _boostTimeLeft > 0){
                    //		_playerAcceleration.x += 0.05;
                    //	}else {
                    _playerAcceleration.x += 0.1;
                    //	}
                }
                
                //increase the boid speed, if it is not at the maximum
                if (_boidCurrentSpeed < 5.0f){
                    _boidCurrentSpeed+=0.1;
                    for (Boid* bee in _bees){
                        [bee setSpeedMax:_boidCurrentSpeed  withRandomRangeOf:0.2f andSteeringForceMax:1.8f * 1.5f withRandomRangeOf:0.25f];
                        bee.startMaxSpeed = _boidCurrentSpeed;
                    }
                    changeWasEnough = YES;
                }
            }
        }
        if (change == 5  || changeWasEnough == NO){
            if (_currentDifficulty > 20){
                //spore time
                if (_fireBallChance < 0.3){
                    _fireBallChance +=0.05;
                    changeWasEnough = YES;
                }
            }else  {
                if (_normalSpeed.x <= 4.0){
                    _normalSpeed.x += 0.1;
                    _sickSpeed.x += 0.05;
                    _boostSpeed.x += 0.2;
                    
                    if (_normalSpeed.x > 2.0f && _normalSpeed.x < 3.0f){
                        _level.difficulty = NORMAL;
                    }else if (_normalSpeed.x > 3.0f){
                        _level.difficulty = HARD;
                    }
                    
                    //	if (_illnessTimeLeft > 0 || _boostTimeLeft > 0){
                    //		_playerAcceleration.x += 0.05;
                    //	}else {
                    _playerAcceleration.x += 0.1;
                    //	}
                }
                
                //increase the boid speed, if it is not at the maximum
                if (_boidCurrentSpeed < 5.0f){
                    _boidCurrentSpeed+=0.1;
                    for (Boid* bee in _bees){
                        [bee setSpeedMax:_boidCurrentSpeed  withRandomRangeOf:0.2f andSteeringForceMax:1.8f * 1.5f withRandomRangeOf:0.25f];
                        bee.startMaxSpeed = _boidCurrentSpeed;
                    }
                }
            }
        }
		
		//increase the chance of spore if it is not at the maximum
		
		//increase the chance of atka if it is not at the maximum
		
		//decrease the distance between the predators if it is not at the minimum
		
		
	}
}


-(void) updateLabels{
	_backGround.position = ccpAdd(_backGround.position, _playerAcceleration);
	_pauseButton.position = ccp(_pauseButton.position.x + _playerAcceleration.x, _pauseButton.position.y);	
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
	[self addChild:_pauseMenu z:100 tag:100];	
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
	for (Predator* predator in _predators){
		if ([self isOnScreen:predator]){
			CCAction* actionScaleIn = [CCScaleTo actionWithDuration:0.3f scale:1.0];
			CCAction* actionScaleDone = [CCCallFuncN actionWithTarget:self 
															 selector:@selector(actionMoveFinished:)];
			CCSprite* deadSprite = [CCSprite spriteWithSpriteFrameName:@"beeDies.png"];
			deadSprite.position = predator.position;
			deadSprite.scale = 0.1;
			[deadSprite runAction:[CCSequence actions:actionScaleIn, actionScaleDone, nil]];
			[_batchNode addChild:deadSprite z:300 tag:400];
			[_deadPredators addObject:predator];
		}
	} 
}


-(void) speedEffect{
	if (_boostTimeLeft == 0){
		for (Boid* bee in _bees){
			[bee boost:1.5 withForce:1.8];
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
			[bee boost:0.5 withForce:0.7];
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
	}
	//clear the items
	[_alchemy clearItems];
	[self clearItems];
	
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

-(CCSprite*)createGoalSprite:(CCSprite*) sprite forGoal:(int)goal{
	if (goal == RED_SLOT){
		sprite = [CCSprite spriteWithSpriteFrameName:@"redFlower.png"];
	}else if (goal == BLUE_SLOT) {
		sprite = [CCSprite spriteWithSpriteFrameName:@"blueFlower.png"];
	}else if (goal == YELLOW_SLOT) {
		sprite = [CCSprite spriteWithSpriteFrameName:@"yellowFlower.png"];
	}
	return sprite;
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
	
	//check if it collides with a combo 
	for(ComboFinisher* comboFinisher in _comboFinishers){
		if (CGRectIntersectsRect(point.sprite.boundingBox, comboFinisher.sprite.boundingBox)){
			_lastPointLocation = comboFinisher.sprite.position;
			[self movePointToNewPosition:point];
		}
	}
			
	_lastPointLocation = point.sprite.position;
	point.taken = YES;
}

-(void) movePredatorToNewPosition:(Predator*) predator{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	float rnd = randRange(1, 4);
	if (_lastPredatorLocation.x  < _player.position.x + screenSize.width/2){
		_lastPredatorLocation = ccp(_player.position.x + screenSize.width/2, 0);
	}
    
	[predator setPos:ccp(_lastPredatorLocation.x + _minPredatorDistance,rnd * screenSize.height/5 )];	
	_lastPredatorLocation = predator.position;
	predator.stamina = 800;
	predator.life = _maxPredatorLife;
}

-(void) moveToCemetery:(Boid *)sprite{	
	sprite.position = ccp(_player.position.x - 500, _player.position.y-500);
	[_cemeteryBees addObject:sprite];
	[_bees removeObject:sprite];
	[sprite clearEffects];
}

-(void) removeDeadItems{
	_removeRunning = YES;
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	for (Points* point in _takenPoints){
		PointTaken* actionMoveUp = [PointTaken actionWithDuration:0.4 moveTo:ccp(point.sprite.position.x - _playerAcceleration.x * 5,
																				 point.sprite.position.y + point.sprite.contentSize.height * point.sprite.scale)];
		CCAction* actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(actionMoveFinished:)];
		CCSprite* deadSprite = nil;
		bool goodForCombo = [self addItemValue:point.type];
		if (!goodForCombo){
            [_alchemy clearItems];
            [self clearItems];
            [self clearGoals];
            _bonusCount = 1;
            [self displayNoBonus];				
            [self generateGoals];
		}

		if (point.type == ATTACK_BOOST){
			if (goodForCombo){
				[self.hudLayer addItem:@"redFlower.png"];
				[_alchemy addItem:RED_SLOT];
			}
			deadSprite = [CCSprite spriteWithSpriteFrameName:@"redFlower.png"];
		}else if (point.type == GOLD){
			if (goodForCombo){
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
		}else if (point.type >= BOMB_SLOT){
			NSLog(@"combofinisher");
			self.comboFinisher = (ComboFinisher*) point;
		}
		
		[_batchNode addChild:deadSprite z:300 tag:300];
		deadSprite.position = point.sprite.position;
		deadSprite.scale = 0.1;
		[deadSprite runAction:[CCSequence actions:actionMoveUp, actionMoveDone, nil]];

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
	
	for (Predator* predator in _deadPredators){
		if ([self isOnScreen:predator]){
			CCAction* actionScaleIn = [CCScaleTo actionWithDuration:0.3f scale:1.3];
			CCAction* actionScaleDone = [CCCallFuncN actionWithTarget:self 
															 selector:@selector(actionMoveFinished:)];
			CCSprite* deadSprite = [CCSprite spriteWithSpriteFrameName:@"beeDies.png"];
			deadSprite.position = predator.position;
			deadSprite.scale = 0.6;
			[deadSprite runAction:[CCSequence actions:actionScaleIn, actionScaleDone, nil]];	
			[_batchNode addChild:deadSprite z:299 tag:predator.tag-1];
		}
		[self movePredatorToNewPosition:predator];
	}
	[_deadPredators removeAllObjects];
	_removeRunning = NO;
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

-(void)detectBox2DCollisions{
//	std::vector<b2Body *>toDestroy; 
	std::vector<MyContact>::iterator pos;
	
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
					if (predator.life > 0 ){
						[self playDeadBeeSound];
						[_deadBees addObject:boid];
					//	toDestroy.push_back(bodyA);
						[predator gotHit:boid.damage];
						//if it is dead, do not iterate over this
						if (predator.life <= 0){
							[_deadPredators addObject:predator];
					//		toDestroy.push_back(bodyB);
						}
					}
				}
			}else if ([bodyB->GetUserData() isKindOfClass:[Boid class]] && [bodyA->GetUserData() isKindOfClass:[Predator class]] ){
				Boid *boid = (Boid *) bodyB->GetUserData();
				if ([bodyB->GetUserData() isKindOfClass:[Predator class]] == NO){
					Predator *predator = (Predator *) bodyA->GetUserData();
					//if it is dead already dont do anything with it
					if (predator.life > 0){
						[self playDeadBeeSound];
						[_deadBees addObject:boid];
			//			toDestroy.push_back(bodyB);
						[predator gotHit:boid.damage];
						//if it is dead, do not iterate over this
						if (predator.life <= 0){
							[_deadPredators addObject:predator];
							//toDestroy.push_back(bodyA);
						}
					}
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
                    _pointsGathered += point.value * _bonusCount;
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
			else if ([bodyA->GetUserData() isKindOfClass:[Predator class]] && [bodyB->GetUserData() isKindOfClass:[Spore class]]) {
				Predator *predator = (Predator *) bodyA->GetUserData();
				if ([self isOnScreen:predator]){
					[_deadPredators addObject:predator];
				}
			//	toDestroy.push_back(bodyA);
			}
			else if ([bodyB->GetUserData() isKindOfClass:[Predator class]] && [bodyA->GetUserData() isKindOfClass:[Spore class]]) {
				Predator *predator = (Predator *) bodyB->GetUserData();
				if ([self isOnScreen:predator]){
					[_deadPredators addObject:predator];
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
	_currentDifficulty = 1;
	_bonusCount = 1;
    _fireBallChance = 0;
    _atkaChance = 0;
	[self unschedule:@selector(loadingTextures)];
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	[[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:NO];
	self.isTouchEnabled = YES;
	
	_batchNode = [CCSpriteBatchNode batchNodeWithFile:@"beeSprites2.png"]; // 1
	[self addChild:_batchNode z:500 tag:500]; // 2
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"beeSprites2.plist"];

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
	_sporeOutOfScreen = YES;
	
	//box2d end
	_maxPredatorLife = 1;
    _minPredatorDistance =  screenSize.width * 1.25;
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
	_fireBallSpeed =  -1;
	_playerAcceleration = _normalSpeed;
	_pointsGathered = 0;
	_boostTimeLeft = 0;
	_lastPointLocation = ccp(screenSize.width, 0);
	_lastPredatorLocation = ccp(screenSize.width, 0);
	_lastComboFinisher = ccp(screenSize.width, 0);
	_distanceTravelled = 0;
	
	_forests = [[NSMutableArray alloc] init];
	
	_totalTimeElapsed = 0;
	
	_points = [[[NSMutableArray alloc] init]retain];
	_takenPoints = [[[NSMutableArray alloc] init]retain];
	_takenCombos = [[[NSMutableArray alloc] init] retain];
	_bees = [[[NSMutableArray alloc] init] retain];
	_deadBees = [[[NSMutableArray alloc] init] retain];
	_predators = [[[NSMutableArray alloc] init]retain];
	_deadPredators = [[[NSMutableArray alloc] init]retain];
	_cemeteryBees = [[[NSMutableArray alloc] init] retain];
	_particleNode = [[CCNode alloc] init];
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
	
	if (_level.trapAvailable){
		_atka = [[[Atka alloc] initForNode:_batchNode] retain];
		[_atka createBox2dBodyDefinitions:_world];
		_atka.sprite.position =  ccp(_player.position.x + screenSize.width/2 + screenSize.width * 20, 
									 randomDist * screenSize.height/5 );
	}
	
	if (_level.sporeAvailable){
		_fireBall = [[[Spore alloc] initForNode:_batchNode] retain];
		_fireBall.sprite.position = ccpAdd(_player.position, ccp(screenSize.width * randomDist, screenSize.height/2 * randomY));
		[_fireBall createBox2dBodyDefinitions:_world];
		//[_batchNode addChild:_fireBall.sprite z:100 tag:100];
	}
	
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
		[boid setPos: ccp( CCRANDOM_0_1() * screenSize.width/3,  screenSize.height / 2)];
		// Color
		[boid setOpacity:220];
		[boid createBox2dBodyDefinitions:_world];
		[_batchNode addChild:boid z:100 tag:1];
		[boid update];
	}
	for (int i = 0; i < 10 ; i++){
		[self generatePredators];
	}
	
	for (int i = 0; i < 12; i++) {
		[self generateNextPoint: (i % 3)+1];
	}
	
	if (_level.distanceToGoal < 0){
		self.comboFinishers = [[NSMutableArray alloc] init];
		for (int i = 0; i < 3; i++){
			[self generateNextFinisher:i];
		}
	}
	
	//init the array for clouds
	_clouds = [[NSMutableArray alloc] init];
	//init the clouds
	CCSprite* bgCloud;
	for (int i= 0; i <6; i++){
		bgCloud = [CCSprite spriteWithSpriteFrameName:@"cloudsmall.png"];
		bgCloud.scale = randRange(0.4, 0.8);
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
	
	
	_tree = [CCSprite spriteWithSpriteFrameName:@"tree1.png"];
	[_backGroundNode addChild:_tree z:59 parallaxRatio:ccp(0.05, 0.0) positionOffset:ccp(screenSize.width * 3/2, _tree.contentSize.height/2 *_tree.scale )];
	
	_tree2 = [CCSprite spriteWithSpriteFrameName:@"tree2.png"];
	[_backGroundNode addChild:_tree2 z:59 parallaxRatio:ccp(0.05, 0.0) positionOffset:ccp(screenSize.width * 3, _tree2.contentSize.height/2 *_tree2.scale)];
	
	_tree3 = _tree = [CCSprite spriteWithSpriteFrameName:@"tree1.png"];
	[_backGroundNode addChild:_tree z:59 parallaxRatio:ccp(0.05, 0.0) positionOffset:ccp(screenSize.width/2, _tree.contentSize.height/2 *_tree.scale )];
	
	[self initLabels];
	
	[self schedule:@selector(loadingTerrain)];
}




-(void) loadingTerrain{
	[self unschedule:@selector(loadingTerrain)];
	
	_hills1 = [CCSprite spriteWithFile:@"hills1.png"];
	_hills2 = [CCSprite spriteWithFile:@"hills1.png"];
	
	[_backGroundNode addChild:_hills1 z:61 parallaxRatio:ccp(0.15, 0.0) positionOffset:ccp(_hills1.contentSize.width/2 - 30, _hills1.contentSize.height/2)];
    [_backGroundNode addChild:_hills2 z:60 parallaxRatio:ccp(0.15, 0.0) positionOffset:ccp(_hills1.contentSize.width + _hills1.contentSize.width/2 -60, _hills2.contentSize.height/2) ];

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

-(id) initWithLayers:(HUDLayer *)hudLayer pause:(PauseLayer *)pauseLayer{
	if ((self = [super init])){
		self.hudLayer = hudLayer;
        self.pauseLayer = pauseLayer;
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
	_world->Step(dt, 10, 10);
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
		}else{
            CCSprite *sprite = (CCSprite *)b->GetUserData();
			b2Vec2 b2Position = b2Vec2(sprite.position.x/PTM_RATIO,
									   sprite.position.y/PTM_RATIO);
			float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(sprite.rotation);
            b->SetTransform(b2Position, b2Angle);
        }
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

-(void) respawnForest{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	for (CCSprite *background in _forests) {
		if ([_backGroundNode convertToWorldSpace:background.position].x < -background.contentSize.width * background.scale) {
			[_backGroundNode incrementOffset:ccp(background.contentSize.width * background.scale *  [_forests count],0) forChild:background];
		}
	}
	
	if ([_backGroundNode convertToWorldSpace:_tree.position].x < -_tree.contentSize.width/2 * _tree.scale) {
		[_backGroundNode incrementOffset:ccp(_tree.contentSize.width * _tree.scale + screenSize.width  ,0) forChild:_tree];
		[_backGroundNode convertToWorldSpace:_tree.position];
	}
	
	if ([_backGroundNode convertToWorldSpace:_tree2.position].x < -_tree2.contentSize.width/2 * _tree2.scale) {
		[_backGroundNode incrementOffset:ccp(_tree2.contentSize.width * _tree2.scale + screenSize.width  ,0) forChild:_tree2];
		[_backGroundNode convertToWorldSpace:_tree2.position];
	}
	
	if ([_backGroundNode convertToWorldSpace:_tree3.position].x < -_tree3.contentSize.width/2 * _tree3.scale) {
		[_backGroundNode incrementOffset:ccp(_tree3.contentSize.width * _tree3.scale + screenSize.width  ,0) forChild:_tree3];
		[_backGroundNode convertToWorldSpace:_tree3.position];
	}
	
	if ([_backGroundNode convertToWorldSpace:_hills1.position].x < -_hills1.contentSize.width/2 * _hills1.scale) {
		[_backGroundNode incrementOffset:ccp(_hills1.contentSize.width * _hills1.scale +  _hills2.contentSize.width * _hills1.scale - 60,0) forChild:_hills1];
		[_backGroundNode convertToWorldSpace:_hills1.position]; 
	}
	
	if ([_backGroundNode convertToWorldSpace:_hills2.position].x < -_hills2.contentSize.width/2 * _hills2.scale) {
		[_backGroundNode incrementOffset:ccp(_hills1.contentSize.width * _hills1.scale +  _hills2.contentSize.width * _hills2.scale - 60 ,0) forChild:_hills2];
		[_backGroundNode convertToWorldSpace:_hills2.position];
	}
}

/*
-(void) moveSun:(ccTime)dt{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	_sunSprite.position = ccpAdd(_sunSprite.position, ccpMult(_sunAcceleration, dt));
	_sunAcceleration = ccp(_playerAcceleration.x, _playerAcceleration.x/50);
	if (_sunSprite.position.y + _sunSprite.contentSize.height/2 >= screenSize.height){
		//time to move downwards 
		_sunAcceleration = ccp(_sunAcceleration.x, -_sunAcceleration.y);
	}
}
*/



-(void)selectTarget:(Predator*)predator{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	/*
	switch (predator.type) {
		case AGGRESSIVE:
			predator.target = _slowestBoid.position;
			break;
		case LAZY:
			predator.target = _slowestBoid.position;
			break;
			
		case DUMB:
			predator.target = _slowestBoid.position;
			break;
			
		case PASSIVE:
			predator.target = ccp(_player.position.x - screenSize.width * 2, screenSize.height * CCRANDOM_0_1() );
			break;

		default:
			break;
	}	*/
	predator.target = _slowestBoid.position;
}


-(void)generatePredators{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	Predator* predator = [Predator spriteWithSpriteFrameName:@"fly.png"];
	predator.scale = 0.6;
	int pType = arc4random() % MAX_PREDATOR_TYPE;
	
	predator.type = pType;

	predator.doRotation = YES; 
	
	float predatorSpeed = _level.predatorSpeed - (float)_level.difficulty;
	
	_predatorCurrentSpeed = predatorSpeed;
	
	[predator setSpeedMax:predatorSpeed withRandomRangeOf:0.2f andSteeringForceMax:1 withRandomRangeOf:0.15f];
	[predator setWanderingRadius: 16.0f lookAheadDistance: 40.0f andMaxTurningAngle:0.2f];
	[predator setEdgeBehavior: EDGE_NONE];
	//[predator setPos: ccp( _player.position.x + screenSize.width/2 + CCRANDOM_0_1() * screenSize.width/3,  screenSize.height * CCRANDOM_0_1())];
	// Color
	[predator setOpacity:250];
	[_batchNode addChild:predator z:101 tag:1];
	
	predator.life = _maxPredatorLife;
	predator.stamina = 800;
	[_predators addObject:predator];
	[self movePredatorToNewPosition:predator];
	[predator createBox2dBodyDefinitions:_world];
}


-(void)updatePredators:(ccTime)dt{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	for (Predator* predator in _predators){
		if ([self isOnScreen:predator]){
			predator.illnessTime -= dt;
			[self selectTarget:predator];
			[predator update:dt];
		}
	}
}
	
-(void) gameOver{
	[self unschedule:@selector(update:)];
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	CCSprite* gameOverSprite = [CCSprite spriteWithFile:@"gameOverOverlay.png"];
	gameOverSprite.position = _player.position;
	gameOverSprite.scaleX = 1.8f;
	gameOverSprite.opacity = 0;
	[self addChild:gameOverSprite z:599 tag:299];
	[gameOverSprite runAction:[CCFadeIn actionWithDuration:0.2]];
	
	CCLabelTTF* gameOverLabel = [[CCLabelTTF alloc] initWithString:@"Game Over" fontName:@"Marker Felt" fontSize:32];
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
		bee.leftEdgePosition = ccp(_player.position.x - screenSize.width/2, _player.position.y);
		[self beeDefaultMovement:bee withDt:dt];
		if (!CGPointEqualToPoint(_currentTouch , CGPointZero)){
			[bee seek:_currentTouch usingMultiplier:0.15f];
		}else{
			[bee seek:_player.position usingMultiplier:0.15f];
		}
		[bee update];
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

-(void) updatePoints{
	for (Points* point in _points){
		if (![self isOnScreen:point.sprite]){
			point.taken = NO;
		}
	}
	for (ComboFinisher* point in _comboFinishers){
		if (![self isOnScreen:point.sprite]){
			point.taken = NO;
		}
	}
}

-(void) displayNoBonus{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	//display an item for no bonus
	CCLabelTTF* noBonus = [[[CCLabelTTF alloc] initWithString:@"Failed" fontName:@"Marker Felt" fontSize:32] autorelease];
	noBonus.position = ccp(_player.position.x , _player.position.y - screenSize.height);

	CCAction* moveInABit = [CCMoveTo actionWithDuration:0.2 position:ccp(_player.position.x , _player.position.y - screenSize.height/4)];
	CCAction* fadeOut = [CCFadeOut actionWithDuration:1];
	[self addChild:noBonus z:500 tag:500];
	CCAction* bonusActionDone = [CCCallFuncN actionWithTarget:self 
													 selector:@selector(actionBonusFinished:)];
	[noBonus runAction:[CCSequence actions: moveInABit, fadeOut, bonusActionDone, nil]];					   
}

-(void) displayHighScore{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	//display an item for no bonus
	CCLabelTTF* noBonus = [[[CCLabelTTF alloc] initWithString:@"High Score" fontName:@"Marker Felt" fontSize:32] autorelease];
	noBonus.position = ccp(_player.position.x , _player.position.y - screenSize.height);
	
	CCAction* moveInABit = [CCMoveTo actionWithDuration:0.2 position:ccp(_player.position.x , _player.position.y - screenSize.height/4)];
	CCAction* fadeOut = [CCFadeOut actionWithDuration:1];
	[self addChild:noBonus z:500 tag:500];
	CCAction* bonusActionDone = [CCCallFuncN actionWithTarget:self 
													 selector:@selector(actionBonusFinished:)];
	[noBonus runAction:[CCSequence actions: moveInABit, fadeOut, bonusActionDone, nil]];					   
}

	
-(void) displayBonus{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	//display an item for no bonus
	NSString* tmpStr = [[[NSString alloc] initWithFormat:@"%ix Bonus", _bonusCount] autorelease];
	CCLabelTTF* noBonus = [[[CCLabelTTF alloc] initWithString:tmpStr fontName:@"Marker Felt" fontSize:32] autorelease];
	noBonus.position = ccp(_player.position.x , _player.position.y - screenSize.height);
	CCAction* bonusActionDone = [CCCallFuncN actionWithTarget:self 
													 selector:@selector(actionBonusFinished:)];

	CCAction* moveInABit = [CCMoveTo actionWithDuration:0.2 position:ccp(_player.position.x , _player.position.y - screenSize.height/4)];
	CCAction* fadeOut = [CCFadeOut actionWithDuration:1];
	[self addChild:noBonus z:500 tag:500];
	[noBonus runAction:[CCSequence actions: moveInABit, fadeOut, bonusActionDone, nil]];					   
}


-(void)updateSounds:(ccTime)dt{
	if (_auEffectLeft > 0){
		_auEffectLeft-=dt;
		if (_auEffectLeft < 0){
			_auEffectLeft = 0;
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
				if (_removeRunning == NO){
					[self removeDeadItems];
				}
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
					_fireBall.sprite.position = ccpAdd(_fireBall.sprite.position, ccp(_fireBallSpeed,0));
				}
			
				//parallaxNode
				CGPoint backgroundScrollVel = ccp(-10, 0);
				_backGroundNode.position = ccpAdd(_backGroundNode.position, backgroundScrollVel);
				//ccpMult(backgroundScrollVel, dt));
				CGSize screenSize = [[CCDirector sharedDirector] winSize];
				/*
				if (((_player.position.y + _player.contentSize.height/2 >= screenSize.height) && _playerAcceleration.y > 0) ||
					((_player.position.y - _player.contentSize.height/2 <= 0) && _playerAcceleration.y < 0)){
						_playerAcceleration = ccp(_playerAcceleration.x, 0);
				}*/
				
				_player.position = ccpAdd(_player.position, _playerAcceleration);

				[self updateLabels];
				[self setViewpointCenter:_player.position];
				for (Boid* boid in _bees){
					if (_slowestBoid == nil){
						_slowestBoid = boid;
					}else {
						if (boid.maxSpeed < _slowestBoid.maxSpeed){
							_slowestBoid = boid;
						}
					}
				}
				
				[self removeOutOfScreenPredators];

				[self updatePredators:dt];
				[self beeMovement:dt];
				[self removeOutOfScreenItems];
				//update terrain, tell it how far we have proceeded
				//[_terrain setOffsetX:_playerAcceleration.x];
				//respawn the clouds if needed
				[self respawnCloud];
				[self respawnForest];
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
		[self schedule: @selector(update:)];
		[self generateGoals];
	}else if (_gameIsReady && _gameStarted){
		self.currentTouch = [self convertTouchToNodeSpace: touch];
		self.currentTouch = ccp(self.currentTouch.x - 10, self.currentTouch.y);
		if (_isGameOver){
			if (_newHighScore && _distanceToGoal < 0){
				[self saveLevelPerformance];
			}
			[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.0 scene:[MainMenuScene scene] withColor:ccBLACK]];
		}else if (_isLevelDone) {
			[self saveLevelPerformance];
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
	//self.currentTouch = CGPointZero;
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

	[_bees release];
	_bees = nil;
	[_predators release];
	_predators = nil;
	[_clouds release];
	_clouds = nil;
	[_forests release];
	_forests = nil;
	[_level release];
	_level = nil;
	_fireBall = nil;
	_atka = nil;
	[_alchemy release];
	_alchemy = nil;
	
	_tree = nil;
	_tree2 = nil;
	_batchNode = nil;

	_particleNode = nil;
	_emitter = nil;
	_slowestBoid = nil;
	_terrain = nil;

	_backGround = nil;
	_backGround2 = nil;
	_backGround3 = nil;
	_hills1 = nil;
	_hills2 = nil;
	[_cemeteryBees release];
	_cemeteryBees = nil;
	[_comboFinishers release];
	_comboFinishers = nil;
	[_comboFinisher release];
}	


@end




