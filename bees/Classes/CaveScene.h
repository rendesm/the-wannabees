//
//  HelloWorldScene.h
//  bees
//
//  Created by macbook white on 7/18/11.
//  Copyright nincs 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "BeeImports.h"
#import "MyContactFilter.h"


// HelloWorld Layer
@interface CaveScene : CCLayer
{	
    PauseLayer* _pauseLayer;
    HUDLayer* _hudLayer;
	Level* _level;
	bool _updateBox;
	CCProgressTimer* _distanceLeft;
	bool _newHighScore;
	CCMenuItemImage* _resetButton;
	bool _removeRunning ;
	CCParticleSystemQuad *_emitter;
	b2World *_world;
	MyContactListener* _contactListener;
	MyContactFilter* _contactFilter;
	UITouch* _touch1;
	NSMutableArray* _clouds;
	NSMutableArray* _forests;
	CCSprite* _backGround;
	CCSprite* _backGround2;
	CCSprite* _backGround3;
	
	CCLabelBMFont* _goalTimer;
	ccTime _goalTimeLeft;
	ccTime _goalTimeMax;
	int _goal1;
	int _goal2;
	int _goal3;
	
	float _minRockDistance;
	
	CCMenuItemImage* _pauseButton;
	
	NSMutableArray* _bees;
	NSMutableArray* _deadBees;
	
	NSMutableArray* _points;
	NSMutableArray* _takenPoints;
	
	NSMutableArray* _bats;
	NSMutableArray* _deadBats;
	NSMutableArray* _outOfScreenBats;
	
	NSMutableArray* _guanos;
	NSMutableArray* _deadGuanos;
	
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
	bool _isLevelDone;
	CCNode* _particleNode;
	int _distanceTravelled;
	int _distanceToGoal;
	
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
	
	int	_item1Value;
	int _item2Value;
	int _item3Value;
		
	CCSprite* _tree;
	CCSprite* _tree2;
	CCSprite* _tree3;
	
	NSMutableArray *_backgrounds;
	
	CCSprite* _top1;
	CCSprite* _bottom1;
	
	CGPoint _lastPointLocation;
	CGPoint _minBatDistance;
	CGPoint _lastBatPosition;
	CGPoint _lastTopRockLocation;
	CGPoint _lastBottomRockLocation;
	
	int _maxPredatorLife;
	
	int _bonusCount;
	
	CCMenu *_pausedMenu;
	
	NSArray *_topRocks;
	NSArray *_bottomRocks;
	
	ccTime _auEffectLeft;
	
	ComboFinisher* _comboFinisher;
	CGPoint _lastComboFinisher;
	NSMutableArray* _comboFinishers;
	NSMutableArray* _takenCombos;
    
    int _currentDifficulty;
	float _boidCurrentSpeed;
	float _boidCurrentTurn;
	float _predatorCurrentSpeed;
	float _fireBallSpeed;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;
-(id) initWithLayers:(HUDLayer *)hudLayer pause:(PauseLayer *)pauseLayer;
-(void) updateCave;
-(void)updateSounds:(ccTime)dt;
-(void)update:(ccTime)dt;
-(void) updateCurrentDifficulty;

-(void) checkBatRockCollision:(Bat*)bat;
-(void) checkRockBatCollision:(Rock*)rock;

-(void) saveLevelPerformance;
-(void) calculateAndApplyBonus;
-(void) displayBonus;

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
-(void)updateBats:(ccTime)dt;

- (CCSprite *)spriteWithColor:(ccColor4F)bgColor textureSize:(float)textureSize withNoise:(NSString*)inNoise withGradientAlpha:(float)gradientAlpha;
- (ccColor4F)randomBrightColor;
- (ccColor4F)randomBlueColor;
- (ccColor4F)randomGreenColor;
- (void)genBackground;


-(void) bombEffect;
-(void) speedEffect;
-(void) diseaseEffect;
-(void) shrinkEffect;
-(void) normalEffect;
-(void) clearItems;
-(void) clearItemValues;
-(void) generateGoals;
-(void) clearGoals;
-(bool) checkGoals;

-(bool)addItemValue:(int)value;

-(void) removeDeadItems;

-(void) playDeadBeeSound;
-(void) playComboSuccessSound;
/*
-(void) ccTouchesBegan:(NSSet*) touches withEvent:(UIEvent *)event;
-(void) ccTouchesMoved:(NSSet*) touches withEvent:(UIEvent *)event;
-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
 */

-(void)switchPause:(id)sender;

-(void)continueGame;

-(void) updateBox2DWorld:(ccTime)dt;

-(void) removeOutOfScreenAtka;
-(void) removeOutOfScreenSpore;
-(void) generateBats;
-(void) generateNextFinisher:(int) type;
-(void) removeOutOfScreenCombos;

-(void) moveComboToNewPosition:(ComboFinisher*) point;
-(void) moveToCemetery:(Boid*) sprite;
-(void) movePredatorToNewPosition:(Predator*) predator;
-(void) movePointToNewPosition:(Points*) point;
-(void) generateNextPoint:(int)types;

@property(nonatomic, assign) CGPoint currentTouch;
@property(nonatomic) bool paused;
@property(nonatomic, retain) NSMutableArray* backgrounds;
@property(nonatomic, retain) Level* level;

@property(nonatomic, retain) ComboFinisher* comboFinisher;
@property(nonatomic, retain) NSMutableArray* comboFinishers;
@property(nonatomic, retain) PauseLayer* pauseLayer;
@property(nonatomic, retain) HUDLayer* hudLayer;

@end

