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
@synthesize batchnode = _batchnode;

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
        
        _loadingFont = [[CCLabelBMFont alloc] initWithString:@"Loading..." fntFile:@"markerfelt.fnt"];
        _loadingFont.scale = 0.4;
        _loadingFont.position = ccp(_loadingFont.contentSize.width/2* _loadingFont.scale + 60, screenSize.height/5 - 5);
        
        [self addChild:_loadingFont z:5002 tag:1000];
		
		[_activity startAnimating];
		[[[CCDirector sharedDirector] openGLView] addSubview:_activity];
        
		[self addChild:_loadingScreen z:5000 tag:1000];
        self.moveUpwards = [CCMoveTo actionWithDuration:0.5f position:ccp(screenSize.width/2, screenSize.height + screenSize.height/2 + 30)];
        self.moveDownwards = [CCMoveTo actionWithDuration:0.5f position:ccp(screenSize.width/2, screenSize.height/2)];
    
    }
    return self;
}

-(void) loadingFinished{
    _tapToStartFont = [[CCLabelBMFont alloc] initWithString:@"Tap to start..." fntFile:@"markerfelt.fnt"];
	_tapToStartFont.scale = 0.4;
	_tapToStartFont.position = _loadingFont.position;
	[self removeChild:_loadingFont cleanup:YES];
    _loadingFont = nil;
	[self addChild:_tapToStartFont z:5002 tag:1001];
	[_activity removeFromSuperview];
}

-(void) deleteLoadingScreen{
    [self removeChild:self.loadingScreen cleanup:YES];
    self.loadingScreen = nil;
}

-(void) startGame{
    [self removeChild:_tapToStartFont cleanup:YES];
    _tapToStartFont = nil;
    CCAction* callback =  [CCCallFunc actionWithTarget:self selector:@selector(deleteLoadingScreen)];
    [self.loadingScreen runAction:[CCSequence actions:self.moveUpwards,callback, nil] ];
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
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene]];
}


-(void) createPauseMenu{
	CGSize screenSize = [CCDirector sharedDirector].winSize;

	CCMenuItemImage *button1 = [CCMenuItemImage 
								itemFromNormalImage:@"resumeButton.png" selectedImage:@"resumeButtonTapped.png" 
								target:self.gameScene selector:@selector(switchPause:)];

	CCMenuItemImage *button2 = [CCMenuItemImage 
								itemFromNormalImage:@"restartButton.png" selectedImage:@"restartButtonTapped.png"
								target:self selector:@selector(restartButtonTapped:)];
	
	CCMenuItemImage *button3 = [CCMenuItemImage
								itemFromNormalImage:@"exitButton.png" selectedImage:@"exitButtonTapped.png"
								target:self selector:@selector(quitButtonTapped:)];
	
	_pausedMenu = [CCMenu menuWithItems:button1, button2, button3, nil];
	[self addChild:_pausedMenu z:5001 tag:2];
	
	_pausedMenu.position =  ccp( screenSize.width * 1.5, screenSize.height/2);
	[_pausedMenu alignItemsVerticallyWithPadding:20];
    
    CCAction* actionMoveIn = [[CCMoveTo actionWithDuration:0.3f position:ccp(screenSize.width - button1.contentSize.width/2, _pausedMenu.position.y)] retain];
    
	[_pausedMenu runAction:actionMoveIn];
}



