//
//  HelloWorldScene.mm
//  bees
//
//  Created by macbook white on 7/18/11.
//  Copyright nincs 2011. All rights reserved.
//


// Import the interfaces
#import "CaveScene.h"
#import "LevelManager.h"

#define rad2Deg 57.2957795

#define leftEdge 0.0f
#define bottomEdge 0.0f
#define topEdge 320.0f
#define rightEdge 480.0f

#define IGNORE 1.0f

#define kFilteringFactor 0.05


@implementation CaveScene
@synthesize  currentTouch = _currentTouch;
@synthesize paused = _paused;
@synthesize backgrounds = _backgrounds;
@synthesize level = _level;
@synthesize comboFinisher = _comboFinisher;
@synthesize comboFinishers = _comboFinishers;


+(id)scene{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	CaveScene *layer = [CaveScene node];
	
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
	_pausedMenu.opacity =0;
	[_pausedMenu runAction:[CCFadeIn actionWithDuration:0.3]];
}

- (void)genBackground {
	CGSize winSize = [CCDirector sharedDirector].winSize;
	_backGround = [CCSprite spriteWithFile:_level.backgroundImage];
	_backGround.position = _player.position;
	[self addChild:_backGround z:-1 tag:1];
}



#pragma mark particles
-(void) generateParticle:(int)type{
	_emitter = [CCParticleSystemQuad particleWithFile:@"fallingDown.plist"];
	[_tree  addChild:_emitter z:-1 tag:100];
	_emitter.scale = 0.3;
}

-(void) addRockHitEmitter:(CGPoint)location{
	_emitter = [CCParticleSystemQuad particleWithFile:@"rockHit.plist"];
	_emitter.position = location;
	_emitter.scale = 0.5;
	[self addChild:_emitter z:600 tag:600];
	_emitter.autoRemoveOnFinish = YES;
}

-(void) addHighScoreEmitter{
	_emitter = [CCParticleSystemQuad particleWithFile:@"highscoreParticle.plist"];
	_emitter.position = ccp(_player.position.x, 0);
	_emitter.scale = 0.5;
	[self addChild:_emitter z:600 tag:600];
	_emitter.autoRemoveOnFinish = YES;
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
	std::vector<b2Body *>toDestroy; 
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	for (Points* point in _points){
		if (point.sprite.position.x + point.sprite.contentSize.width/2 * point.sprite.scale < _player.position.x - screenSize.width/2){
			[self movePointToNewPosition:point];
		}
	}
}

