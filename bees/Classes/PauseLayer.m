//
//  PauseLayer.m
//  bees
//
//  Created by macbook white on 9/23/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "PauseLayer.h"

@implementation PauseLayer
@synthesize paused = _paused;
@synthesize pausedMenu = _pausedMenu;
@synthesize moveUpwards = _moveUpwards, moveDownwards = _moveDownwards, moveDone = _moveDone, loadingScreen = _loadingScreen;
@synthesize gameScene = _gameScene;

+(id)scene{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PauseLayer *layer = [PauseLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    if ((self = [super init])){
        self.paused = NO;
       	self.loadingScreen = [CCSprite spriteWithFile:@"curtain1small.png"];
        _loadingScreen.position = ccp(_loadingScreen.contentSize.width/2, _loadingScreen.contentSize.height/2 - 20);
        // Add the UIActivityIndicatorView (in UIKit universe)
		_activity = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge] autorelease];
		_activity.center = ccp(240,190);
		
		_loadingSprite = [CCSprite spriteWithFile:@"loading.png"];
		_loadingSprite.scale = 0.5;
		_loadingSprite.position = ccp(_activity.center.x, _activity.center.y + _loadingSprite.contentSize.height * _loadingSprite.scale);
        
		[self addChild:_loadingSprite z:5001 tag:1001];
		
		[_activity startAnimating];
		[[[CCDirector sharedDirector] openGLView] addSubview:_activity];
        
		[self addChild:_loadingScreen z:5000 tag:1000];
        self.moveUpwards = [[CCMoveTo actionWithDuration:0.5f position:ccp(screenSize.width/2, screenSize.height + screenSize.height/2 + 30)] retain];
        self.moveDownwards = [[CCMoveTo actionWithDuration:0.5f position:ccp(screenSize.width/2, screenSize.height/2)] retain];
    }
    return self;
}

-(void) loadingFinished{
	_tapToStartSprite = [CCSprite spriteWithFile:@"tapToStart.png"];
	_tapToStartSprite.scale = 0.5;
	_tapToStartSprite.position = _loadingSprite.position;
	[self removeChild:_loadingSprite cleanup:YES];
    _loadingSprite = nil;
	[self addChild:_tapToStartSprite z:5002 tag:1001];
	[_activity removeFromSuperview];
}

-(void) startGame{
    [self removeChild:_tapToStartSprite cleanup:YES];
    _tapToStartSprite = nil;
    [self.loadingScreen runAction:self.moveUpwards];
}


-(void) restartButtonTapped:(id)sender{
    if ([[LevelManager sharedManager] world] == 1){
        [[CCDirector sharedDirector] replaceScene:[CampaignScene scene]];
    }else if ([[LevelManager sharedManager] world] == 2){
        [[CCDirector sharedDirector] replaceScene:[CaveScene scene]];
    }if ([[LevelManager sharedManager] world] == 3){
        [[CCDirector sharedDirector] replaceScene:[SeaScene scene]];
    }
}

-(void) quitButtonTapped:(id)sender{
    [[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene]];
}


-(void) createPauseMenu{
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	CCMenuItemImage *button1 = [CCMenuItemImage 
								itemFromNormalImage:@"resume.png" selectedImage:@"resumeTapped.png" 
								target:self.gameScene selector:@selector(switchPause:)];

	CCMenuItemImage *button2 = [CCMenuItemImage 
								itemFromNormalImage:@"restart.png" selectedImage:@"restartTapped.png" 
								target:self selector:@selector(restartButtonTapped:)];
	
	CCMenuItemImage *button3 = [CCMenuItemImage
								itemFromNormalImage:@"quit.png" selectedImage:@"quitTapped.png"
								target:self selector:@selector(quitButtonTapped:)];
	
	_pausedMenu = [CCMenu menuWithItems:button1, button2, button3, nil];
	[self addChild:_pausedMenu z:5001 tag:2];
	
	_pausedMenu.position =  ccp( screenSize.width/2, screenSize.height/2);
	[_pausedMenu alignItemsVerticallyWithPadding:20];
	[_pausedMenu runAction:[CCFadeIn actionWithDuration:0.3]];
}

-(void) switchPause{    
	if (_paused == NO){
		self.moveDone = [CCCallFuncN actionWithTarget:self selector:@selector(createPauseMenu)];
		[_loadingScreen runAction:[CCSequence actions: _moveDownwards, _moveDone, nil]];
		_paused = YES;
	}else{
		_paused = NO;
		CGSize screenSize = [CCDirector sharedDirector].winSize;
        
		[_loadingScreen runAction:self.moveUpwards];
        CCAction* fadeIn = [CCFadeIn actionWithDuration:0.2];
		[_pausedMenu runAction:[CCFadeOut actionWithDuration:0.2]];
		[self removeChild:_pausedMenu cleanup:YES]; 
        _pausedMenu = nil;
	}
}



@end