-(void) createGameOverMenu{
	CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    
	CCMenuItemImage *button1 = [CCMenuItemImage 
								itemFromNormalImage:@"highscoresButton.png" selectedImage:@"highscoresButtonTapped.png" 
								target:self.gameScene selector:@selector(presentGameCenter)];    
    
	CCMenuItemImage *button2 = [CCMenuItemImage 
								itemFromNormalImage:@"restartButton.png" selectedImage:@"restartButtonTapped.png"
								target:self selector:@selector(restartButtonTapped:)];
	
	CCMenuItemImage *button3 = [CCMenuItemImage
								itemFromNormalImage:@"exitButton.png" selectedImage:@"exitButtonTapped.png"
								target:self selector:@selector(quitButtonTapped:)];
	
	_pausedMenu = [CCMenu menuWithItems:button1, button2, button3, nil];
	[self addChild:_pausedMenu z:5001 tag:2];
	
	_pausedMenu.position =  ccp( screenSize.width * 1.5, screenSize.height/2);
	[_pausedMenu alignItemsVerticallyWithPadding:20];
    
    CCAction* actionMoveIn = [[CCMoveTo actionWithDuration:0.3f position:ccp(screenSize.width - button1.contentSize.width/2, _pausedMenu.position.y)] retain];
    
	[_pausedMenu runAction:actionMoveIn];
    
    CCSprite* gameOverSprite = [CCSprite spriteWithFile:@"gameOver.png"];
    gameOverSprite.position = ccp(40+gameOverSprite.contentSize.width/2, screenSize.height + gameOverSprite.contentSize.height/2);
    CCAction *slideDown = [CCMoveTo actionWithDuration:0.3f position:ccp(gameOverSprite.position.x, screenSize.height - gameOverSprite.contentSize.height/2)];
    [self addChild:gameOverSprite z:5001 tag:5001];
    
    CCLabelBMFont* highscoreLabel = [[CCLabelBMFont alloc] initWithString:[NSString stringWithFormat:@"%i", _highScore]  fntFile:@"markerfelt.fnt"];	
    highscoreLabel.scale = 0.25;
    highscoreLabel.position = ccp(180, 45);
    CCLabelBMFont* scoreLabel = [[CCLabelBMFont alloc] initWithString:[NSString stringWithFormat:@"%i", _score]  fntFile:@"markerfelt.fnt"];	
    scoreLabel.scale = 0.25;
    scoreLabel.position = ccp(180, 78);
    [gameOverSprite addChild:highscoreLabel];
    [gameOverSprite addChild:scoreLabel];
    [gameOverSprite runAction:slideDown];   
}


-(void) switchPause{    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
	if (_paused == NO){
        self.loadingScreen = [CCSprite spriteWithFile:@"curtain1small.png"];
        self.loadingScreen.position = ccp(screenSize.width/2, screenSize.height + screenSize.height/2 + 30);
        [self addChild:_loadingScreen z:5000 tag:1000];
		self.moveDone = [CCCallFuncN actionWithTarget:self selector:@selector(createPauseMenu)];
		[_loadingScreen runAction:[CCSequence actions: _moveDownwards, _moveDone, nil]];
		_paused = YES;
	}else{
		_paused = NO;
        CCAction* callback = [CCCallFunc actionWithTarget:self selector:@selector(deleteLoadingScreen)];
		[_loadingScreen runAction:[CCSequence actions:self.moveUpwards,callback, nil]];
		[_pausedMenu runAction:[CCFadeOut actionWithDuration:0.3]];
		[self removeChild:_pausedMenu cleanup:YES]; 
        _pausedMenu = nil;
	}
}
-(void) gameOver:(int)score withHighScore:(int)highscore{
    //create the menu
    CGSize screenSize = [CCDirector sharedDirector].winSize;

    self.loadingScreen = [CCSprite spriteWithFile:@"curtain1small.png"];
    self.loadingScreen.position = ccp(screenSize.width/2, screenSize.height + screenSize.height/2 + 30);
    [self addChild:_loadingScreen z:5000 tag:1000];

    _score = score ;
    _highScore = highscore;
    CCAction* callback = [CCCallFunc actionWithTarget:self selector:@selector(createGameOverMenu)];
    [_loadingScreen runAction:[CCSequence actions: _moveDownwards, callback, nil]];
}

-(void) dealloc{
    self.moveDone = nil;
    self.moveDownwards = nil;
    self.moveUpwards = nil;
    [super dealloc];
}

@end
