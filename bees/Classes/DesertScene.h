//
//  DesertScene.h
//  bees
//
//  Created by Mihaly Rendes on 10/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BeeImports.h"

@interface DesertScene : CCLayer {
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
    int _currentDifficulty;
    bool _newHighScore;
    CCMenuItemImage* _pauseButton;
	
    
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
}

-(id) initWithLayers:(HUDLayer *)hudLayer pause:(PauseLayer *)pauseLayer message:(MessageLayer *)messageLayer harvester:(HarvesterLayer*)harvesterLayer background:(HillsBackgroundLayer*) background;
-(void)detectBox2DCollisions;
-(void) updateBox2DWorld:(ccTime)dt;
-(void) beeMovement:(ccTime)dt;

@property (nonatomic, retain) NSMutableArray* bees;
@property (nonatomic, retain) NSMutableArray* deadBees;
@property (nonatomic, retain) NSMutableArray* points;
@property (nonatomic, retain) NSMutableArray* takenPoints;
@property (nonatomic, retain) PauseLayer*               pauseLayer;
@property (nonatomic, retain) HUDLayer*                 hudLayer;
@property (nonatomic, retain) MessageLayer*             messageLayer;
@property (nonatomic, retain) HarvesterLayer*           harvesterLayer;
@property (nonatomic, retain) HillsBackgroundLayer*     bgLayer;
@property (nonatomic, retain) Level*                    level;
@property (nonatomic) CGPoint                           currentTouch;

@end