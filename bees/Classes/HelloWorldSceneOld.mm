//
//  HelloWorldScene.mm
//  bees
//
//  Created by macbook white on 7/18/11.
//  Copyright nincs 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldScene.h"

#define rad2Deg 57.2957795

#define leftEdge 0.0f
#define bottomEdge 0.0f
#define topEdge 320.0f
#define rightEdge 480.0f

#define IGNORE 1.0f

#define kFilteringFactor 0.05
CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

@implementation PauseMenuLayer
@synthesize hudLayer = _hudLayer;


-(id) init{
	if ((self = [super init])){
		//disable multitouch for this menu layer
//		[[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:NO];
		self.isTouchEnabled = NO;
		[self addLayerImage];
	}
	return self;
}

-(void) showControls{
	
}


-(void) hideControls{
	
}


-(void) addLayerImage{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	CCSprite* layerImage = [CCSprite spriteWithFile:@"pauselayer.png"];
	layerImage.position = ccp(winSize.width/2, winSize.height/2);
	layerImage.scale = 0.1;
	layerImage.opacity = 180;
	[self addChild:layerImage];
	[layerImage runAction: [CCScaleTo actionWithDuration:0.2 scale:0.5]];
	[self addLayerButtons];
}

-(void) addLayerButtons{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	CCLabelTTF* resumeLabel = [[CCLabelTTF alloc] initWithString:@"Resume" fontName:@"Arial" fontSize:16];
	resumeLabel.color = ccc3(0, 0, 0);
	CCMenuItemFont* resumeButton = [[CCMenuItemLabel alloc] initWithLabel:resumeLabel target: self 
																 selector:@selector(resumeButtonTapped:)];
	
	CCMenu* pausedMenu = [CCMenu menuWithItems:resumeButton, nil];
	pausedMenu.position = ccp(winSize.width/2, winSize.height/2);
	[self addChild:pausedMenu];
}

-(void) resumeButtonTapped:(id)sender {
	[self.hudLayer continueGame];
}

-(void) optionsButtonTapped:(id)sender{
	
}

-(void) quitButtonTapped:(id)sender{
	
}

-(void) dealloc{
	[self.hudLayer release];
	[super dealloc];
}

@end


// HUD Layer implementation

@implementation HUDLayer
@synthesize mainScreen = _mainScreen;
@synthesize pauseScreen = _pauseScreen;
@synthesize pauseButton = _pauseButton;


-(id) init{
	if ((self = [super init])){
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		
		//enable multitouch
		[[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:NO];
		self.isTouchEnabled = NO;
				
	//	_pauseButton = [[CCMenuItemImage itemFromNormalImage:@"upperPauseButton.png" selectedImage:@"upperPauseButton.png" target:self
	//												selector:@selector(pauseButtonTapped:)] retain];
	//	CCMenu* pauseMenu = [CCMenu menuWithItems:_pauseButton, nil];
	//	pauseMenu.position = ccp(screenSize.width - _pauseButton.contentSize.width/2, screenSize.height - _pauseButton.contentSize.height/2);
	//	[self addChild:pauseMenu z:51 tag:51];
	}
	return self;
}

-(void) continueGame{
	[self removeChild:self.pauseScreen cleanup:YES];
	[self showControls];
	[self.mainScreen continueGame];
}

-(void) hideControls{
	[self.pauseButton setIsEnabled:NO];
}

-(void) showControls{
	[self.pauseButton setIsEnabled:YES];
}

-(void)pauseButtonTapped:(id)sender{
	[_mainScreen switchPause];
}

@end 


@implementation HelloWorld
@synthesize  currentTouch = _currentTouch;
@synthesize uiLayer = _uiLayer;
@synthesize attackEnabled = _attackEnabled;
@synthesize evadeEnabled = _evadeEnabled;
@synthesize paused = _paused;
@synthesize attackBoostIntensity = _attackBoostIntensity;
@synthesize evadeBoostIntensity = _evadeBoostIntensity;

static Level* _level;
static int _difficulty;
static int _type;

+ (Level*) getLevel{
    return _level;
}

+ (void)setLevel:(Level*)newLevel {
    if (_level != newLevel) {
        [_level release];
        _level = [newLevel copy];
    }
}

+ (int) getType{
    return _type;
}

+ (void)setType:(int)newType {
    if (_type != newType) {
		_type = newType;
    }
}

+ (int) getDifficulty{
    return _difficulty;
}

+ (void)setDifficulty:(int)newDifficulty {
    if (_difficulty != newDifficulty) {
        _difficulty = newDifficulty;
    }
}


+(id)scene{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	HUDLayer *hud = [HUDLayer node];
	[scene addChild:hud	 z:200];
	hud.mainScreen = layer;
	
	// return the scene
	return scene;
}


+(id) scene:(Level*)level withDifficulty:(int) difficulty withType:(int)levelType{
	//set the name for the race;
	[HelloWorld setLevel:level];
	//set the name for the race;
	[HelloWorld setType:levelType];
	//set the name for the race;
	[HelloWorld setDifficulty:difficulty];
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	HUDLayer *hud = [HUDLayer node];
	[scene addChild:hud	 z:200];
	hud.mainScreen = layer;
	
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
	_backGround = [CCSprite spriteWithFile:@"bg1.png"];
	_backGround.position = ccp(winSize.width/2, winSize.height/2);
	[self addChild:_backGround z:-1 tag:1];
}



#pragma mark particles
-(void) generateParticle:(int)type{
	_emitter = [CCParticleSystemQuad particleWithFile:@"fallingDown.plist"];
	[_tree  addChild:_emitter z:-1 tag:100];
	_emitter.scale = 0.6;

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
			point.taken = NO;
			NSLog(@"out of screen point");
			[self movePointToNewPosition:point.sprite];
			/*
			for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
				if (point == b->GetUserData()) {
					toDestroy.push_back(b);
					NSLog(@"removing out of screen point");
					break;
				}
			}*/
		}
		//[_points removeObjectsInArray:_takenPoints];
	}
	/*std::vector<b2Body *>::iterator pos2;
	for(pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
		b2Body *body = *pos2;     
		_world->DestroyBody(body);
	}*/
}

