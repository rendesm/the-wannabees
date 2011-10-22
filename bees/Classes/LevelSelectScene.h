//
//  LevelSelectScene.h
//  bees
//
//  Created by macbook white on 8/21/11.
//  Copyright 2011 nincs. All rights reserved.
//
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "Level.h"
#import "TypeEnums.h"
#import "ConfigManager.h"
#import "LevelSelectHills.h"
#import "LevelManager.h"


@class CampaignScene;
@class MainMenuScene;
@class Level;
@class CaveScene;
@class LevelSelectHills;

@interface LevelSelectScene : CCLayer {
	CCSprite *_planet;
	CCSprite *_bgPicture;
	CCMenu *_difficultyMenu;
	CCMenu *_launchMenu;
	CCMenuItemImage *_easy;
	CCMenuItemImage *_medium;
	CCMenuItemImage *_hard;
	int _difficulty;
	float _buttonWidth;
	NSMutableDictionary* _levels;
	NSString* _selectedLevel;
	int _selectedLevelTag;
	CCMenu* _levelSelectMenu;
	CGPoint _source;
	CCAction* _planetAction;
	bool _planetWasTouched;
	bool _rotateDone;
	int _selectedWorld;
	ccTime _delayTime;
	CCParticleSystemQuad *_emitter;
}

@property (nonatomic, retain) NSMutableDictionary* levels;
@property (nonatomic, retain) NSString* selectedLevel;
@property (nonatomic, retain) CCAction* planetAction;
@property (nonatomic, retain) CCParticleSystemQuad *emitter;

+(id)scene:(int)type;
-(void) menuMoveFinished:(id)sender;
-(void) backButtonTapped:(id)sender;
-(void) launchButtonTapped:(id)sender;
-(void) rotateDone:(id)sender;
-(void) delay:(ccTime)dt;
-(void) initMenus;
-(void) readInLevels;
@end
