//
//  HelloWorldScene.h
//  bees
//
//  Created by macbook white on 7/18/11.
//  Copyright nincs 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "BeeImports.h"
#import <iAd/iAd.h>
#import "beesAppDelegate.h"

// HelloWorld Layer
@interface CampaignScene : CCLayer<ADBannerViewDelegate, GKLeaderboardViewControllerDelegate>
{	
    GLESDebugDraw *_debugDraw;

    ADBannerView* _bannerView;
	Level* _level;
    CCMenu* _pauseMenu;
	bool _updateBox;
	CCProgressTimer* _distanceLeft;
	bool _newHighScore;
	CCMenuItemImage* _resetButton;
	//bool _removeRunning ;
	CCParticleSystemQuad *_emitter;
	b2World *_world;
	MyContactListener* _contactListener;
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
	
	CCSprite* _rightOrnament;
	CCMenuItemImage* _pauseButton;
	
	NSMutableArray* _bees;
	NSMutableArray* _deadBees;
	NSMutableArray* _cemeteryBees;
	
	NSMutableArray* _points;
	NSMutableArray* _takenPoints;
	
	NSMutableArray* _predators;
	NSMutableArray* _deadPredators;
	
	NSMutableArray* _takenCombos;
	
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
	
	ccTime _timeTillNextScreen;
	int _pointsGathered;
		
	bool _paused;
	float _attackBoostIntensity;
	float _evadeBoostIntensity;
	
	bool _touchEnded;
	Fish* _fireBall;
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
	bool _gameIsReady;
	bool _gameStarted;
	
	Alchemy* _alchemy;
	
	int	_item1Value;
	int _item2Value;
	int _item3Value;
		
	CCSprite* _tree;
	CCSprite* _tree2;
	CCSprite* _tree3;
    CCSprite* _farSprite;
	
	CCSprite* _hills1;
	CCSprite* _hills2;
	
	CGPoint _lastPointLocation;
	CGPoint _lastPredatorLocation;
	
	int _maxPredatorLife;
	
	int _bonusCount;
	
	CCMenu *_pausedMenu;
	ccTime _auEffectLeft;
	
	ComboFinisher* _comboFinisher;
	CGPoint _lastComboFinisher;
	NSMutableArray* _comboFinishers;
	
	int _currentDifficulty;
	float _boidCurrentSpeed;
	float _boidCurrentTurn;
	float _predatorCurrentSpeed;
	float _fireBallSpeed;
    float _fireBallChance;
    float _atkaChance;
    float _minPredatorDistance;
	HUDLayer* _hudLayer;
    PauseLayer* _pauseLayer;
    MessageLayer* _messageLayer;
    HarvesterLayer* _harvesterLayer;
    HillsBackgroundLayer* _bgLayer;
    CCSprite* _backHill1;
    CCSprite* _backHill2;
    float _lastFishLocation;
    float _maxFishJump;
    NSMutableArray* _fish;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

-(id) initWithLayers:(HUDLayer*) hudLayer pause:(PauseLayer*) pauseLayer message:(MessageLayer*) messageLayer harvester:(HarvesterLayer*)harvesterLayer bgLayer:(HillsBackgroundLayer*)bgLayer;


-(void)updateSounds:(ccTime)dt;
-(void)update:(ccTime)dt;
-(void) updateLabels:(ccTime)dt;

-(void) saveLevelPerformance;
-(void) calculateAndApplyBonus;
-(void) displayBonus;

-(void) separate:(Boid*)bee withSeparationDistance:(float)separationDistance usingMultiplier:(float)multiplier;
-(void) align:(Boid*)bee withAlignmentDistance:(float)neighborDistance usingMultiplier:(float)multiplier;
-(void) cohesion:(Boid*)bee withNeighborDistance:(float)neighborDistance usingMultiplier:(float)multiplier;

-(void) beeDefaultMovement:(Boid*) bee withDt:(ccTime)dt;
-(void) beeMovement:(ccTime)dt;
-(void)selectTarget:(Predator*)predator;
-(void) shrinkEffectDone;

-(void)setViewpointCenter:(CGPoint) position;
-(void)updatePredators:(ccTime)dt;

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
-(CCSprite*)createGoalSprite:(CCSprite*) sprite forGoal:(int)goal;

-(bool)addItemValue:(int)value;

-(void) removeDeadItems;
/*
-(void) ccTouchesBegan:(NSSet*) touches withEvent:(UIEvent *)event;
-(void) ccTouchesMoved:(NSSet*) touches withEvent:(UIEvent *)event;
-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
 */

-(void) switchPause:(id)sender;

-(void) updateBox2DWorld:(ccTime)dt;

-(void) removeOutOfScreenAtka;
-(void) removeOutOfScreenSpore;
-(void) generatePredators;
-(void) removeOutOfScreenCombos;

-(void) playComboSuccessSound;
-(void) playDeadBeeSound;
-(void) beeMovement:(ccTime)dt;

-(void) moveToCemetery:(Boid*) sprite;
-(void) movePredatorToNewPosition:(Predator*) predator;
-(void) movePointToNewPosition:(Points*) point;
-(void) moveComboToNewPosition:(ComboFinisher*) point;
-(void) generateNextPoint:(int)types;
-(void) generateNextFinisher:(int) type;
-(void) presentGameCenter;

@property(nonatomic, assign) CGPoint currentTouch;
@property(nonatomic) bool attackEnabled;
@property(nonatomic) bool evadeEnabled;
@property(nonatomic) bool paused;
@property(nonatomic) float attackBoostIntensity;
@property(nonatomic) float evadeBoostIntensity;
@property(nonatomic, retain) Level* level;
@property(nonatomic, retain) ComboFinisher* comboFinisher;
@property(nonatomic, retain) NSMutableArray* comboFinishers;
@property(nonatomic, retain) HUDLayer* hudLayer;
@property(nonatomic, retain) PauseLayer* pauseLayer;
@property(nonatomic, retain) MessageLayer* messageLayer;
@property(nonatomic, retain) HarvesterLayer* harvesterLayer;
@property(nonatomic, retain) HillsBackgroundLayer* bgLayer;
@property(nonatomic, retain) NSMutableArray* fish;
@end