-(void) removeOutOfScreenItems{
	[self removeOutOfScreenSpore];
	[self removeOutOfScreenAtka];
	[self removeOutOfScreenPoints];
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
	float rnd = randRange(1,4);
	Points* point = nil;	
	CGSize screenSize = [[CCDirector sharedDirector] winSize];

	if (types == YELLOW_SLOT){
		//but right now just add a point to a random location
		point =	[[Points alloc] initWithFileName:@"yellowFlower.png" withValue:1];
		point.sprite.position  = ccp(_player.position.x + screenSize.width/2 + screenSize.width/4 + rnd * screenSize.width/16,
									 rnd * screenSize.height/5 );
		[point scaleSprite:0.5];
		[point createBox2dBodyDefinitions:_world];
		point.type = GOLD;
		[_points addObject:point];
		[_batchNode addChild:point.sprite z:50 tag:5];
	}else if (types == RED_SLOT){
		//but right now just add a point to a random location
		point =	[[Points alloc] initWithFileName:@"redFlower.png" withValue:1];
		point.sprite.position  = ccp(_lastPointLocation.x + screenSize.width/4 + rnd * screenSize.width/16, 
									 rnd * screenSize.height/5 );
		[point scaleSprite:0.5];
		[point createBox2dBodyDefinitions:_world];
		point.type = ATTACK_BOOST;
		[_points addObject:point];
		[_batchNode addChild:point.sprite z:50 tag:5];
	}else if (types == BLUE_SLOT){
		//but right now just add a point to a random location
		point =	[[Points alloc] initWithFileName:@"blueFlower.png" withValue:1];
		point.sprite.position  = ccp(_lastPointLocation.x + screenSize.width/4 + rnd * screenSize.width/16, 
									 rnd * screenSize.height/5 );
		[point scaleSprite:0.5];
		[point createBox2dBodyDefinitions:_world];
		 point.type = EVADE_BOOST;
		[_points addObject:point];
		[_batchNode addChild:point.sprite z:50 tag:5];
	}
	
	_lastPointLocation = point.sprite.position;
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

-(void) updateLabels{
	
	_ornament1.position = ccp(_ornament1.position.x + _playerAcceleration.x, _ornament1.position.y);
	_ornament2.position = ccp(_ornament2.position.x + _playerAcceleration.x, _ornament2.position.y);
	_ornament3.position = ccp(_ornament3.position.x + _playerAcceleration.x, _ornament3.position.y);
	
	_slot1.position = ccp(_slot1.position.x + _playerAcceleration.x, _slot1.position.y);
	_slot2.position = ccp(_slot2.position.x + _playerAcceleration.x, _slot2.position.y);
	_slot3.position = ccp(_slot3.position.x + _playerAcceleration.x, _slot3.position.y);
	
	/*
	[_distanceLabel setString:[NSString stringWithFormat:@"%i meters", _distanceTravelled]];
	_distanceLabel.position = ccp(_player.position.x, _distanceLabel.position.y);
	[_pointsLabel setString:[NSString stringWithFormat:@"%i points", _pointsGathered]];
	_pointsLabel.position = ccp(_pointsLabel.position.x + _playerAcceleration.x, _pointsLabel.position.y);
	_upperOverlay.position = ccp(_upperOverlay.position.x + _playerAcceleration.x, _upperOverlay.position.y);
	if (_attackBoostSprite != nil){
		_attackBoostSprite.position = ccp(_attackBoostSprite.position.x + _playerAcceleration.x, _attackBoostSprite.position.y);
	}
	if (_evadeBoostSprite != nil){
		_evadeBoostSprite.position = ccp(_evadeBoostSprite.position.x + _playerAcceleration.x, _evadeBoostSprite.position.y);
	}*/
}
 

-(void) initLabels{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	/*
	_distanceLabel = [CCLabelTTF labelWithString:@"0 meters" fontName:@"Marker Felt" fontSize:12];
	_distanceLabel.position = ccp(screenSize.width/2, screenSize.height - _distanceLabel.contentSize.height/2 );
	_distanceLabel.color = ccBLACK;
	[self addChild:_distanceLabel z:300 tag:300];
	 */
	
	float ornamentWidth;
	float slotWidth;
	
	_ornament1 = [[CCSprite spriteWithSpriteFrameName:@"leftOrnament.png"] retain];
	_ornament2 = [[CCSprite spriteWithSpriteFrameName:@"leftOrnament.png"] retain];
	_ornament3 = [[CCSprite spriteWithSpriteFrameName:@"leftOrnament.png"] retain];
	_slot1 = [[CCSprite spriteWithSpriteFrameName:@"emptySlot.png"] retain];
	_slot2 = [[CCSprite spriteWithSpriteFrameName:@"emptySlot.png"] retain];
	_slot3 = [[CCSprite spriteWithSpriteFrameName:@"emptySlot.png"] retain];
	
	ornamentWidth = _ornament1.contentSize.width;
	slotWidth = _slot1.contentSize.width;
	
	_slot1.scale = 0.6;
	_slot2.scale = 0.6;
	_slot3.scale = 0.6;
	
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
	
	
	/*
	_pointsLabel = [CCLabelTTF labelWithString:@"0 points" fontName:@"Marker Felt" fontSize:12];
	_pointsLabel.position = ccp(_pointsLabel.contentSize.width/2 + 5, screenSize.height - _distanceLabel.contentSize.height/2);
	_pointsLabel.color = ccBLACK;
	[self addChild:_pointsLabel z: 300 tag:301];
	
	_upperOverlay = [CCSprite spriteWithFile:@"upperYellowBar.png"];
	_upperOverlay.position = ccp(_upperOverlay.contentSize.width/2, screenSize.height - _upperOverlay.contentSize.height/2);
	[self addChild:_upperOverlay z: 50 tag:50];
	 */
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
	std::vector<b2Body *>toDestroy; 
	for (Predator* predator in _predators){
		if ([self isOnScreen:predator]){
			CCAction* actionScaleIn = [CCScaleTo actionWithDuration:0.3f scale:1.0];
			CCAction* actionScaleDone = [CCCallFuncN actionWithTarget:self 
															 selector:@selector(actionScaleFinished:)];
			CCSprite* deadSprite = [CCSprite spriteWithSpriteFrameName:@"beeDies.png"];
			deadSprite.position = predator.position;
			deadSprite.scale = 0.4;
			[deadSprite runAction:[CCSequence actions:actionScaleIn, actionScaleDone, nil]];
			[_batchNode addChild:deadSprite z:300 tag:400];
			[_deadPredators addObject:predator];
			
			b2Body *predatorBody = NULL;
			for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
				if (predator == (Predator*) b->GetUserData()) {
					predatorBody = b;
					toDestroy.push_back(predatorBody);
					break;
				}
			}
		}
	} 
	std::vector<b2Body *>::iterator pos2;
	for(pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
		b2Body *body = *pos2;     
		_world->DestroyBody(body);
	}
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
	NSLog(@"growing");
}	


