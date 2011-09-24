//
//  MainMenuScene.m
//  bees
//
//  Created by macbook white on 7/21/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "MainMenuScene.h"
#import "LevelSelectScene.h"
#import "ConfigManager.h"


@implementation MainMenuScene
@synthesize selectedLevel = _selectedLevel;
@synthesize campaignLevels = _campaignLevels, survivalLevels = _survivalLevels, timeRaceLevels = _timeRaceLevels;
@synthesize emitter = _emitter;

+(id)scene{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object 
	MainMenuScene *layer = [MainMenuScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id)init{
	CGSize size = [[CCDirector sharedDirector] winSize];
	if( (self=[super init] )) {
		_init = YES;
		_emitter = nil;
		[self readInLevels];
		self.selectedLevel = [[NSString alloc] initWithString:@"level1"];
		
		
		
		/*
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"music2.mp3"];
		if (_musicEnabled && !_backGroundMusicStarted){
			[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"music2.mp3" loop:YES];
			_backGroundMusicStarted = YES;
		}
		 */
		
	
		
		CCMenuItemImage *button1 = [CCMenuItemImage 
							itemFromNormalImage:@"play.png" selectedImage:@"playTapped.png" 
							target:self selector:@selector(gameButtonTapped)];
		
	
		
		CCMenuItemImage *button2 = [CCMenuItemImage 
									itemFromNormalImage:@"options.png" selectedImage:@"optionsTapped.png" 
									target:self selector:@selector(optionsButtonTapped)];
		CCMenuItemImage *button3 = [CCMenuItemImage 
									itemFromNormalImage:@"help.png" selectedImage:@"helpTapped.png" 
									target:self selector:@selector(storeButtonTapped)];
		
		_buttonWidth = ccp(button1.contentSize.width, button1.contentSize.height);
		_menu = [CCMenu menuWithItems:button1, button2, button3, nil];
		[self addChild:_menu z:200 tag:2];
		
		_menu.position =  ccp( size.width /4 * 3 + size.width, size.height - 60 - button1.contentSize.height - button2.contentSize.height);
		[_menu alignItemsVerticallyWithPadding:30];
		_menu.opacity =255;
		
		_bgPicture = [CCSprite spriteWithFile:@"mainMenuBg.png"];
		_bgPicture.position = ccp(size.width/2 , size.height/2);
		[self addChild:_bgPicture z:0 tag:1];
		
		_actionMoveIn = [[CCMoveTo actionWithDuration:0.5f
											 position: ccp( size.width - _buttonWidth.x/2, _menu.position.y)] retain];
		_actionMoveOut = [[CCMoveTo actionWithDuration:0.5f position:ccp(size.width + _buttonWidth.x/2, _menu.position.y)] retain];
		_actionMoveDone = [[CCCallFuncN actionWithTarget:self 
											   selector:@selector(menuMoveFinished:)] retain];
		_actionFadeInDone = [[CCCallFuncN actionWithTarget:self 
												selector:@selector(menuFadeInFinished:)] retain];

		[_menu runAction:[CCSequence actions:_actionMoveIn, _actionMoveDone, nil]];
		
		
		[self createAlternativeOptionsMenu];
		[self createPlayMenu];
		
		
		
		if (_soundsEnabled) {
			[[SimpleAudioEngine sharedEngine] preloadEffect:@"tick.wav"];
		}
		
//		_effectSprite = [CCSprite spriteWithFile:@"darkenCornersEffect.png"];
//		_effectSprite.position = ccp(size.width/2,  size.height/2);
//		_effectSprite.scale = 0.5;
//		[self addChild:_effectSprite z:1000 tag:1000];
	}
	
	return self; 
}


#pragma mark create menus

-(void) createPlayMenu{
	CCMenuItemImage *campaignButton = [CCMenuItemImage 
								   itemFromNormalImage:@"campaign.png" selectedImage:@"campaignTapped.png" 
								   target:self selector:@selector(campaignButtonTapped)];
	
	
	CCMenuItemImage *survivalButton = [CCMenuItemImage 
								   itemFromNormalImage:@"survival.png" selectedImage:@"survivalTapped.png" 
								   target:self selector:@selector(survivalButtonTapped)];
	
	
	CCMenuItemImage *timeRaceButton = [CCMenuItemImage 
								   itemFromNormalImage:@"timeRace.png" selectedImage:@"timeRaceTapped.png" 
								   target:self selector:@selector(timeRaceButtonTapped)];
	
	
	CCMenuItemImage *backButton = [CCMenuItemImage 
								   itemFromNormalImage:@"back.png" selectedImage:@"backTapped.png" 
								   target:self selector:@selector(playBackButtonTapped)];
	
	_playMenu = [CCMenu menuWithItems:campaignButton, survivalButton, timeRaceButton, backButton,nil];
	[self addChild:_playMenu z:201 tag:3];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	_playMenu.position =  ccp( size.width /4 * 3 + size.width, size.height - 60 - campaignButton.contentSize.height - survivalButton.contentSize.height);
	[_playMenu alignItemsVerticallyWithPadding:20];
}


-(void)createAlternativeOptionsMenu{
	CCMenuItemImage *musicEnabled = [CCMenuItemImage 
									 itemFromNormalImage:@"music.png" selectedImage:@"music.png" 
									 target:self selector:nil];
	
	CCMenuItemImage *musicDisabled = [CCMenuItemImage 
									  itemFromNormalImage:@"musicUnselected.png" selectedImage:@"musicUnselected.png" 
									  target:self selector:nil];
	
	
	CCMenuItemToggle *musicLabel = [CCMenuItemToggle itemWithTarget:self selector:@selector(musicButtonTapped) items:musicEnabled, musicDisabled, nil];
	
	CCMenuItemImage *soundsEnabled = [CCMenuItemImage 
									  itemFromNormalImage:@"sounds.png" selectedImage:@"sounds.png" 
									  target:self selector:nil];
	
	CCMenuItemImage *soundsDisabled = [CCMenuItemImage 
									   itemFromNormalImage:@"soundsUnselected.png" selectedImage:@"soundsUnselected.png" 
									   target:self selector:nil];
	
	CCMenuItemToggle *soundsLabel = [CCMenuItemToggle itemWithTarget:self selector:@selector(soundButtonTapped) items:soundsEnabled, soundsDisabled, nil];
	
	CCMenuItemImage *vibrationEnabled = [CCMenuItemImage 
										 itemFromNormalImage:@"particles.png" selectedImage:@"particles.png" 
										 target:self selector:nil];
	
	CCMenuItemImage *vibrationDisabled = [CCMenuItemImage 
										  itemFromNormalImage:@"particlesUnselected.png" selectedImage:@"particlesUnselected.png" 
										  target:self selector:nil];
	
	CCMenuItemToggle *tutorialsLabel = [CCMenuItemToggle itemWithTarget:self selector:@selector(vibrationButtonTapped) items:vibrationEnabled, vibrationDisabled, nil];
	
	
	CCMenuItemImage *backButton = [CCMenuItemImage 
								   itemFromNormalImage:@"back.png" selectedImage:@"backTapped.png" 
								   target:self selector:@selector(optionsBackButtonTapped)];
	
	_optionsMenu = [CCMenu menuWithItems:musicLabel, soundsLabel, tutorialsLabel, backButton,nil];
	[self addChild:_optionsMenu z:200 tag:2];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	_optionsMenu.position =  ccp( size.width /4 * 3 + size.width, size.height - 60 - musicLabel.contentSize.height - soundsLabel.contentSize.height);
	[_optionsMenu alignItemsVerticallyWithPadding:20];
	[self readInPropertyList];
	if (!_musicEnabled) {
		[musicLabel activate];
	}
	
	if (!_soundsEnabled){
		[soundsLabel activate];
	}
	
	if (!_particlesEnabled){
		[tutorialsLabel activate];
	}else {
		[self loadParticles];
	}

	_init = NO;
}


#pragma mark property list functions

-(void) readInPropertyList{
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSString *plistPath;
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
															  NSUserDomainMask, YES) objectAtIndex:0];
	plistPath = [rootPath stringByAppendingPathComponent:@"GameInfo.plist"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
		plistPath = [[NSBundle mainBundle] pathForResource:@"GameInfo" ofType:@"plist"];
	}
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
										  propertyListFromData:plistXML
										  mutabilityOption:NSPropertyListMutableContainersAndLeaves
										  format:&format
										  errorDescription:&errorDesc];
	if (!temp) {
		NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
	}
		
	_musicEnabled = [[temp objectForKey:@"Music"] boolValue];
	_soundsEnabled = [[temp objectForKey:@"Sounds"] boolValue];
	_particlesEnabled = [[temp objectForKey:@"Particles"] boolValue];
	
	ConfigManager* sharedManager = [ConfigManager sharedManager];
	
	sharedManager.sounds = _soundsEnabled;
	sharedManager.music = _musicEnabled;
	sharedManager.particles = _particlesEnabled;
}