-(void) removeOutOfScreenBats{
	std::vector<b2Body *>toDestroy; 
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	for (Bat* bat in _bats){
		if (bat.sprite.position.x + bat.sprite.contentSize.width/2 *bat.sprite.scale < _player.position.x - screenSize.width/2){
			[self moveBatToNewPosition:bat];
		}else if (bat.sprite.position.x - bat.sprite.contentSize.width/2 *bat.sprite.scale > _player.position.x + screenSize.width/2){
			//revive
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

-(void) checkRockBatCollision:(Rock*)rock{
	for(Bat* bat in _bats){
		if (CGRectIntersectsRect(rock.sprite.boundingBox, bat.sprite.boundingBox)){
			rock.sprite.position = ccpAdd(ccp(_minRockDistance,0), rock.sprite.position);
			[self checkRockBatCollision:rock];
		}
	}
}

-(void) checkBatRockCollision:(Bat*)bat{
	for (Rock* rock in _topRocks){
		if (CGRectIntersectsRect(rock.sprite.boundingBox, bat.sprite.boundingBox)){
			bat.sprite.position = ccpAdd(_minBatDistance, bat.sprite.position);
			[self checkBatRockCollision:bat];
		}
	}
}


-(void)generateBats{
	float rnd = 1;
	if (_level.difficulty == EASY){
		rnd = randRange(3, 5);
	}else if (_level.difficulty == NORMAL) {
		rnd = randRange(2, 4);
	}else if (_level.difficulty == HARD) {
		rnd = randRange(1, 3);
	}
	
	_lastBatPosition = ccpAdd(_lastBatPosition , ccp(rnd * _minBatDistance.x, 0));
	//check if it is colliding with a toprock 
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	Bat* bat = [[Bat alloc] initForPosition:_lastBatPosition forNode:_batchNode withTime:1 + _level.difficulty];
	[self checkBatRockCollision:bat];
	bat.timeLeftForGuano = 0;
	[bat.sprite setOpacity:250];
	[_bats addObject:bat];
	bat.sprite.scale = 0.7;
	[bat createBox2dBodyDefinitions:_world];
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
	point.sprite.position = ccp(_lastComboFinisher.x + _playerAcceleration.x * 60 * 5 * rnd * type + 1, 
								rndY * screenSize.height/4);
	_lastComboFinisher = point.sprite.position;
	
	[point createBox2dBodyDefinitions:_world];
	[_comboFinishers addObject:point];
	
	point.taken = NO;
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

-(void) updateLabels{
	//_resetButton.position = ccpAdd(_resetButton.position, _playerAcceleration);
	_pauseButton.position = ccp(_pauseButton.position.x + _playerAcceleration.x, _pauseButton.position.y);
	_ornament1.position = ccp(_ornament1.position.x + _playerAcceleration.x, _ornament1.position.y);
	_ornament2.position = ccp(_ornament2.position.x + _playerAcceleration.x, _ornament2.position.y);
	_ornament3.position = ccp(_ornament3.position.x + _playerAcceleration.x, _ornament3.position.y);
	
	_slot1.position = ccp(_slot1.position.x + _playerAcceleration.x, _slot1.position.y);
	_slot2.position = ccp(_slot2.position.x + _playerAcceleration.x, _slot2.position.y);
	_slot3.position = ccp(_slot3.position.x + _playerAcceleration.x, _slot3.position.y);
	
	_item1.position = _slot1.position;
	_item2.position = _slot2.position;
	_item3.position = _slot3.position;
	
	_rightOrnament.position = ccp(_rightOrnament.position.x + _playerAcceleration.x, _rightOrnament.position.y);
	_pointsSprite.position = ccp(_pointsSprite.position.x + _playerAcceleration.x, _pointsSprite.position.y);
	[_pointsLabel setString:[NSString stringWithFormat:@"%i", _pointsGathered]];
	_pointsLabel.position = _pointsSprite.position;
	
	_loadingScreen.position = ccp(_player.position.x, _loadingScreen.position.y);
	
	//goals section
	
	_goal1Slot.position = ccp(_goal1Slot.position.x + _playerAcceleration.x, _goal1Slot.position.y);
	_goal2Slot.position = ccp(_goal2Slot.position.x + _playerAcceleration.x, _goal2Slot.position.y);
	_goal3Slot.position = ccp(_goal3Slot.position.x + _playerAcceleration.x, _goal3Slot.position.y);
	if (_goal1Sprite){
		_goal1Sprite.position = _goal1Slot.position;
	}
	if (_goal2Sprite){
		_goal2Sprite.position = _goal2Slot.position;
	}
	if (_goal3Sprite){
		_goal3Sprite.position = _goal3Slot.position;
	}
	
	_distanceLeft.position = ccpAdd(_distanceLeft.position, _playerAcceleration);
	_distanceLeft.percentage = (float)_goalTimeLeft/(float)_goalTimeMax * 100;
	[_distanceLeft updateRadial];
	
//	_goalTimer.position = ccpAdd(_goalTimer.position, _playerAcceleration);
	
	/*
	[_distanceLabel setString:[NSString stringWithFormat:@"%i meters", _distanceTravelled]];
	_distanceLabel.position = ccp(_player.position.x, _distanceLabel.position.y);
		_upperOverlay.position = ccp(_upperOverlay.position.x + _playerAcceleration.x, _upperOverlay.position.y);
	if (_attackBoostSprite != nil){
		_attackBoostSprite.position = ccp(_attackBoostSprite.position.x + _playerAcceleration.x, _attackBoostSprite.position.y);
	}
	if (_evadeBoostSprite != nil){
		_evadeBoostSprite.position = ccp(_evadeBoostSprite.position.x + _playerAcceleration.x, _evadeBoostSprite.position.y);
	}*/
	_backGround.position = _player.position;
}

-(void)resetButtonTapped:(id)sender{
	[_alchemy clearItems];
	[self clearItems];
	[self clearItemValues];
}
 

-(void) initLabels{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	// _resetButton = [CCMenuItemImage itemFromNormalImage:@"avoidButton.png" selectedImage:@"avoidButton.png"
	//															  target:self selector:@selector(resetButtonTapped:)];
	
	//_resetButton.scale = 0.5;
	//CCMenu* resetMenu = [CCMenu menuWithItems:_resetButton, nil];
	//resetMenu.position = ccp(_resetButton.contentSize.width * _resetButton.scale, _resetButton.contentSize.height* _resetButton.scale);
	//[self addChild:resetMenu z:100 tag:100];
	
	_pauseButton = [CCMenuItemImage		itemFromNormalImage:@"pauseButton.png" selectedImage:@"pauseButton.png" 
												  target:self selector:@selector(switchPause:)];
	

	CCMenu* _pauseMenu = [CCMenu menuWithItems:_pauseButton, nil];
	_pauseMenu.position = ccp(screenSize.width - _pauseButton.contentSize.width * 2, _pauseButton.contentSize.height);
	[self addChild:_pauseMenu z:101 tag:100];	
	
	float ornamentWidth;
	float slotWidth;
	
	_ornament1 = [CCSprite spriteWithSpriteFrameName:@"leftOrnament.png"];
	_ornament2 = [CCSprite spriteWithSpriteFrameName:@"leftOrnament.png"];
	_ornament3 = [CCSprite spriteWithSpriteFrameName:@"leftOrnament.png"];
	_slot1 = [CCSprite spriteWithSpriteFrameName:@"emptySlot.png"];
	_slot2 = [CCSprite spriteWithSpriteFrameName:@"emptySlot.png"];
	_slot3 = [CCSprite spriteWithSpriteFrameName:@"emptySlot.png"]; 
	
	ornamentWidth = _ornament1.contentSize.width;
	slotWidth = _slot1.contentSize.width;
		
	_ornament1.position = ccp(ornamentWidth/2 * _ornament1.scale, 
							  screenSize.height - _slot1.contentSize.height * _slot1.scale);
	_slot1.position = ccp(_ornament1.position.x + ornamentWidth/2 * _ornament1.scale + slotWidth/2 * _slot1.scale,
						  screenSize.height - _slot1.contentSize.height * _slot1.scale);
	

	_ornament2.position = ccp(_ornament1.position.x + ornamentWidth * _ornament1.scale +slotWidth/2 * _slot1.scale,
							  _slot1.position.y);
	
	_slot2.position = ccp(_ornament2.position.x + ornamentWidth/2 * _ornament2.scale + slotWidth/2 * _slot2.scale, 
							_slot1.position.y);

	_ornament3.position = ccp(_ornament2.position.x + ornamentWidth * _ornament2.scale +slotWidth/2 * _slot2.scale,
							  _slot2.position.y);
	
	_slot3.position = ccp(_ornament3.position.x + ornamentWidth/2 * _ornament3.scale + slotWidth/2 * _slot3.scale, 
						  _slot1.position.y);
	
	
	[_batchNode addChild:_ornament1 z:100 tag:100];
	[_batchNode addChild:_ornament2 z:100 tag:100];
	[_batchNode addChild:_ornament3 z:100 tag:100];
	
	[_batchNode addChild:_slot1 z:100 tag:100];
	[_batchNode addChild:_slot2 z:100 tag:100];
	[_batchNode addChild:_slot3 z:100 tag:100];
	
	
	_rightOrnament = [CCSprite spriteWithSpriteFrameName:@"leftOrnament.png"];
	_rightOrnament.rotation = 180;
	_rightOrnament.position = ccp(screenSize.width - _rightOrnament.contentSize.width/2, _ornament1.position.y);
	[self addChild:_rightOrnament];
	
	_pointsSprite = [CCSprite spriteWithSpriteFrameName:@"emptySlot.png"];
//	_pointsSprite.scale = 0.5;
	_pointsSprite.position = ccp(_rightOrnament.position.x - _rightOrnament.contentSize.width/2 - _pointsSprite.contentSize.width/2 * _pointsSprite.scale,
								_rightOrnament.position.y);
	
	[self addChild:_pointsSprite z:100 tag:100];
	
	_pointsLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:12];
	_pointsLabel.position = _pointsSprite.position;
	_pointsLabel.color = ccWHITE;
	[self addChild:_pointsLabel z: 300 tag:301];
	
	//goals section	
	_goal1Slot = [CCSprite spriteWithSpriteFrameName:@"emptySlot.png"];
	_goal2Slot = [CCSprite spriteWithSpriteFrameName:@"emptySlot.png"];
	_goal3Slot = [CCSprite spriteWithSpriteFrameName:@"emptySlot.png"];
	
	_goal1Slot.scale = 0.6;
	_goal2Slot.scale = 0.6;
	_goal3Slot.scale = 0.6;
	
	_goal1Slot.position = ccp(_slot3.position.x + _slot3.contentSize.width*_slot3.scale*2, _slot3.position.y);
	_goal2Slot.position = ccp(_goal1Slot.position.x + _goal1Slot.contentSize.width * _goal1Slot.scale, _slot3.position.y);
	_goal3Slot.position = ccp(_goal2Slot.position.x + _goal2Slot.contentSize.width * _goal2Slot.scale, _slot3.position.y);
	[_batchNode addChild:_goal1Slot z:101 tag:101];
	[_batchNode addChild:_goal2Slot z:101 tag:101];
	[_batchNode addChild:_goal3Slot z:101 tag:101];
	
	_distanceLeft = [CCProgressTimer progressWithFile:@"emptySlot.png"];
	_distanceLeft.scale = 0.4;
	[_distanceLeft setType:kCCProgressTimerTypeRadialCW];
	[_distanceLeft setPercentage:0.0f];
	_distanceLeft.position = ccpAdd(_goal2Slot.position, ccp(0, _goal2Slot.contentSize.height/2 * _goal2Slot.scale + _distanceLeft.contentSize.height/2 * _distanceLeft.scale));
	[self addChild:_distanceLeft z:201 tag:500];
	
//	_goalTimer = [CCLabelBMFont labelWithString:@"0" fntFile:@"MarkerFelt.fnt"];
//	_goalTimer.position = ccp(_goal2Slot.position.x, _goal2Slot.position.y - _goal2Slot.contentSize.height * _goal2Slot.scale - _goalTimer.contentSize.height/2);
//	[self addChild:_goalTimer z:101 tag:101];
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
	std::vector<b2Body *>toDestroy; 
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
	std::vector<b2Body *>toDestroy; 
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


-(void) bombEffect{
	for (Bat* predator in _bats){
		if ([self isOnScreen:predator.sprite]){
			CCAction* actionScaleIn = [CCScaleTo actionWithDuration:0.3f scale:1.0];
			CCAction* actionScaleDone = [CCCallFuncN actionWithTarget:self 
															 selector:@selector(actionMoveFinished:)];
			CCSprite* deadSprite = [CCSprite spriteWithSpriteFrameName:@"beeDies.png"];
			deadSprite.position = predator.sprite.position;
			deadSprite.scale = 0.1;
			[deadSprite runAction:[CCSequence actions:actionScaleIn, actionScaleDone, nil]];
			[_batchNode addChild:deadSprite z:300 tag:400];
			[_deadBats addObject:predator];
		}
	} 
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
	if (_item1) {
		[_batchNode removeChild:_item1 cleanup:YES];
		_item1 = nil;
	}
	if (_item2){
		[_batchNode removeChild:_item2 cleanup:YES];
		_item2 = nil;
	}
	if (_item3){
		[_batchNode removeChild:_item3 cleanup:YES];
		 _item3 = nil;
	}
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
	[_batchNode removeChild:_goal1Sprite cleanup:YES];
	_goal1Sprite = nil;
	[_batchNode removeChild:_goal2Sprite cleanup:YES];
	_goal2Sprite = nil;
	[_batchNode removeChild:_goal3Sprite cleanup:YES];
	_goal3Sprite = nil;
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
	
	_goalTimeLeft = randRange(minTime, maxTime);
	_goalTimeMax = _goalTimeLeft;
//	int tmpTime = ceil(_goalTimeLeft);
//	[_goalTimer setString:[NSString stringWithFormat:@"%i", tmpTime]];
	
	_goal1 = ceil(randRange(0, maxNumber));
	_goal2 = ceil(randRange(0, maxNumber));
	_goal3 = ceil(randRange(0, maxNumber));
	
	_goal1Sprite = [self createGoalSprite:_goal1Sprite forGoal:_goal1];
	_goal2Sprite = [self createGoalSprite:_goal2Sprite forGoal:_goal2];
	_goal3Sprite = [self createGoalSprite:_goal3Sprite forGoal:_goal3];
	
	_goal1Sprite.scale = 0.6;
	_goal2Sprite.scale = 0.6;
	_goal3Sprite.scale = 0.6;

	_goal1Sprite.position = _goal1Slot.position;
	_goal2Sprite.position = _goal2Slot.position;
	_goal3Sprite.position = _goal3Slot.position;
	
	[_batchNode addChild:_goal1Sprite z:101 tag:101];
	[_batchNode addChild:_goal2Sprite z:101 tag:101];
	[_batchNode addChild:_goal3Sprite z:101 tag:101];
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


-(void) removeOutOfScreenCombos{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	for (ComboFinisher* point in _comboFinishers){
		if (point.sprite.position.x + point.sprite.contentSize.width/2 * point.sprite.scale < _player.position.x - screenSize.width/2){
			[self moveComboToNewPosition:point];
		}
	}
}	

-(void)addItem:(NSString*)item{
	if (_item1 == nil) {
		_item1 = [CCSprite spriteWithSpriteFrameName:item];
		_item1.position = _slot1.position;
		[_batchNode addChild:_item1 z:110 tag:100];
	}else if(_item2 == nil){
		_item2 = [CCSprite spriteWithSpriteFrameName:item];
		_item2.position = _slot2.position;
		[_batchNode addChild:_item2 z:110 tag:100];
	}else if(_item3 == nil){
		_item3 = [CCSprite spriteWithSpriteFrameName:item];
		_item3.position = _slot3.position;
		[_batchNode addChild:_item3 z:110 tag:100];
	}
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

-(void) moveBatToNewPosition:(Bat*) bat{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	float rnd = randRange(1, 4);
	if (_lastBatPosition.x  < _player.position.x + screenSize.width/2){
		_lastBatPosition = ccp(_player.position.x + screenSize.width/2, _lastBatPosition.y);
	}
	bat.sprite.position = ccp(_lastBatPosition.x + _minBatDistance.x * rnd ,_lastBatPosition.y );	
	[self checkBatRockCollision:bat];
	_lastBatPosition = bat.sprite.position;
	bat.life = 6;
}


-(void) moveToCemetery:(Boid *)sprite{
		sprite.position = ccp(-500,-500);
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
			[self clearItems];
			[_alchemy clearItems];
		}
		if (point.type == ATTACK_BOOST){
			if (goodForCombo) {
				[self addItem:@"redFlower.png"];
				[_alchemy addItem:RED_SLOT];
			}
			deadSprite = [CCSprite spriteWithSpriteFrameName:@"redFlower.png"];
		}else if (point.type == GOLD){
			if (goodForCombo) {
				[self addItem:@"yellowFlower.png"];
				[_alchemy addItem:YELLOW_SLOT];
			}
			deadSprite = [CCSprite spriteWithSpriteFrameName:@"yellowFlower.png"];
		}else if (point.type == EVADE_BOOST){
			if (goodForCombo){
				[self addItem:@"blueFlower.png"];
				[_alchemy addItem:BLUE_SLOT];
			}
			deadSprite = [CCSprite spriteWithSpriteFrameName:@"blueFlower.png"];			
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
			NSLog(@"BOMB WAS TAKEN");
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
		[_bees removeObject:boid];
		//check if it was the slowest
		if ([_slowestBoid isEqual:boid]){
			_slowestBoid = nil;
		}
	}
	[_deadBees removeAllObjects];
	
	for (Bat* bat in _deadBats){
		if ([self isOnScreen:bat.sprite]){
			CCAction* actionScaleIn = [CCScaleTo actionWithDuration:0.3f scale:1.3];
			CCAction* actionScaleDone = [CCCallFuncN actionWithTarget:self 
															 selector:@selector(actionMoveFinished:)];
			CCSprite* deadSprite = [CCSprite spriteWithSpriteFrameName:@"beeDies.png"];
			deadSprite.position = bat.sprite.position;
			deadSprite.scale = 0.6;
			[deadSprite runAction:[CCSequence actions:actionScaleIn, actionScaleDone, nil]];	
			[_batchNode addChild:deadSprite z:299 tag:100];
		}
		[self moveBatToNewPosition:bat];
	}
	[_deadBats removeAllObjects];
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
		NSLog(@"sounds on");
		[[SimpleAudioEngine sharedEngine] playEffect:@"woohooo.wav"];
	}
}


#pragma mark collision detection

-(void)detectBox2DCollisions{
//	std::vector<b2Body *>toDestroy; 
	std::vector<MyContact>::iterator pos;
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	ConfigManager* sharedManager = [ConfigManager sharedManager];
	
	for(pos = _contactListener->_contacts.begin(); 
		pos != _contactListener->_contacts.end(); ++pos) {
		MyContact contact = *pos;
		b2Body *bodyA = contact.fixtureA->GetBody();
		b2Body *bodyB = contact.fixtureB->GetBody();
		if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
			if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && [bodyB->GetUserData() isKindOfClass:[Bat class]] ){
				Boid *boid = (Boid *) bodyA->GetUserData();
				if ([bodyA->GetUserData() isKindOfClass:[Bat class]] == NO){
					Bat *bat = (Bat *) bodyB->GetUserData();
					//if it is dead already dont do anything with it
					[self playDeadBeeSound];
					[_deadBees addObject:boid];
					bat.life--;
					if (bat.life == 0){
						[_deadBats addObject:bat];
					}
				}
			}else if ([bodyB->GetUserData() isKindOfClass:[Boid class]] && [bodyA->GetUserData() isKindOfClass:[Bat class]] ){
				Boid *boid = (Boid *) bodyB->GetUserData();
				Bat *bat = (Bat *) bodyA->GetUserData();
				[self playDeadBeeSound];
				[_deadBees addObject:boid];
				bat.life--;
				if (bat.life == 0){
					[_deadBats addObject:bat];
				}
			}else if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && [bodyB->GetUserData() isKindOfClass:[Points class]] 
					 && ([bodyA->GetUserData() isKindOfClass:[Predator class]] == NO)){
				Points* point = (Points*) bodyB->GetUserData();
				if (point.taken == NO){
					point.taken = YES;
					//play some animation before deleting
					//delete the point
					//toDestroy.push_back(bodyB);
					_pointsGathered += point.value * _bonusCount;
					[_takenPoints addObject:point];
				}
			}else if ([bodyB->GetUserData() isKindOfClass:[Boid class]] && [bodyA->GetUserData() isKindOfClass:[Points class]]
					   && ([bodyB->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Points* point = (Points*) bodyA->GetUserData();
				if (point.taken == NO){
					point.taken = YES;
					//play some animation before deleting
					//delete the point
					//toDestroy.push_back(bodyA);
					if (point.type == GOLD){
						_pointsGathered += point.value * _bonusCount;
					}
					[_takenPoints addObject:point];
				}
			}
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
				Boid *boid = (Predator *) bodyB->GetUserData();
				[self playDeadBeeSound];
				[_deadBees addObject:boid];
				//toDestroy.push_back(bodyB);
			}
			else if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && [bodyB->GetUserData() isKindOfClass:[Spore class]]
					 && ([bodyA->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Predator *) bodyA->GetUserData();
				[self playDeadBeeSound];
				[_deadBees addObject:boid];
				//toDestroy.push_back(bodyA);
			}
						
			//ATKA
			else if ([bodyB->GetUserData() isKindOfClass:[Boid class]] && [bodyA->GetUserData() isKindOfClass:[Atka class]]
					 && ([bodyB->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Boid *) bodyB->GetUserData();
				[boid makeSick:0.5 withForce:0.5];
				_illnessTimeLeft = 2.0f;
				[self setSickSpeed];
			}
			else if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && [bodyB->GetUserData() isKindOfClass:[Atka class]]
					 && ([bodyA->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Boid *) bodyA->GetUserData();
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
			//ROCK
			else if ([bodyB->GetUserData() isKindOfClass:[Boid class]] && [bodyA->GetUserData() isKindOfClass:[Rock class]]
						 && ([bodyB->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Boid *) bodyB->GetUserData();
				[self playDeadBeeSound];
				[_deadBees addObject:boid];
				if (sharedManager.particles){
					[self addRockHitEmitter:boid.position];
				}
				//toDestroy.push_back(bodyB);
			}
			else if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && [bodyB->GetUserData() isKindOfClass:[Rock class]]
					 && ([bodyA->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Boid *) bodyA->GetUserData();
				[self playDeadBeeSound];
				[_deadBees addObject:boid];
				if (sharedManager.particles){
					[self addRockHitEmitter:boid.position];
				}
				//toDestroy.push_back(bodyA);
			}
			//GUANO
			else if ([bodyB->GetUserData() isKindOfClass:[Boid class]] && [bodyA->GetUserData() isKindOfClass:[Guano class]]) {
				Guano *guano = (Guano*) bodyA->GetUserData();
				if (guano.isActive){
					Boid *boid = (Boid *) bodyB->GetUserData();
					[self playDeadBeeSound];
					[_deadBees addObject:boid];
					guano.sprite.position = ccp(screenSize.width, screenSize.height + guano.sprite.contentSize.height);
					guano.isActive = NO;
					guano.speed = -1.5;
				}
				//toDestroy.push_back(bodyB);
			}
			else if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && [bodyB->GetUserData() isKindOfClass:[Guano class]]) {
				Guano *guano = (Guano*) bodyB->GetUserData();
				if (guano.isActive){				
					Boid *boid = (Boid *) bodyA->GetUserData();
					[self playDeadBeeSound];
					[_deadBees addObject:boid];
					guano.sprite.position = ccp(screenSize.width, screenSize.height + guano.sprite.contentSize.height);
					guano.isActive = NO;
					guano.speed = -1.5;
				}
				//toDestroy.push_back(bodyA);
			}
			
		}   
	}
	/*
	std::vector<b2Body *>::iterator pos2;
	for(pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
		b2Body *body = *pos2;     
		_world->DestroyBody(body);
	}	
	 */
}

-(void) actionMoveFinished:(id)sender{
	[_batchNode removeChild:(CCSprite*)sender cleanup:YES];
}


-(void) actionBonusFinished:(id)sender{
	[self removeChild:(CCLabelTTF*)sender cleanup:YES];
}

-(void) loadingTextures{
	_bonusCount = 1;
	[self unschedule:@selector(loadingTextures)];
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	[[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:NO];
	self.isTouchEnabled = YES;
	
	_effectSprite = [CCSprite spriteWithFile:@"darkenCornersFlowersEffect.png"];
	_effectSprite.position = ccp(screenSize.width/2, screenSize.height/2);
	_effectSprite.scale = 0.5;
	//_effectSprite.opacity = 0;
	[self addChild:_effectSprite z:600 tag:999];
	_batchNode = [CCSpriteBatchNode batchNodeWithFile:@"caveWorld.png"]; // 1
	[self addChild:_batchNode z:500 tag:500]; // 2
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"caveWorld.plist"];

	//init the box2d world
	b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
	bool doSleep = true;
	_world = new b2World(gravity, doSleep);
	
	_contactListener = new MyContactListener();
	//set the contactListener for the world
	_world->SetContactListener(_contactListener);
	
	_atkaOutOfScreen = YES;
	_sporeOutOfScreen = NO;
	
	//box2d end
	_minBatDistance = ccp(100,0);
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
	_distanceTravelled = 0;
//	_distanceToGoal = 7000;
	_forests = [[NSMutableArray alloc] init];
	
	_totalTimeElapsed = 0;
	
	_points = [[[NSMutableArray alloc] init]retain];
	_takenPoints = [[[NSMutableArray alloc] init]retain];
	_bees = [[[NSMutableArray alloc] init] retain];
	_deadBees = [[[NSMutableArray alloc] init] retain];
	_bats = [[[NSMutableArray alloc] init]retain];
	_deadBats = [[[NSMutableArray alloc] init]retain];
	_guanos = [[[NSMutableArray alloc] init]retain];
	_takenCombos = [[[NSMutableArray alloc] init] retain];
	
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
	
	
	Boid* boid;
	float count = 20;
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
		}else if (_level.difficulty == NORMAL){
			[boid setSpeedMax:3.0f  withRandomRangeOf:0.2f andSteeringForceMax:1.8f * 1.5f withRandomRangeOf:0.25f];
		}else if (_level.difficulty == HARD) {
			[boid setSpeedMax:4.0f  withRandomRangeOf:0.2f andSteeringForceMax:1.8f * 1.5f withRandomRangeOf:0.25f];
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
		//boid.rotation = 180;
		[boid setPos: ccp( CCRANDOM_0_1() * screenSize.width/3,  screenSize.height / 2)];
		// Color
		[boid setOpacity:220];
		[boid createBox2dBodyDefinitions:_world];
		[_batchNode addChild:boid z:100 tag:1];
		[boid update];
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

	for (int i = 0; i < 10; i++){
		//do a guano
		Guano* guano = [[Guano alloc]initWithFileName:@"rockparticle.png"];
		guano.sprite.position = ccp( _player.position.x ,screenSize.height + guano.sprite.contentSize.height * 1.5 * i);
		guano.sprite.scale = 0.5;
		[guano createBox2dBodyDefinitions:_world];
		[_batchNode addChild:guano.sprite z:201 tag:101];
		//set it to default
		[_guanos addObject:guano];
	}
	
	
	// init the parallax node 
	_backGroundNode = [CCParallaxNode node];
	[self addChild:_backGroundNode z:2];
	CGPoint bgSpeed = ccp(0.1, 0.0);
	_backGroundNode.position = _player.position;
	
	// init the background
	[self genBackground];
	

	[self initLabels];
	
	[self schedule:@selector(loadingTerrain)];
}


-(void) loadingTerrain{
	[self unschedule:@selector(loadingTerrain)];
	_minRockDistance = 150;
	float rnd = randRange(1, 2);
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	self.backgrounds = [[NSMutableArray alloc]init];
	
	CCSprite* topx;
	for (int i = 0 ; i <=2; i++){
		topx = [CCSprite spriteWithSpriteFrameName:@"top.png"];
		topx.scale = 0.5;
		topx.position = ccp(i* topx.contentSize.width * topx.scale + topx.contentSize.width/2 * topx.scale, screenSize.height - topx.contentSize.height/2 * topx.scale - 5);
		[self.backgrounds addObject:topx];
		[self addChild:topx z:2 tag:2];	
	}
	
	CCSprite* bottomx;
	for (int i = 0 ; i <=2; i++){
		bottomx = [CCSprite spriteWithSpriteFrameName:@"bottom.png"];
		bottomx.scale = 0.5;
		bottomx.position =ccp(i* bottomx.contentSize.width * bottomx.scale + bottomx.contentSize.width/2 * bottomx.scale , bottomx.contentSize.height/2 * bottomx.scale - 5);
		[self.backgrounds addObject:bottomx];
		[self addChild:bottomx z:2 tag:2];
	}
	
	//generate rocks
	Rock* rock1 = [[Rock alloc] initWithFileName:@"rock1.png"];
	rock1.sprite.position = ccp (screenSize.width/2, rock1.sprite.contentSize.height/2 - 20);
	rock1.sprite.position = ccp(bottomx.contentSize.width/2, rock1.sprite.contentSize.height/2);
	rock1.type = 1;
	[rock1 createBox2dBodyDefinitions:_world];
	[_batchNode addChild:rock1.sprite z:1 tag:1];
	
	Rock* rock2 = [[Rock alloc] initWithFileName:@"rock2.png"];
	rock2.type = 2;
	[rock2 createBox2dBodyDefinitions:_world];
	rock2.sprite.position = ccp (rock1.sprite.position.x + rock1.sprite.contentSize.width/2 +  rnd * _minRockDistance, rock2.sprite.contentSize.height/2 );
	[_batchNode addChild:rock2.sprite z:1 tag:1];
	
	Rock* rock1b = [[Rock alloc] initWithFileName:@"rock1.png"];
	rock1b.type = 1;
	[rock1b createBox2dBodyDefinitions:_world];
	rock1b.sprite.position = ccp (screenSize.width/2, bottomx.contentSize.height * bottomx.scale + rock1b.sprite.contentSize.height/2 - 20);
	rock1b.sprite.position = ccp(rock2.sprite.position.x + rock2.sprite.contentSize.width/2 +  rnd * _minRockDistance,  rock1b.sprite.contentSize.height/2 );
	[_batchNode addChild:rock1b.sprite z:1 tag:1];
	
	_bottomRocks = [[NSArray alloc] initWithObjects:rock1, rock2, rock1b, nil];
	_lastBottomRockLocation = rock2.sprite.position;
	
	//generate rocks
	Rock* rock3 = [[Rock alloc] initWithFileName:@"topRock1.png"];
	rock3.type = 3;
	[rock3 createBox2dBodyDefinitions:_world];
	rock3.sprite.position = ccp (screenSize.width/2 - rnd * _minRockDistance, screenSize.height - rock3.sprite.contentSize.height/2);
	[_batchNode addChild:rock3.sprite z:1 tag:1];
	
	Rock* rock4 = [[Rock alloc] initWithFileName:@"topRock2.png"];
	rock4.type = 4;
	[rock4 createBox2dBodyDefinitions:_world];
	rock4.sprite.position = ccp (rock3.sprite.position.x + rock3.sprite.contentSize.width/2 * rock3.sprite.scale + rnd* _minRockDistance , screenSize.height  - rock4.sprite.contentSize.height/2 );
	 [_batchNode addChild:rock4.sprite z:1 tag:1];
	
	Rock* rock5 = [[Rock alloc] initWithFileName:@"topRock2.png"];
	rock5.type = 4;
	[rock5 createBox2dBodyDefinitions:_world];
	rock5.sprite.position = ccp (rock4.sprite.position.x + rock4.sprite.contentSize.width/2 * rock4.sprite.scale + rnd* _minRockDistance , screenSize.height  - rock5.sprite.contentSize.height/2 );
	[_batchNode addChild:rock5.sprite z:1 tag:1];
	
	_lastTopRockLocation = rock4.sprite.position;
	
	_topRocks = [[NSArray alloc] initWithObjects:rock3, rock4, rock5, nil];
	
	//generate the bats
	_lastBatPosition = ccp(screenSize.width, screenSize.height - topx.contentSize.height * topx.scale);
	for (int i = 0; i<4; i++){
		[self generateBats];
	}
	
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
	_item1 = nil;
	_item2 = nil;
	_item3 = nil;
	_gameIsReady = YES;

	_tapToStartSprite = [CCSprite spriteWithFile:@"tapToStart.png"];
	_tapToStartSprite.scale = 0.5;
	_tapToStartSprite.position = _loadingSprite.position;
	[self removeChild:_loadingSprite cleanup:YES];
	[self addChild:_tapToStartSprite z:5002 tag:1001];
	[_activity removeFromSuperview];
	//add some tap to start
	_alchemy = [[[Alchemy alloc]init] retain];
	_alchemy.world = self;
}

-(id) init{
	if ((self = [super init])){
		self.level = [[LevelManager sharedManager] selectedLevel];
		_distanceToGoal = _level.distanceToGoal;
		if (_level.difficulty == EASY && _distanceToGoal > 0){
			_distanceToGoal = _distanceToGoal/2;
		}else if (_level.difficulty == NORMAL && _distanceToGoal > 0){
			_distanceToGoal = _distanceToGoal/3*2;
		}
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		_gameIsReady = NO;
		_gameStarted = NO;
		_paused = NO;
		_loadingScreen = [CCSprite spriteWithFile:@"curtain1small.png"];
		_loadingScreen.position = ccp(_loadingScreen.contentSize.width/2, _loadingScreen.contentSize.height/2 - 20);

		
		// Add the UIActivityIndicatorView (in UIKit universe)
		_activity = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge] autorelease];
		_activity.center = ccp(240,190);
		
		_loadingSprite = [CCSprite spriteWithFile:@"loading.png"];
		_loadingSprite.scale = 0.5;
		_loadingSprite.position = ccp(_activity.center.x, _activity.center.y + _loadingSprite.contentSize.height * _loadingSprite.scale);
		[self addChild:_loadingSprite z:5001 tag:1001];
		
		[_activity startAnimating];
		[[[CCDirector sharedDirector] openGLView] addSubview:_activity];
	
		[self addChild:_loadingScreen z:5000 tag:1000];
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
		}else if ([b->GetUserData() isKindOfClass:[Rock class]]){
			Rock *rock = (Rock *)b->GetUserData();
            b2Vec2 b2Position = b2Vec2(rock.sprite.position.x/PTM_RATIO,
                                       rock.sprite.position.y/PTM_RATIO);
            float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(rock.sprite.rotation);
            b->SetTransform(b2Position, b2Angle);
		}else if ([b->GetUserData() isKindOfClass:[Bat class]]){
			Bat *bat = (Bat *)b->GetUserData();
            b2Vec2 b2Position = b2Vec2(bat.sprite.position.x/PTM_RATIO,
                                       bat.sprite.position.y/PTM_RATIO);
            float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(bat.sprite.rotation);
            b->SetTransform(b2Position, b2Angle);
		}else if ([b->GetUserData() isKindOfClass:[Guano class]]){
			Guano *guano = (Guano *)b->GetUserData();
            b2Vec2 b2Position = b2Vec2(guano.sprite.position.x/PTM_RATIO,
                                       guano.sprite.position.y/PTM_RATIO);
            float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(guano.sprite.rotation);
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


-(void)respawnCave{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	for (CCSprite* sprite in _backgrounds){
		if (sprite.position.x + sprite.contentSize.width/2 * sprite.scale < _player.position.x - screenSize.width/2){
			sprite.position = ccp(sprite.position.x + ([_backgrounds count]/2) * sprite.contentSize.width * sprite.scale,
								  sprite.position.y);
		}
	}
	
	for (Rock* rock in _topRocks){
		if (rock.sprite.position.x + rock.sprite.contentSize.width/2 * rock.sprite.scale < _player.position.x - screenSize.width/2){
			float rnd = randRange(1, 4);
			if (_lastTopRockLocation.x  < _player.position.x + screenSize.width/2){
				_lastTopRockLocation = ccp(_player.position.x + screenSize.width/2, 0);
			}
			rock.sprite.position = ccp(_lastTopRockLocation.x + rnd * _minRockDistance + rock.sprite.contentSize.width ,rock.sprite.position.y );	
			[self checkRockBatCollision:rock];
			_lastTopRockLocation = rock.sprite.position;
		}
	}
	
	for (Rock* rock in _bottomRocks){
		if (rock.sprite.position.x + rock.sprite.contentSize.width/2 * rock.sprite.scale < _player.position.x - screenSize.width/2){
			float rnd = randRange(1, 4);
			if (_lastTopRockLocation.x  < _player.position.x + screenSize.width/2){
				_lastTopRockLocation = ccp(_player.position.x + screenSize.width/2, 0);
			}
			rock.sprite.position = ccp(_lastTopRockLocation.x + rnd * _minRockDistance + rock.sprite.contentSize.width ,rock.sprite.position.y );	
			_lastTopRockLocation = rock.sprite.position;
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
	if (_newHighScore && _isLevelDone) {
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
		if ([[ConfigManager sharedManager] particles]){
			[self addHighScoreEmitter];
		}
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
	[bee wander: 0.05f];
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


-(void) updateCave{
	/*
	for (Rock* rock in _topRocks){
		rock.sprite.position = ccpAdd(rock.sprite.position, ccp(_playerAcceleration.x/2, _playerAcceleration.y));
	}
	
	for (Rock* rock in _bottomRocks){
		rock.sprite.position = ccpAdd(rock.sprite.position, ccp(_playerAcceleration.x/2, _playerAcceleration.y));
	}*/
	
	
	[self respawnCave];
}

-(void)updateSounds:(ccTime)dt{
	if (_auEffectLeft > 0){
		_auEffectLeft-=dt;
		if (_auEffectLeft < 0){
			_auEffectLeft = 0;
		}
	}
}


-(void) removeOutOfScreenGuanos{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	CCSprite* bottomLine = (CCSprite*)[_backgrounds objectAtIndex:0];
	for (Guano* guano in _guanos){
		if (guano.isActive && guano.sprite.position.y + guano.sprite.contentSize.height/2 * guano.sprite.scale <= bottomLine.contentSize.height * bottomLine.scale){
			//splash
			guano.sprite.position = ccp(guano.sprite.position.x, screenSize.height + guano.sprite.contentSize.height * 2);
			guano.isActive = NO;
			guano.speed = -1.5;
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
			//update goalTime
			_goalTimeLeft -= tickTime;
			if (_goalTimeLeft <= 0) {
				[self clearGoals];
				_bonusCount = 1;
				[self displayNoBonus];				
				[self generateGoals];
				[self clearItems];
				[_alchemy clearItems];
			}else{
		//		int tmpTime = ceil(_goalTimeLeft);
		//		[_goalTimer setString:[NSString stringWithFormat:@"%i", tmpTime]];
			}
			
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
					_fireBall.sprite.position = ccpAdd(_fireBall.sprite.position, ccp(-1,0));
				}
			
				//parallaxNode
				CGPoint backgroundScrollVel = ccp(-10, 0);
				_backGroundNode.position = ccpAdd(_backGroundNode.position, backgroundScrollVel);
				//ccpMult(backgroundScrollVel, dt));
				CGSize screenSize = [[CCDirector sharedDirector] winSize];
				if (((_player.position.y + _player.contentSize.height/2 >= screenSize.height) && _playerAcceleration.y > 0) ||
					((_player.position.y - _player.contentSize.height/2 <= 0) && _playerAcceleration.y < 0)){
						_playerAcceleration = ccp(_playerAcceleration.x, 0);
				}
				
				_player.position = ccpAdd(_player.position, _playerAcceleration);
				_effectSprite.position = _player.position;
			
				for (Boid* boid in _bees){
					if (_slowestBoid == nil){
						_slowestBoid = boid;
					}else {
						if (boid.maxSpeed < _slowestBoid.maxSpeed){
							_slowestBoid = boid;
						}
					}
				}
				
				for (Bat* bat in _bats){
					if ([self isOnScreen:bat.sprite]) {
						bat.timeLeftForGuano -= dt;
						if (bat.timeLeftForGuano <= 0) {
							//do a guano
							for (Guano* guano in _guanos){
								if (guano.isActive == NO){
									guano.sprite.position = bat.sprite.position;
									guano.isActive = YES;
									break;
								}
							}
							bat.timeLeftForGuano = bat.maxGuanoTime;
						}
					}
				}
				
				for (Guano* guano in _guanos){
					if (guano.isActive){
						guano.sprite.position = ccpAdd(guano.sprite.position, ccp(0, guano.speed));
						guano.speed -= 0.1;
					}
				}
				
				[self removeOutOfScreenGuanos];
				[self removeOutOfScreenBats];
				[self beeMovement:dt];
				[self removeOutOfScreenItems];
				//update terrain, tell it how far we have proceeded
				//[_terrain setOffsetX:_playerAcceleration.x];
				//respawn the clouds if needed
				if (_updateBox) {
					_updateBox = NO;
					[self updateBox2DWorld:dt];
				}
				
				//detect the collisions
				[self detectBox2DCollisions];
				[self setViewpointCenter:_player.position];
				[self detectGameConditions];
				_distanceTravelled = _player.position.x /3 ;
				[self updateLabels];
				if (_level.sporeAvailable || _level.trapAvailable){
					[self generateNextScreen];
				}
				[self updatePoints];
				[self updateCave];
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
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCAction* moveDownward = [[CCMoveTo actionWithDuration:0.5f position:ccp(_player.position.x, screenSize.height/2)] retain];
		CCAction* moveDone = [CCCallFuncN actionWithTarget:self 
														 selector:@selector(createPauseMenu)];
		[_loadingScreen runAction:[CCSequence actions: moveDownward, moveDone, nil]];
		[self unschedule:@selector(update:)];
		_paused = YES;
	}else{
		_paused = NO;
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCAction* moveUpwards = [[CCMoveTo actionWithDuration:0.5f position:ccp(_player.position.x, screenSize.height + screenSize.height/2 + 30)] retain];
		[_loadingScreen runAction:moveUpwards];
		[self schedule: @selector(update:)];
		[_pausedMenu runAction:[CCFadeOut actionWithDuration:0.2]];
		[self removeChild:_pausedMenu cleanup:YES]; 
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
		CCAction* moveUpwards = [[CCMoveTo actionWithDuration:1.0f position:ccp(_player.position.x, screenSize.height + screenSize.height/2 + 30)] retain];
		[_loadingScreen runAction:moveUpwards];
		_gameStarted = YES;
		[self removeChild:_tapToStartSprite cleanup:YES];
		[self schedule: @selector(update:)];
		[self generateGoals];
	}else if (_gameIsReady && _gameStarted){
		self.currentTouch = [self convertTouchToNodeSpace: touch];
		self.currentTouch = ccp(self.currentTouch.x - 10, self.currentTouch.y);
		if (_isGameOver){
			/*
			if (_newHighScore){
				[self saveLevelPerformance];
			}
			 */
			[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.0 scene:[MainMenuScene scene] withColor:ccBLACK]];
		}else if (_isLevelDone) {
			if (_newHighScore){
				[self saveLevelPerformance];
			}
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
	[_bats release];
	_bats = nil;
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
	_pointsSprite = nil;
	_batchNode = nil;
	_loadingScreen = nil;
	_tapToStartSprite = nil;
	_effectSprite = nil;
	_slot1 = nil;
	_slot2 = nil;
	_slot3 = nil;
	_ornament1 = nil;
	_ornament2 = nil;
	_ornament3 = nil;
	_rightOrnament = nil;
	_item1 = nil;
	_item2 = nil;
	_item3 = nil;
	_goal1Slot = nil;
	_goal2Slot = nil;
	_goal3Slot = nil;
	_particleNode = nil;
	_emitter = nil;
	_slowestBoid = nil;
	_terrain = nil;
	_goal1Sprite = nil;
	_goal2Sprite = nil;
	_goal3Sprite = nil;
	_backGround = nil;
	_backGround2 = nil;
	_backGround3 = nil;
	_top1 = nil;
	_bottom1 = nil;
}	


@end