-(void) applyEffect:(int)effect{
	if (effect == BOMB_EFFECT){
		[self bombEffect];
	}else if (effect == SPEED_EFFECT){
		[self speedEffect];
	}else if (effect == DISEASE_EFFECT){
		[self diseaseEffect];
	}else if (effect == SHRINK_EFFECT){
		[self shrinkEffect];
	}
	
	/*
	if (effect > 0){
		[_batchNode removeChild:_item1 cleanup:YES];
		_item1 = nil;
		[_batchNode removeChild:_item2 cleanup:YES];
		_item2 = nil;
		[_batchNode removeChild:_item3 cleanup:YES];
		_item3 = nil;
	}*/
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


-(void)addItem:(NSString*)item{
	if (_item1 == nil) {
		_item1 = [CCSprite spriteWithSpriteFrameName:item];
		_item1.scale = 0.6;
		[self addChild:_item1 z:110 tag:100];
	}else if(_item2 == nil){
		_item2 = [CCSprite spriteWithSpriteFrameName:item];
		_item2.scale = 0.6;
		[self addChild:_item2 z:110 tag:100];
	}else if(_item3 == nil){
		_item3 = [CCSprite spriteWithSpriteFrameName:item];
		_item3.scale = 0.6;
		_item3.position = _slot3.position;
		[self addChild:_item3 z:110 tag:100];
	}
}

-(void) movePointToNewPosition:(CCSprite*) point{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	float rnd = randRange(1, 4);
	point.position  = ccp(_lastPointLocation.x + screenSize.width/4, 
								 rnd * screenSize.height/5 );	
	_lastPointLocation = point.position;
}

-(void) movePredatorToNewPosition:(Predator*) predator{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	float rnd = randRange(1, 4);
	predator.position  = ccp(_lastPredatorLocation.x + screenSize.width/2 ,rnd * screenSize.height/5 );	
	_lastPredatorLocation = predator.position;
 	NSLog(@"%f", _lastPredatorLocation.x);
}

-(void) moveToCemetery:(Boid *)sprite{
//	if (sprite.specy == BEE){
//		sprite.position = ccp(-500,-500);
//	}
}


-(void) removeDeadItems{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	
	for (Points* point in _takenPoints){
		NSLog(@"remove dead point");
			PointTaken* actionMoveUp = [PointTaken actionWithDuration:0.4 moveTo:ccp(point.sprite.position.x - _playerAcceleration.x * 5,
																					 point.sprite.position.y + point.sprite.contentSize.height * point.sprite.scale)];
			CCAction* actionMoveDone = [CCCallFuncN actionWithTarget:self 
															selector:@selector(actionScaleFinished:)];
			[point.sprite runAction:[CCSequence actions:actionMoveUp, actionMoveDone, nil]];
			
			if (point.type == ATTACK_BOOST){
				[_alchemy addItem:RED_SLOT];
				//[self addItem:@"redFlower.png"];
			}else if (point.type == GOLD){
				[_alchemy addItem:YELLOW_SLOT];
				//[self addItem:@"yellowFlower.png"];
			}else if (point.type == EVADE_BOOST){
				[_alchemy addItem:BLUE_SLOT];
				//[self addItem:@"blueFlower.png"];
			}
	}
		
	//remove the dead objects
	for (Boid* boid in _deadBees){
		CCAction* actionScaleIn = [CCScaleTo actionWithDuration:0.3f scale:1.0] ;
		CCAction* actionScaleDone = [CCCallFuncN actionWithTarget:self 
														 selector:@selector(actionScaleFinished:)];
		//add the deadAnimation
		CCSprite* deadSprite = [CCSprite spriteWithSpriteFrameName:@"beeDies.png"];
		deadSprite.position = boid.position;
		deadSprite.scale = 0.3;
		[deadSprite runAction:[CCSequence actions:actionScaleIn, actionScaleDone, nil]];	
		[_batchNode addChild:deadSprite z:300 tag:boid.tag-1];
		//[_batchNode removeChild:boid cleanup:YES];
		[self moveToCemetery:boid];
		[_bees removeObject:boid];
		//check if it was the slowest
		if ([_slowestBoid isEqual:boid]){
			_slowestBoid = nil;
		}
	}
	
	/*
	for (Predator* predator in _deadPredators){
		if ([self isOnScreen:predator]){
			CCAction* actionScaleIn = [CCScaleTo actionWithDuration:0.3f scale:1.3];
			CCAction* actionScaleDone = [CCCallFuncN actionWithTarget:self 
															 selector:@selector(actionScaleFinished:)];
			CCSprite* deadSprite = [CCSprite spriteWithSpriteFrameName:@"beeDies.png"];
			deadSprite.position = predator.position;
			deadSprite.scale = 0.4;
			[deadSprite runAction:[CCSequence actions:actionScaleIn, actionScaleDone, nil]];	
			[_batchNode addChild:deadSprite z:299 tag:predator.tag-1];
		}
		//[_batchNode removeChild:predator cleanup:YES];
		[self movePredatorToNewPosition:predator];
		//[_predators removeObject:predator];
	}*/
	
	[_deadBees removeAllObjects];
	[_deadPredators removeAllObjects];
	[_takenPoints removeAllObjects];
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
						[_deadBees addObject:boid];
						//toDestroy.push_back(bodyB);
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
					//play some animation before deleting
					//delete the point
					//toDestroy.push_back(bodyB);
					if (point.type == GOLD){
						_pointsGathered += point.value;
					}
					
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
						_pointsGathered += point.value;
					}
					[_takenPoints addObject:point];
				}
			}
			//SPORE
			else if ([bodyB->GetUserData() isKindOfClass:[Boid class]] && [bodyA->GetUserData() isKindOfClass:[Spore class]]
					 && ([bodyB->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Predator *) bodyB->GetUserData();
				[_deadBees addObject:boid];
				//toDestroy.push_back(bodyB);
			}
			else if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && [bodyB->GetUserData() isKindOfClass:[Spore class]]
					 && ([bodyA->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Predator *) bodyA->GetUserData();
				[_deadBees addObject:boid];
				//toDestroy.push_back(bodyA);
			}
			else if ([bodyA->GetUserData() isKindOfClass:[Predator class]] && [bodyB->GetUserData() isKindOfClass:[Spore class]]) {
				Predator *predator = (Predator *) bodyA->GetUserData();
				[_deadPredators addObject:predator];
			//	toDestroy.push_back(bodyA);
			}
			else if ([bodyB->GetUserData() isKindOfClass:[Predator class]] && [bodyA->GetUserData() isKindOfClass:[Spore class]]) {
				Predator *predator = (Predator *) bodyB->GetUserData();
				[_deadPredators addObject:predator];
			//	toDestroy.push_back(bodyB);
			}
			//EMITTER
			else if ([bodyB->GetUserData() isKindOfClass:[Boid class]] && [bodyA->GetUserData() isKindOfClass:[CollisionEmitter class]]
					 && ([bodyB->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Predator *) bodyB->GetUserData();
				[_deadBees addObject:boid];
			//	toDestroy.push_back(bodyB);
			}
			else if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && [bodyB->GetUserData() isKindOfClass:[CollisionEmitter class]]
					 && ([bodyA->GetUserData() isKindOfClass:[Predator class]] == NO)) {
				Boid *boid = (Predator *) bodyA->GetUserData();
				[_deadBees addObject:boid];
			//	toDestroy.push_back(bodyA);
			}
			else if ([bodyA->GetUserData() isKindOfClass:[Predator class]] && [bodyB->GetUserData() isKindOfClass:[CollisionEmitter class]]) {
				Predator *predator = (Predator *) bodyA->GetUserData();
				[_deadPredators addObject:predator];
			//	toDestroy.push_back(bodyA);
			}
			else if ([bodyB->GetUserData() isKindOfClass:[Predator class]] && [bodyA->GetUserData() isKindOfClass:[CollisionEmitter class]]) {
				Predator *predator = (Predator *) bodyB->GetUserData();
				[_deadPredators addObject:predator];
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
	}	
	 */
}

