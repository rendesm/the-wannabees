//
//  MainMenuScene.h
//  bees
//
//  Created by macbook white on 7/21/11.
//  Copyright 2011 nincs. All rights reserved.
//
#import "cocos2d.h"
#import "Boid.h"
#import "SimpleAudioEngine.h"
#import "HiveScene.h"

//#import "LevelSelectScene.h"

@class HelloWorld;
@class CampaignScene;
@class LevelSelectScene;
@class ConfigManager;
@interface MainMenuScene : CCLayer {
	CCMenu* _menu;
	CGPoint _source;
	CCSprite* _bgPicture;
	CGPoint _buttonWidth;
	CCMenu* _optionsMenu;
	CCMenu* _playMenu;
	CCMenu* _labelMenu;
	CCAction* _actionMoveIn;
	CCAction* _actionMoveOut;
	CCAction* _actionMoveDone;
	CCAction* _actionFadeInDone;
	
	CCMenuItemToggle* _tutorialsLabel;
	CCMenuItemToggle* _soundLabel;
	CCMenuItemToggle* _musicLabel;
	
	CCParticleSystemQuad *_emitter;
	
	CCSprite* _effectSprite;
	
	bool _backGroundMusicStarted;
	
	NSMutableDictionary* _campaignLevels;
	NSMutableDictionary* _survivalLevels;
	NSMutableDictionary* _timeRaceLevels;
	NSString* _selectedLevel;
	bool _init;
    ConfigManager* _configManager;
    
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

-(void) gameButtonTapped;
-(void) storeButtonTapped;
-(void) optionsButtonTapped;
-(void) createOptionsMenu;

-(void) musicButtonTapped;
-(void) soundButtonTapped;
-(void) vibrationButtonTapped;
-(void) optionsBackButtonTapped;

-(void)playBackButtonTapped;
-(void)campaignButtonTapped;
-(void)survivalButtonTapped;
-(void)timeRaceButtonTapped;

-(void)menuMoveFinished:(id)sender;
-(void)menuFadeInFinished:(id)sender;

-(void) readInPropertyList;
-(void) savePropertyList;

-(void) readInLevels;

-(void) loadParticles;
-(void) unloadParticles;

@property (nonatomic, retain) NSString* selectedLevel;
@property (nonatomic, retain) NSMutableDictionary* campaignLevels;
@property (nonatomic, retain) NSMutableDictionary* survivalLevels;
@property (nonatomic, retain) NSMutableDictionary* timeRaceLevels;
@property (nonatomic, retain) CCParticleSystemQuad *emitter;

@end
