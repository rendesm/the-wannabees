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
    CCSprite* _textSprite;
    
    CCLabelBMFont* _loadingFont;
    CCLabelBMFont* _tapToStartFont;
    CCSpriteBatchNode* _batchnode;
    CCLayer*  _gameScene;
    int _highScore;
    int _score;
}

-(void) loadingFinished;
-(void) createPauseMenu;
-(void) switchPause;
-(void) startGame;
-(void) gameOver:(int)score withHighScore:(int)highscore;

@property (nonatomic, retain) CCMenu* pausedMenu;
@property (nonatomic) bool paused;
@property (nonatomic,retain) CCAction* moveUpwards;
@property (nonatomic,retain) CCAction* moveDownwards;
@property (nonatomic,retain) CCAction* moveDone;
@property (nonatomic,retain) CCSprite* loadingScreen;
@property (nonatomic,retain) CCLayer*  gameScene;
@property (nonatomic, retain) CCSpriteBatchNode* batchnode;
@end