-(void) actionScaleFinished:(id)sender{
	[self movePointToNewPosition:(CCSprite*)sender];
	//[_batchNode removeChild:(CCSprite*)sender cleanup:YES];
}



-(void) loadingTextures{
	[self unschedule:@selector(loadingTextures)];
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	[[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:NO];
	self.isTouchEnabled = YES;
	
	_effectSprite = [CCSprite	spriteWithFile:@"darkenCornersFlowersEffect.png"];
	_effectSprite.position = ccp(screenSize.width/2, screenSize.height/2);
	_effectSprite.scale = 0.5;
//	_effectSprite.opacity = 0;
	[self addChild:_effectSprite z:600 tag:999];
	_batchNode = [CCSpriteBatchNode batchNodeWithFile:@"beeSprites.png"]; // 1
	[self addChild:_batchNode z:500 tag:500]; // 2
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"beeSprites.plist"];
	
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
	
	_beeSick = NO;
	//set the speeds 
	_normalSpeed = ccp(3,0);
	_boostSpeed = ccp(4.5,0);
	_sickSpeed = ccp(1.5,0);
	_playerAcceleration = _normalSpeed;
	_attackBoostIntensity = 0.43;
	_evadeBoostIntensity = 0.1;
	_pointsGathered = 0;
	_boostTimeLeft = 0;
	_lastPointLocation = ccp(screenSize.width, 0);
	_lastPredatorLocation = ccp(screenSize.width, 0);
	_distanceTravelled = 0;
	_forests = [[NSMutableArray alloc] init];
	
	_totalTimeElapsed = 0;
	_timeUntilNextWave = 1;
	
	_points = [[[NSMutableArray alloc] init]retain];
	_takenPoints = [[[NSMutableArray alloc] init]retain];
	_bees = [[[NSMutableArray alloc] init] retain];
	_deadBees = [[[NSMutableArray alloc] init] retain];
	_predators = [[[NSMutableArray alloc] init]retain];
	_deadPredators = [[[NSMutableArray alloc] init]retain];
	
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
	
	_atka = nil;
	
	_fireBall = [[[Spore alloc] initForNode:_batchNode] retain];
	_fireBall.sprite.position = ccpAdd(_player.position, ccp(screenSize.width * randomDist, screenSize.height/2 * randomY));
	[_fireBall createBox2dBodyDefinitions:_world];
	
	
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
		[boid setSpeedMax:2.6f * 1.5f withRandomRangeOf:0.2f andSteeringForceMax:1.8f * 1.5f withRandomRangeOf:0.25f];
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
		[boid setOpacity:200];
		[boid createBox2dBodyDefinitions:_world];
		[_batchNode addChild:boid z:100 tag:1];
		[boid update];
	}		
	
	for (int i = 0; i < 10; i++){
		[self generatePredators];
	}
	
	for (int i = 0; i < 12; i++) {
		[self generateNextPoint: (i % 3)+1];
	}
	
	// init the background
	[self genBackground];
	
	//init the array for clouds
	_clouds = [[NSMutableArray alloc] init];
	//init the clouds
	CCSprite* bgCloud;
	for (int i= 0; i <6; i++){
		bgCloud = [CCSprite spriteWithSpriteFrameName:@"cloudsmall.png"];
		bgCloud.scale = randRange(0.4, 1.0);
		bgCloud.opacity = 220;
		[_clouds addObject:bgCloud];
	}
	
	// init the parallax node 
	_backGroundNode = [CCParallaxNode node];
	[self addChild:_backGroundNode z:2];
	CGPoint bgSpeed = ccp(0.1, 0.0);
	_backGroundNode.anchorPoint = ccp(0,0);
	_backGroundNode.position = _player.position;
	
	for (CCSprite* cloud in _clouds) {
		float rnd = randRange(0.1, 1.0);
		float rndOffset = randRange(400, 1000);
		CGPoint positionOffsetForCloud = ccp(screenSize.width - cloud.contentSize.width * cloud.scale + rndOffset, 
											 screenSize.height - cloud.contentSize.height * cloud.scale);
		[_backGroundNode addChild:cloud z:2 parallaxRatio:ccp(rnd*0.5/4,0) positionOffset:positionOffsetForCloud];
	}
	
	for (int i = 0; i <=4 ; i++){
		CCSprite* forestSprite = [CCSprite spriteWithSpriteFrameName:@"grass21.png"];
		forestSprite.scale = 0.7;
		bgSpeed = ccp(0.1, 0.0);  
		[_backGroundNode addChild:forestSprite z:60 parallaxRatio:bgSpeed positionOffset:ccp(((i*2+1)*forestSprite.contentSize.width/2)*forestSprite.scale,
																							 forestSprite.contentSize.height/2  * forestSprite.scale)];
		[_forests addObject:forestSprite];
	}
	
	_tree = [CCSprite spriteWithFile:@"tree1.png"];
	_tree.scale = 0.6;
	[_backGroundNode addChild:_tree z:59 parallaxRatio:ccp(0.05, 0.0) positionOffset:ccp(screenSize.width * 3/2, _tree.contentSize.height/2 *_tree.scale)];
	[self generateParticle:0];
	
	
	[self initLabels];
	
	[self schedule:@selector(loadingTerrain)];
}

