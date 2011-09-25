//
//  PauseLayer.h
//  bees
//
//  Created by macbook white on 9/23/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LevelSelectScene.h"
#import "LevelManager.h"
@class SeaScene;
@interface PauseLayer : CCLayer {
    bool _paused;
    CCMenu* _pausedMenu;
    CCAction* _moveUpwards;
    CCAction* _moveDownwards;
    CCAction* _moveDone;
    CCSprite* _loadingScreen;
    UIActivityIndicatorView* _activity;
    CCSprite* _loadingSprite;
    CCSprite* _tapToStartSprite;
    
    CCLayer*  _gameScene;
}

-(void) loadingFinished;
-(void) createPauseMenu;
-(void) switchPause;
-(void) startGame;

@property (nonatomic, retain) CCMenu* pausedMenu;
@property (nonatomic) bool paused;
@property (nonatomic,retain) CCAction* moveUpwards;
@property (nonatomic,retain) CCAction* moveDownwards;
@property (nonatomic,retain) CCAction* moveDone;
@property (nonatomic,retain) CCSprite* loadingScreen;
@property (nonatomic,retain) CCSprite* tapToStartSprite;
@property (nonatomic,retain) CCLayer*  gameScene;
@end
