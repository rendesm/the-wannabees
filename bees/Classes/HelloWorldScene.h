//
//  HelloWorldScene.h
//  bees
//
//  Created by macbook white on 7/18/11.
//  Copyright nincs 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "BeeImports.h"



// HelloWorld Layer
@class UILayer;
@interface HelloWorld : CCLayer
{	
	bool _removeRunning ;

	
	CCParticleSystemQuad *_emitter;
	b2World *_world;
	MyContactListener* _contactListener;
	UITouch* _touch1;
	NSMutableArray* _clouds;
	NSMutableArray* _forests;
	CCSprite* _backGround;
	CCSprite* _backGround2;
	CCSprite* _backGround3;
	
	CCSprite* _rightOrnament;
	CCMenuItemImage* _pauseButton;
	
	NSMutableArray* _bees;
	NSMutableArray* _deadBees;
	
	NSMutableArray* _points;
	NSMutableArray* _takenPoints;
	
	NSMutableArray* _predators;
	NSMutableArray* _deadPredators;
	NSMutableArray* _outOfScreenPredators;
	
	CGPoint _currentTouch;
	CCSprite* _player;
	CGPoint _playerAcceleration;
	Terrain* _terrain;
	
	CCParallaxNode* _backGroundNode;
	ccTime _totalTimeElapsed;
	ccTime _timeUntilNextWave;
	Boid* _slowestBoid;
	CGRect _boidCollectiveRect;
	bool _isGameOver;
	UILayer* _uiLayer;
	CCNode* _particleNode;
	int _distanceTravelled;
	
	CCSprite *_pointsSprite;
	CCLabelTTF* _pointsLabel;
	ccTime _timeTillNextScreen;
	int _pointsGathered;
		
	bool _paused;
	float _attackBoostIntensity;
	float _evadeBoostIntensity;
	
	bool _touchEnded;
	Spore* _fireBall;
	Atka* _atka;
	
	bool _beeSick;
	CGPoint _boostSpeed;
	CGPoint _normalSpeed;
	CGPoint	_sickSpeed;
	CCSpriteBatchNode* _batchNode;
	
	bool _atkaOutOfScreen;
	bool _sporeOutOfScreen;
	ccTime _boostTimeLeft;
	ccTime _illnessTimeLeft;
	ccTime _sizeModTimeLeft;
	bool _shrinked;
	
	//loadingScreen
	CCSprite* _loadingScreen;
	bool _gameIsReady;
	bool _gameStarted;
	CCSprite* _loadingSprite;
	CCSprite* _tapToStartSprite;
	UIActivityIndicatorView* _activity;
	
	Alchemy* _alchemy;
	CCSprite* _effectSprite;
	
	CCSprite* _slot1;
	CCSprite* _slot2;
	CCSprite* _slot3;
	CCSprite *_ornament1;
	CCSprite *_ornament2;
	CCSprite *_ornament3;
	
	CCSprite *_item1;
	CCSprite *_item2;
	CCSprite *_item3;
	
	CCSprite* _tree;
	
	CGPoint _lastPointLocation;
	CGPoint _lastPredatorLocation;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;
+(id) scene:(Level*)level withDifficulty:(int) difficulty withType:(int)levelType;
-(void)update:(ccTime)dt;
-(void) separate:(Boid*)bee withSeparationDistance:(float)separationDistance usingMultiplier:(float)multiplier;
-(void) align:(Boid*)bee withAlignmentDistance:(float)neighborDistance usingMultiplier:(float)multiplier;
-(void) cohesion:(Boid*)bee withNeighborDistance:(float)neighborDistance usingMultiplier:(float)multiplier;

-(void) sortBees;
-(void) beeDefaultMovement:(Boid*) bee withDt:(ccTime)dt;
-(void) beeMovement:(ccTime)dt;
-(void)selectTarget:(Predator*)predator;
-(void) shrinkEffectDone;

-(void)setViewpointCenter:(CGPoint) position;
-(void)initActions;
-(void) actionScaleFinished:(id)sender;
-(void)updatePredators:(ccTime)dt;

- (CCSprite *)spriteWithColor:(ccColor4F)bgColor textureSize:(float)textureSize withNoise:(NSString*)inNoise withGradientAlpha:(float)gradientAlpha;
- (ccColor4F)randomBrightColor;
- (ccColor4F)randomBlueColor;
- (ccColor4F)randomGreenColor;
- (void)genBackground;

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;

-(void) bombEffect;
-(void) speedEffect;
-(void) diseaseEffect;
-(void) shrinkEffect;
-(void) normalEffect;

-(void)addItem:(NSString*)item;

-(void) removeDeadItems;
-(void) removeDeadPoint:(Points*)point;
/*
-(void) ccTouchesBegan:(NSSet*) touches withEvent:(UIEvent *)event;
-(void) ccTouchesMoved:(NSSet*) touches withEvent:(UIEvent *)event;
-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
 */

-(void)switchPause:(id)sender;

-(void)continueGame;

-(void)generateCollectables;

-(void) updateBox2DWorld:(ccTime)dt;

-(void) removeOutOfScreenAtka;
-(void) removeOutOfScreenSpore;
-(void) generatePredators;


-(void) moveToCemetery:(Boid*) sprite;
-(void) movePredatorToNewPosition:(Predator*) predator;
-(void) movePointToNewPosition:(Points*) point;
-(void) generateNextPoint:(int)types;

@property(nonatomic, assign) CGPoint currentTouch;
@property(nonatomic, retain) UILayer* uiLayer;
@property(nonatomic) bool attackEnabled;
@property(nonatomic) bool evadeEnabled;
@property(nonatomic) bool paused;
@property(nonatomic) float attackBoostIntensity;
@property(nonatomic) float evadeBoostIntensity;
@end