-(void) loadingTerrain{
	[self unschedule:@selector(loadingTerrain)];
	
	_terrain = [Terrain node];
	ccColor4F bgColor = [self randomGreenColor];
	CCSprite *stripes = [self spriteWithColor:bgColor textureSize:512 withNoise:@"grassNoise4.png" withGradientAlpha:1.0f];
	
	ccTexParams tp2 =  {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
	[stripes.texture setTexParameters:&tp2];
	_terrain.stripes = stripes;
	[self addChild:_terrain z:30];
	[_terrain setOffsetX:_playerAcceleration.x];

	[self schedule:@selector(loadingSounds)];
}


-(void) loadingSounds{
	[self unschedule:@selector(loadingSounds)];
	[self schedule:@selector(loadingDone)];
}

-(void) loadingDone{
	[self unschedule:@selector(loadingDone)];
	_item1 = nil;
	_item2 = nil;
	_item3 = nil;
	_gameIsReady = YES;
	[_activity removeFromSuperview];
	//add some tap to start
	_alchemy = [[[Alchemy alloc]init] retain];
	_alchemy.world = self;
}

-(id) init{
	if ((self = [super init])){
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		_gameIsReady = NO;
		_gameStarted = NO;
		_moveUpwards = [[CCMoveTo actionWithDuration:1.0f position:ccp(screenSize.width/2, screenSize.height + screenSize.height/2 + 30)] retain];
		_loadingScreen = [CCSprite spriteWithFile:@"curtain1small.png"];
		_loadingScreen.position = ccp(_loadingScreen.contentSize.width/2, _loadingScreen.contentSize.height/2 - 20);

		
		// Add the UIActivityIndicatorView (in UIKit universe)
		_activity = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge] autorelease];
		_activity.center = ccp(240,190);
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
	
	/*
	if ([_backGroundNode convertToWorldSpace:_tree.position].x < -_tree.contentSize.width * _tree.scale) {
		[_backGroundNode incrementOffset:ccp(_tree.contentSize.width * _tree.scale + screenSize.width * 3 ,0) forChild:_tree];
		[_backGroundNode convertToWorldSpace:_tree.position];
	}*/
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
	}		
}


