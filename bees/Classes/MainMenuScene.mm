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
#import "GameCenterHelper.h"
#import "HelpScene.h"

@implementation MainMenuScene
@synthesize selectedLevel = _selectedLevel;
@synthesize campaignLevels = _campaignLevels, survivalLevels = _survivalLevels, timeRaceLevels = _timeRaceLevels;
@synthesize emitter = _emitter;
@synthesize aboutMenu = _aboutMenu;

static int messageNumber = 1;

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
		
		CCMenuItemImage *button1 = [CCMenuItemImage 
							itemFromNormalImage:@"play.png" selectedImage:@"playTapped.png" 
							target:self selector:@selector(gameButtonTapped)];
		
		CCMenuItemImage *button2 = [CCMenuItemImage 
									itemFromNormalImage:@"options.png" selectedImage:@"optionsTapped.png" 
									target:self selector:@selector(optionsButtonTapped)];
		CCMenuItemImage *button3 = [CCMenuItemImage 
									itemFromNormalImage:@"credits.png" selectedImage:@"creditsTapped.png" 
									target:self selector:@selector(storeButtonTapped)];
		
		_buttonWidth = ccp(button1.contentSize.width, button1.contentSize.height);
		_menu = [CCMenu menuWithItems:button1, button2, button3, nil];
		[self addChild:_menu z:200 tag:2];
		
		_menu.position =  ccp( size.width /4 * 3 + size.width, size.height - 60 - button1.contentSize.height - button2.contentSize.height);
		[_menu alignItemsVerticallyWithPadding:30];
		
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
        [self createAboutMenu];
		
		
		
		if (_configManager.sounds) {
			[[SimpleAudioEngine sharedEngine] preloadEffect:@"tick.wav"];
		}
        
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.8];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"Wannabeesmenu.caf"];
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.7];
		if (_configManager.music && ![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]){
			[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Wannabeesmenu.caf" loop:YES];
			_backGroundMusicStarted = YES;
		}
	}
	
	return self; 
}

-(void) createAboutMenu{
    CCMenuItemImage *backButton = [CCMenuItemImage 
								   itemFromNormalImage:@"back.png" selectedImage:@"backTapped.png" 
								   target:self selector:@selector(aboutBackButtonTapped)];
    self.aboutMenu = [CCMenu menuWithItems:backButton,nil];
	[self addChild:self.aboutMenu z:201 tag:3];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	self.aboutMenu.position =  ccp( size.width /4 * 3 + size.width, 60 + backButton.contentSize.height/2);
	[self.aboutMenu alignItemsVerticallyWithPadding:20];
}

#pragma mark create menus

-(void) helpButtonTapped{
    if (_configManager.sounds && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}
    [[CCDirector sharedDirector] replaceScene:[HelpScene scene]];
}

-(void) createPlayMenu{	
	CCMenuItemImage *survivalButton = [CCMenuItemImage 
								   itemFromNormalImage:@"survival.png" selectedImage:@"survivalTapped.png" 
								   target:self selector:@selector(survivalButtonTapped)];

    CCMenuItemImage *help = [CCMenuItemImage 
                                itemFromNormalImage:@"help.png" selectedImage:@"helpTapped.png" 
                                target:self selector:@selector(helpButtonTapped)];
	
	CCMenuItemImage *backButton = [CCMenuItemImage 
								   itemFromNormalImage:@"back.png" selectedImage:@"backTapped.png" 
								   target:self selector:@selector(playBackButtonTapped)];
	
	//_playMenu = [CCMenu menuWithItems:campaignButton, survivalButton, timeRaceButton, backButton,nil];
    _playMenu = [CCMenu menuWithItems:survivalButton, help, backButton,nil];
	[self addChild:_playMenu z:201 tag:3];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	_playMenu.position =  ccp( size.width /4 * 3 + size.width, size.height - 60 - survivalButton.contentSize.height - survivalButton.contentSize.height);
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
	

    _optionsMenu = [CCMenu menuWithItems:musicLabel, soundsLabel, tutorialsLabel, backButton, nil];
	[self addChild:_optionsMenu z:200 tag:2];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	_optionsMenu.position =  ccp( size.width /4 * 3 + size.width, size.height - 60 - musicLabel.contentSize.height - soundsLabel.contentSize.height);
	[_optionsMenu alignItemsVerticallyWithPadding:20];
	[self readInPropertyList];
	if (!_configManager.music) {
		[musicLabel activate];
	}
	
	if (!_configManager.sounds){
		[soundsLabel activate];
	}
   [self loadParticles];
	if (!_configManager.particles){
		[tutorialsLabel activate];
	}
	_init = NO;
}