-(void) savePropertyList{
	NSError* error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"GameInfo.plist"];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath: path]) //4
	{
		NSString *bundle = [[NSBundle mainBundle] pathForResource:@"GameInfo" ofType:@"plist"]; //5
		[fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
	}
	
	NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
	
	[data setObject:[NSNumber numberWithBool: _musicEnabled] forKey:@"Music"];
	[data setObject:[NSNumber numberWithBool: _soundsEnabled] forKey:@"Sounds"];
	[data setObject:[NSNumber numberWithBool: _particlesEnabled] forKey:@"Particles"];
	if(data) {
		[data writeToFile:path atomically:YES];
	}
	else {
		NSLog(error);
		[error release];
	}
	[data release];
}



-(void) readInLevels{
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSString *plistPath;
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
															  NSUserDomainMask, YES) objectAtIndex:0];
	plistPath = [rootPath stringByAppendingPathComponent:@"Levels.plist"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
		plistPath = [[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"];
	}
	
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
										  propertyListFromData:plistXML
										  mutabilityOption:NSPropertyListMutableContainersAndLeaves
										  format:&format
										  errorDescription:&errorDesc];
	if (!temp) {
		NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
	}
	
//	self.campaignLevels = [[NSMutableDictionary alloc] initWithDictionary: (NSDictionary*)[temp objectForKey:@"Campaign"]];
//	self.survivalLevels = [[NSMutableDictionary alloc] initWithDictionary: (NSDictionary*)[temp objectForKey:@"Survival"]];
//	self.timeRaceLevels = [[NSMutableDictionary alloc] initWithDictionary: (NSDictionary*)[temp objectForKey:@"TimeRace"]];

}