-(void)generatePredators{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	Predator* predator = [Predator spriteWithSpriteFrameName:@"fly.png"];
	predator.scale = 0.6;
	int pType = arc4random() % MAX_PREDATOR_TYPE;
	
	predator.type = pType;
	[_predators addObject:predator];
	predator.doRotation = YES; 
	[predator setSpeedMax:2.0f withRandomRangeOf:0.2f andSteeringForceMax:1.0f withRandomRangeOf:0.15f];
	[predator setWanderingRadius: 16.0f lookAheadDistance: 40.0f andMaxTurningAngle:0.2f];
	[predator setEdgeBehavior: EDGE_NONE];
	//[predator setPos: ccp( _player.position.x + screenSize.width/2 + CCRANDOM_0_1() * screenSize.width/3,  screenSize.height * CCRANDOM_0_1())];
	// Color
	[predator setOpacity:250];
	[_batchNode addChild:predator z:101 tag:1];
	
	predator.life = 1;
	predator.stamina = 8;
	_timeUntilNextWave = 1;
	[self movePredatorToNewPosition:predator];
	[predator createBox2dBodyDefinitions:_world];
}


-(void)updatePredators:(ccTime)dt{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	//std::vector<b2Body *>toDestroy; 
	for (Predator* predator in _predators){
		float tmp = predator.position.x - _player.position.x - screenSize.width < 0;
		if (tmp < 0){ 
			//predator.position.y >= _player.position.y + screenSize.height/2 + predator.contentSize.height/2||
			//predator.position.y <= _player.position.y -screenSize.height/2 - predator.contentSize.height/2){
			
			//remove the predator it is too far away.
			//[_deadPredators addObject:predator];
			[self movePredatorToNewPosition:predator];
			//find the b2body for the predator, add to the toDestroy array
			/*
			b2Body *predatorBody = NULL;
			for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
				if (predator == b->GetUserData()) {
					predatorBody = b;
					toDestroy.push_back(predatorBody);
					break;
				}
			}
			 */
		}else{
			predator.illnessTime -= dt;
			[self selectTarget:predator];
			[predator update:dt];
		}
	}
	/*
	std::vector<b2Body *>::iterator pos2;
	for(pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
		b2Body *body = *pos2;     
		_world->DestroyBody(body);
	}*/
}
	
