//
//  SeaScene.h
//  bees
//
//  Created by macbook white on 9/21/11.
//  Copyright 2011 nincs. All rights reserved.
//
#import "BeeImports.h"
#import <iAd/iAd.h>
#import "Fish.h"

@interface SeaScene : CCLayer<ADBannerViewDelegate, GKLeaderboardViewControllerDelegate>{
    ADBannerView* _bannerView;
    PauseLayer* _pauseLayer;
    HUDLayer* _hudLayer;
	Level* _level;
	CCProgressTimer* _distanceLeft;
	bool _newHighScore;
	CCMenuItemImage* _resetButton;
	bool _removeRunning ;
	CCParticleSystemQuad *_emitter;
    CCParticleSystemQuad *_rain;
	b2World *_world;
	MyContactListener* _contactListener;
	UITouch* _touch1;
	NSMutableArray* _clouds;
	CCSprite* _backGround;
    CCSprite* _island;
    CCSprite* _overlaySprite;
    CCSprite* _light;
	
	CCLabelBMFont* _goalTimer;
	ccTime _goalTimeLeft;
	ccTime _goalTimeMax;
	int _goal1;
	int _goal2;
	int _goal3;
	
	CCSprite* _rightOrnament;
	CCMenuItemImage* _pauseButton;
	
	NSMutableArray* _bees;
	NSMutableArray* _deadBees;
	NSMutableArray* _cemeteryBees;
	
	NSMutableArray* _points;
	NSMutableArray* _takenPoints;
	
	NSMutableArray* _fish;
	NSMutableArray* _deadFish;
    
    NSMutableArray* _birds;
	
	NSMutableArray* _takenCombos;
	CCParallaxNode* _backGroundNode;
	CGPoint _currentTouch;
	CCSprite* _player;
	CGPoint _playerAcceleration;
	Terrain* _terrain;
	
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
	
	CGPoint _lastPointLocation;
	CGPoint _lastPredatorLocation;
	
	int _maxPredatorLife;
	
	int _bonusCount;
	
	CCMenu *_pausedMenu;
	ccTime _auEffectLeft;
	
	ComboFinisher* _comboFinisher;
	CGPoint _lastComboFinisher;
	NSMutableArray* _comboFinishers;
	
	int _life;
	
	float _minFishDistance;
    float _fishJumpTime;
	NSMutableArray* _bottomSea;
	NSMutableArray* _topSea;
    MessageLayer* _messageLayer;
    float _maxFishJump;
    int _updateBox;
    int _currentDifficulty;
    float _boidCurrentSpeed;
	float _boidCurrentTurn;
	float _predatorCurrentSpeed;
    CCSprite* _boat;
    CCMenu* _pauseMenu;
    HarvesterLayer* _harvesterLayer;
    bool _evilAppearDone;
    
    float _minBirdDistance;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

-(id) initWithLayers:(HUDLayer *)hudLayer pause:(PauseLayer *)pauseLayer message:(MessageLayer *)messageLayer harvester:(HarvesterLayer*)harvesterLayer;

-(id) initWithLayers:(HUDLayer*) hudLayer pause:(PauseLayer*) pauseLayer message:(MessageLayer*) messageLayer;

-(void)updateSounds:(ccTime)dt;
-(void)update:(ccTime)dt;

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
-(void)updatePredators:(ccTime)dt;

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
-(void) removeOutOfScreenCombos;

-(void) playComboSuccessSound;
-(void) playDeadBeeSound;

-(void) updateTerrain;
-(void) respawnTerrain;

-(void) moveToCemetery:(Boid*) sprite;
-(void) movePredatorToNewPosition:(Fish*) predator;
-(void) movePointToNewPosition:(Points*) point;
-(void) moveComboToNewPosition:(ComboFinisher*) point;
-(void) generateNextPoint:(int)types;
-(void) generateNextFinisher:(int) type;

-(void) loadingSounds;
-(void) loadingTerrain;
-(void) loadingTextures;

-(void) lightFadeInDone:(id)sender;
-(void) lightFadeOutDone:(id)sender;

@property(nonatomic, retain)PauseLayer* pauseLayer;
@property int updateBox;
@property(nonatomic, retain)HUDLayer* hudLayer;
@property(nonatomic, assign) CGPoint currentTouch;
@property(nonatomic) bool attackEnabled;
@property(nonatomic) bool evadeEnabled;
@property(nonatomic) bool paused;
@property(nonatomic) float attackBoostIntensity;
@property(nonatomic) float evadeBoostIntensity;
@property(nonatomic, retain) Level* level;
@property(nonatomic, retain) ComboFinisher* comboFinisher;
@property(nonatomic, retain) NSMutableArray* comboFinishers;
@property(nonatomic, retain) MessageLayer* messageLayer;
@property(nonatomic, retain) HarvesterLayer* harvesterLayer;
@property(nonatomic, retain) CCSprite* island;
@property(nonatomic, retain) NSMutableArray* clouds;
@property(nonatomic, retain) CCParticleSystemQuad* rain;
@property(nonatomic, retain) CCSprite* light;
@end