#pragma mark playmenu buttons functions
-(void)playBackButtonTapped{
	if (_soundsEnabled && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}
	
	_playMenu.isTouchEnabled = NO;
	[_playMenu runAction:_actionMoveOut];
	[_menu runAction:[CCSequence actions:_actionMoveIn, _actionMoveDone, nil]];
}

-(void)campaignButtonTapped{
	if (_soundsEnabled  && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}
	
	//[[CCDirector sharedDirector] replaceScene: [CCTransitionSlideInR transitionWithDuration:0.5 scene:[CampaignScene scene:@"level1" withDifficulty:1 withType:1]]];
	//[[CCDirector sharedDirector] replaceScene: [CCTransitionSlideInT transitionWithDuration:0.8 scene:[LevelSelectScene scene:CAMPAIGN]]];
	[[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene:CAMPAIGN]];
}

-(void)survivalButtonTapped{
	if (_soundsEnabled  && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}
	
	[[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene:SURVIVAL]];
}

-(void)timeRaceButtonTapped{
	if (_soundsEnabled && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}	
	[[CCDirector sharedDirector] replaceScene: [HiveScene scene]];
}


#pragma mark mainmenu buttons tapped

-(void)gameButtonTapped{
	_menu.isTouchEnabled = NO;
	if (_soundsEnabled && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}
	[_menu runAction:_actionMoveOut];
	[_playMenu runAction:[CCSequence actions:_actionMoveIn, _actionMoveDone, nil]];
}

-(void)optionsButtonTapped{
	if (_soundsEnabled && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}	
	[self readInPropertyList];
	_menu.isTouchEnabled = NO;
	[_menu runAction:_actionMoveOut];
	[_optionsMenu runAction:[CCSequence actions:_actionMoveIn, _actionMoveDone, nil]];
}

-(void)storeButtonTapped{
	if (_soundsEnabled && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}
	
	[[CCDirector sharedDirector] replaceScene: [LevelSelectScene scene]];
}

#pragma mark menu actions

-(void)menuFadeInFinished:(id)sender{
	CCMenu *fadeInFinished = (CCMenu *)sender;
}

-(void)menuMoveFinished:(id)sender {
	CCMenu *moveInFinished = (CCMenu *)sender;
	moveInFinished.isTouchEnabled = YES;
}

#pragma mark particles

-(void) loadParticles{
	CGSize size = [[CCDirector sharedDirector] winSize];
	self.emitter = 	[CCParticleSystemQuad particleWithFile:@"coolLeafs.plist"];
	_emitter.position = ccp(-64,size.width/2);
	[self addChild:_emitter z:500 tag:500];
}

-(void) unloadParticles{
	[self removeChild:_emitter cleanup:YES];
	self.emitter = nil;
}

#pragma mark options buttons tapped

-(void) musicButtonTapped{
	if (_soundsEnabled && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}
	
	if (_musicEnabled){
		if (!_init){
			_musicEnabled = NO;
			[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
			_backGroundMusicStarted = NO;
		}
	}else{
		if (!_init){
			[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"music2.mp3"] ;
			_backGroundMusicStarted = YES;
			_musicEnabled = YES;
		}
	}
	if (!_init){
		[[ConfigManager sharedManager] setMusic:_musicEnabled];
	}
}

-(void) soundButtonTapped{
	if (_soundsEnabled && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}
	
	if (!_init){
		_soundsEnabled = !_soundsEnabled;	
		[[ConfigManager sharedManager] setSounds:_soundsEnabled];
	}
}

-(void) vibrationButtonTapped{
	if (_soundsEnabled && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}
	
	if (!_init){
		_particlesEnabled = !_particlesEnabled;
		[[ConfigManager sharedManager] setParticles:_particlesEnabled];
		if (_particlesEnabled && _emitter == nil){
			[self loadParticles];
		}else if (_emitter != nil){
			[self unloadParticles];
		}
	}
}

-(void) optionsBackButtonTapped{
	if (_soundsEnabled && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}
	
	[self savePropertyList];
	_optionsMenu.isTouchEnabled = NO;
	[_optionsMenu runAction:_actionMoveOut];
	[_menu runAction:[CCSequence actions:_actionMoveIn, _actionMoveDone, nil]];
}

-(void) dealloc{
	
	_emitter = nil;
}


@end