-(void) gameOver{
	CCLabelTTF* gameOverLabel = [[CCLabelTTF alloc] initWithString:@"Game Over" fontName:@"Marker Felt" fontSize:62];
	[self addChild:gameOverLabel z:300 tag:10];
	gameOverLabel.position = _player.position;
	gameOverLabel.opacity = 0;
	CCAction *fadeIn = [CCFadeTo actionWithDuration:1.0 opacity:0];

    [gameOverLabel runAction:fadeIn];
}

-(void) detectGameConditions{
	//first check for gameOver
	if ([_bees count] == 0){
		//Game Over
		_isGameOver = YES;
		[self gameOver];
	}
}


-(void) beeDefaultMovement:(Boid*) bee withDt:(ccTime)dt{
	[bee wander: 0.1f];
	[self separate:bee withSeparationDistance:40.0f usingMultiplier:0.8f];
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



-(void)update:(ccTime)dt{
	_totalTimeElapsed += dt;
	if (_totalTimeElapsed > 1){
		if (_gameStarted){
			_totalTimeElapsed += dt;
			if (_isGameOver == NO){
				//decrease boost, enemy, and illnesstimes
				if (_boostTimeLeft > 0){
					_boostTimeLeft -= dt;
					if (_boostTimeLeft <= 0){
						[self setNormalSpeed];
						[self normalEffect];
						_boostTimeLeft = 0;;
					}
				}	
				
				if (_illnessTimeLeft > 0){
					_illnessTimeLeft -= dt;
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
				_effectSprite.position = ccpAdd(_effectSprite.position, _playerAcceleration);
				_backGround.position = ccp(_player.position.x, _backGround.position.y);
				
				[self removeDeadItems];
				for (Boid* boid in _bees){
					if (_slowestBoid == nil){
						_slowestBoid = boid;
					}else {
						if (boid.maxSpeed < _slowestBoid.maxSpeed){
							_slowestBoid = boid;
						}
					}
				}
				
				
				[self updatePredators:dt];
				[self beeMovement:dt];
				[self removeOutOfScreenItems];
				//update terrain, tell it how far we have proceeded
				[_terrain setOffsetX:_playerAcceleration.x];
				//respawn the clouds if needed
				[self respawnCloud];
				[self respawnForest];
				[self updateBox2DWorld:dt];
				//detect the collisions
				[self detectBox2DCollisions];
				[self setViewpointCenter:_player.position];
				[self detectGameConditions];
				_distanceTravelled = _player.position.x /3 ;
				[self updateLabels];
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

-(void) switchPause{
	if (_paused == NO){
		[self unschedule:@selector(update:)];
		_paused = YES;
	}else{
		_paused = NO;
		[self schedule: @selector(update:)];
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
		//CCAction* actionScaleDone = [CCCallFuncN actionWithTarget:self 
		//selector:@selector(actionScaleFinished:)];
		[_loadingScreen runAction:[CCSequence actions:_moveUpwards, nil]];
	//	[self removeChild:_loadingScreen cleanup:YES];
	//	_loadingScreen = nil;
		_gameStarted = YES;
		[self schedule: @selector(update:)];
	}else if (_gameIsReady && _gameStarted){
		self.currentTouch = [self convertTouchToNodeSpace: touch];
		if (_isGameOver){
			[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.0 scene:[MainMenuScene scene] withColor:ccBLACK]];
		}
	}
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	self.currentTouch = [self convertTouchToNodeSpace: touch];
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



#pragma mark accelerometer

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
	
	float accelerationX = acceleration.x * kFilteringFactor + accelerationX * (1.0 - kFilteringFactor);
	float accelerationY = acceleration.y * kFilteringFactor + accelerationY * (1.0 - kFilteringFactor);
	
	// keep the raw reading, to use during calibrations
	float currentRawReading = atan2(accelerationY, accelerationX);
	
	float rotation = -RadiansToDegrees(currentRawReading);
	
	if (rotation <= 170 && rotation >= 0){
		//right slide
		_playerAcceleration = ccp(1,-1);
	}else {
		if ((rotation >= -170 && rotation < 0)){
			//left slide
			_playerAcceleration = ccp(1,1);
		}else{
			_playerAcceleration = ccp(1,0);
		}
	}
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
}	


@end