#pragma mark property list functions

-(void) readInPropertyList{
	_configManager = [ConfigManager sharedManager];		
}


-(void) savePropertyList{
	[_configManager savePropertyList];
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
#pragma mark aboutmenu button 

- (void) aboutBackButtonTapped{
    messageNumber = 0;
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    if (_configManager.sounds && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}
    CCAction* moveOut = [CCMoveTo actionWithDuration:0.5f position:ccp(size.width + _buttonWidth.x/2, _aboutMenu.position.y)] ;
    _aboutMenu.isTouchEnabled = NO;
    [_aboutMenu runAction:moveOut];
	[_menu runAction:[CCSequence actions:_actionMoveIn, _actionMoveDone, nil]];
}

-(void) showCredits{
    [self createMessage:@"Created by" scale:0.6];
}


-(void) messageDone:(id)sender{
    switch (messageNumber) {
        case 0:
            messageNumber = 1;
            break;
        case 1:
            messageNumber = 2;
            [self createMessage:@"Mihaly Rendes" scale:0.4];
            break;
        
        case 2:
            messageNumber = 3;
            [self createMessage:@"Artwork by" scale:0.6];
            break;
            
        case 3:
            messageNumber = 4;
            [self createMessage:@"Katalin Balogh" scale:0.4];
            break;
            
        case 4:
            messageNumber = 5;
            [self createMessage:@"Music by" scale:0.6];
            break;
            
        case 5:
            messageNumber = 6;
            [self createMessage:@"Peter Rendes" scale:0.4];
            break;
            
        case 6:
            messageNumber = 7;
            [self createMessage:@"Boids based on the work of" scale:0.25];
            break;
        case 7:
            messageNumber = 8;
            [self createMessage:@"Mario Gonzalez" scale:0.4];
            break;
            
        case 8:
            messageNumber = 9;
            [self createMessage:@"Justin Windle" scale:0.4];
            break;
            
        case 9:
            messageNumber = 10;
            [self createMessage:@"Special thanks to" scale:0.4];
            break;
            
        case 10:
            messageNumber = 11;
            [self createMessage:@"Ray Wenderlich" scale:0.4];
            break;
        default:
            break;
    }
}

-(void) createMessage:(NSString*)message scale:(float)scale{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    CCLabelBMFont* renderedMessage = [[CCLabelBMFont alloc] initWithString:message fntFile:@"markerfelt.fnt"];
    renderedMessage.position = ccp(screenSize.width/2, screenSize.height * 0.75);
    renderedMessage.scale = 0;
    [self addChild:renderedMessage];
    CCAction* scaleIn = [CCScaleTo actionWithDuration:0.5 scale:scale];
    CCAction *fadeOut = [CCFadeOut actionWithDuration:1.5];
    CCAction *callback = [CCCallFunc actionWithTarget:self selector:@selector(messageDone:)];
    [renderedMessage runAction:[CCSequence actions:scaleIn, fadeOut, callback, nil]];
}

#pragma mark playmenu buttons functions
-(void)playBackButtonTapped{
	if (_configManager.sounds && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}
	
	_playMenu.isTouchEnabled = NO;
	[_playMenu runAction:_actionMoveOut];
	[_menu runAction:[CCSequence actions:_actionMoveIn, _actionMoveDone, nil]];
}


-(void)campaignButtonTapped{
	if (_configManager.sounds  && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}
	
	//[[CCDirector sharedDirector] replaceScene: [CCTransitionSlideInR transitionWithDuration:0.5 scene:[CampaignScene scene:@"level1" withDifficulty:1 withType:1]]];
	//[[CCDirector sharedDirector] replaceScene: [CCTransitionSlideInT transitionWithDuration:0.8 scene:[LevelSelectScene scene:CAMPAIGN]]];
	[[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene:CAMPAIGN]];
}

-(void)survivalButtonTapped{
	if (_configManager.sounds  && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}
	
	[[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene:SURVIVAL]];
}

-(void)timeRaceButtonTapped{
	if (_configManager.sounds && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}	
	[[CCDirector sharedDirector] replaceScene: [HiveScene scene]];
}


#pragma mark mainmenu buttons tapped

-(void)gameButtonTapped{
	_menu.isTouchEnabled = NO;
	if (_configManager.sounds && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}
	[_menu runAction:_actionMoveOut];
	[_playMenu runAction:[CCSequence actions:_actionMoveIn, _actionMoveDone, nil]];
}

-(void)optionsButtonTapped{
	if (_configManager.sounds && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}	
	[self readInPropertyList];
	_menu.isTouchEnabled = NO;
	[_menu runAction:_actionMoveOut];
	[_optionsMenu runAction:[CCSequence actions:_actionMoveIn, _actionMoveDone, nil]];
}

-(void)storeButtonTapped{
    messageNumber = 1;
    CGSize size = [[CCDirector sharedDirector] winSize];
	if (_configManager.sounds && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}
    _menu.isTouchEnabled = NO;
	[_menu runAction:_actionMoveOut];
    CCAction* moveIn = [CCMoveTo actionWithDuration:0.5f
                                         position: ccp( size.width - _buttonWidth.x/2, _aboutMenu.position.y)];
    [self.aboutMenu runAction:[CCSequence actions:moveIn, _actionMoveDone, nil]];
    [self showCredits];
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
	if (_configManager.sounds && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}
	
	if (_configManager.music){
		if (!_init){
            [[ConfigManager sharedManager] setMusic:NO];
			[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
			_backGroundMusicStarted = NO;
		}
	}else{
		if (!_init){
			[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Wannabeesmenu.caf"] ;
			_backGroundMusicStarted = YES;
			[[ConfigManager sharedManager] setMusic:YES];
		}
	}
	if (!_init){
		
	}
}

-(void) soundButtonTapped{
	if (_configManager.sounds && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}
	
	if (!_init){
		[[ConfigManager sharedManager] switchSounds];
	}
}

-(void) vibrationButtonTapped{
	if (_configManager.sounds && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}
	
	if (!_init){
		[[ConfigManager sharedManager] switchParticles];
        if ([[ConfigManager sharedManager] particles]){
            UIAlertView* dialog = [[UIAlertView alloc] init];
            [dialog setDelegate:self];
            [dialog setTitle:@"Particles"];
            [dialog setMessage:@"For perfect performance, ingame particles require Iphone4S device"];
            [dialog addButtonWithTitle:@"Understood"];
            [dialog show];
            [dialog release];
        }
	}
}

-(void) gfxButtonTapped{
    if (_configManager.sounds && !_init){
        [[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
    }
    
    if (!_init){
        [_configManager incrGfx];
    }
}

-(void) optionsBackButtonTapped{
	if (_configManager.sounds && !_init){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}
	
	[self savePropertyList];
	_optionsMenu.isTouchEnabled = NO;
	[_optionsMenu runAction:_actionMoveOut];
	[_menu runAction:[CCSequence actions:_actionMoveIn, _actionMoveDone, nil]];
}

-(void) dealloc{
	_emitter = nil;
    [super dealloc];
}


@end
