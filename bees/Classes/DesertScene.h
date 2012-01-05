//
//  DesertScene.h
//  bees
//
//  Created by Mihaly Rendes on 10/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BeeImports.h"
#import <iAd/iAd.h>

@interface DesertScene  : CCLayer<ADBannerViewDelegate, GKLeaderboardViewControllerDelegate>{
    ADBannerView* _bannerView;
    GLESDebugDraw *_debugDraw;
    //layers
    PauseLayer* _pauseLayer;
    HUDLayer* _hudLayer;
    MessageLayer* _messageLayer;
    HarvesterLayer* _harvesterLayer;
    HillsBackgroundLayer* _bgLayer;
    
    //other objects
	Level* _level;
    CCMenu* _pauseMenu;
    
    //game states
    bool _paused;
    bool _gameIsReady;
    bool _gameStarted;
    bool _isGameOver;
    ccTime _totalTimeElapsed;
    
    //Bonus
    int _bonusCount;
    int _pointsGathered;
    int _goal1;
	int _goal2;
	int _goal3;
    int _item1Value;
    int _item2Value;
    int _item3Value;
    int _currentDifficulty;
    bool _newHighScore;
    CCMenuItemImage* _pauseButton;
    
    Snake* _snake;
	ccTime _timeSinceEnemy2;
    ccTime _timeUntilEnemy2;
    float _predatorCurrentSpeed;
    
    NSMutableArray* _scarabs;
	NSMutableArray* _bees;
	NSMutableArray* _deadBees;
    NSMutableArray* _points;
    NSMutableArray* _takenPoints;
    Boid* _slowestBoid;
    
    CGPoint _currentTouch;
    bool _touchEnded;

	CCSprite* _player;
	CGPoint _playerAcceleration;

    float _boidCurrentSpeed;
    float _boidCurrentTurn;
    
    //Box2d
    b2World *_world;
	MyContactListener* _contactListener;
    
    ccTime _auEffectLeft;
    
    CCSpriteBatchNode* _batchNode;
    
    CGPoint _lastPointLocation;
    Alchemy* _alchemy;
    ccTime _timeUntilScarabs;
    float  _scarabTime;
    float  _scarabSpeed;
}

-(id) initWithLayers:(HUDLayer *)hudLayer pause:(PauseLayer *)pauseLayer message:(MessageLayer *)messageLayer harvester:(HarvesterLayer*)harvesterLayer background:(HillsBackgroundLayer*) background;
-(void)detectBox2DCollisions;
-(void) updateBox2DWorld:(ccTime)dt;
-(void) beeMovement:(ccTime)dt;
-(void) generateGoals;
-(void) clearItemValues;
-(void) clearItems;
-(void) clearGoals;
-(void) cohesion:(Boid*)bee withNeighborDistance:(float)neighborDistance usingMultiplier:(float)multiplier;
-(void) align:(Boid*)bee withAlignmentDistance:(float)neighborDistance usingMultiplier:(float)multiplier;
-(void) separate:(Boid*)bee withSeparationDistance:(float)separationDistance usingMultiplier:(float)multiplier;

-(void) separateScarab:(Predator*)bee withSeparationDistance:(float)separationDistance usingMultiplier:(float)multiplier;
-(void) alignScarab:(Predator*)bee withAlignmentDistance:(float)neighborDistance usingMultiplier:(float)multiplier;
-(void) cohesionScarab:(Predator*)bee withNeighborDistance:(float)neighborDistance usingMultiplier:(float)multiplier;

-(bool) addItemValue:(int)value;
-(void) saveLevelPerformance;
-(void) updateSounds:(ccTime)dt;

@property (nonatomic, retain) NSMutableArray*           bees;
@property (nonatomic, retain) NSMutableArray*           deadBees;
@property (nonatomic, retain) NSMutableArray*           points;
@property (nonatomic, retain) NSMutableArray*           takenPoints;
@property (nonatomic, retain) PauseLayer*               pauseLayer;
@property (nonatomic, retain) HUDLayer*                 hudLayer;
@property (nonatomic, retain) MessageLayer*             messageLayer;
@property (nonatomic, retain) HarvesterLayer*           harvesterLayer;
@property (nonatomic, retain) HillsBackgroundLayer*     bgLayer;
@property (nonatomic, retain) Level*                    level;
@property (nonatomic) CGPoint                           currentTouch;
@property (nonatomic, retain) Snake*                    snake;
@property (nonatomic, retain) NSMutableArray*           scarabs;

@end
