//
//  LevelSelectHills.m
//  bees
//
//  Created by macbook white on 9/15/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "LevelSelectHills.h"
#import "LevelSelectScene.h"
#import "LevelManager.h"
#import "CampaignScene.h"

@implementation LevelSelectHills
@synthesize background = _background, launchMenu = _launchMenu;
@synthesize emitter = _emitter;
@synthesize selectedLevel = _selectedLevel, selectedSprite = _selectedSprite;
@synthesize easyLevelSprites = _easyLevelSprites;

+(id)scene{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object 
	LevelSelectHills *layer = [LevelSelectHills node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


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

-(void) menuFadeInFinished:(id)sender{
	_tappable = YES;
}

-(void) loadItems{
	//	LevelManager* sharedManager = [[LevelManager sharedManager] campaignLevels];
	for (int i = 0; i < 3; i++){
		//get the first 3 levels for Green Hills
		NSString* itemSprite = [NSString stringWithFormat:@"item%i.png", i+1];
		CCSprite* levelSprite = [CCSprite spriteWithFile:itemSprite];
		[self addChild:levelSprite];
		levelSprite.position = ccp(levelSprite.contentSize.width * (i+1) * 1.5, _launchMenu.position.y + _buttonHeight/2);
		levelSprite.opacity = 0;
		CCAction* fadeIn = [CCFadeTo actionWithDuration:0.6 opacity:170];
		CCAction* actionFadeInDone = [[CCCallFuncN actionWithTarget:self selector:@selector(menuFadeInFinished:)] retain];
		_tappable = NO;
		[levelSprite runAction:[CCSequence actions:fadeIn, actionFadeInDone,nil]];
		
		[self.easyLevelSprites addObject:levelSprite];
	}
		
}

-(id) init{
	if ((self = [super init])){
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		self.background = [CCSprite spriteWithFile:@"levelSelectHills.png"];
		self.background.position = ccp(screenSize.width/2, screenSize.height/2);
		[self addChild:_background z:-1 tag:1];
		
		self.easyLevelSprites = [[NSMutableArray alloc]init];
		
		if ([[ConfigManager sharedManager] particles]){
			[self loadParticles];
		}
		
		//create the right side menu
		CCMenuItemImage *backButton = [CCMenuItemImage 
									   itemFromNormalImage:@"back.png" selectedImage:@"backTapped.png" 
									   target:self selector:@selector(backButtonTapped)];
		
		CCMenuItemImage *launchButton = [CCMenuItemImage itemFromNormalImage:@"play.png" selectedImage:@"playTapped.png"
										 target:self selector:@selector(launchButtonTapped:)];

		_buttonHeight = launchButton.contentSize.height;
		self.launchMenu = [CCMenu menuWithItems:launchButton, backButton, nil];
		_launchMenu.position = ccp(screenSize.width /4 * 3 + screenSize.width, screenSize.height - launchButton.contentSize.height * 2);
		[_launchMenu alignItemsVerticallyWithPadding:20];
		[self addChild:_launchMenu z:2 tag:2];
		
		CCAction* actionMoveIn = [CCMoveTo actionWithDuration:0.5f
											 position: ccp( screenSize.width - backButton.contentSize.width/2, _launchMenu.position.y)];
		
		CCAction* actionMoveInDone = [[CCCallFuncN actionWithTarget:self selector:@selector(menuMoveInFinished:)] retain];
		_launchMenu.isTouchEnabled = NO;
		[_launchMenu runAction:[CCSequence actions: actionMoveIn, actionMoveInDone,nil]];		
		[self loadItems];
	}
	return self;
}

-(void) menuMoveInFinished:(id)sender{
	CCMenu *moveInFinished = (CCMenu *)sender;
	moveInFinished.isTouchEnabled = YES;
}

-(void) backButtonTapped{
	[[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene]];
}

-(void) launchButtonTapped:(id)sender{
	if (self.selectedSprite != nil){
		[[CCDirector sharedDirector] replaceScene:[CampaignScene scene]];
	}else {
		//display message to select a level
		//todo
	}

}


- (void)selectSpriteForTouch:(CGPoint)touchLocation {
	CCAction* selectIt = [CCScaleTo actionWithDuration:0.4 scale:1.3];
	CCAction* rescaleIt = [CCScaleTo actionWithDuration:0.4 scale:1.0];
	for (unsigned int i = 0; i < [_easyLevelSprites count]; i++) {
		CCSprite* sprite = [_easyLevelSprites objectAtIndex:i];
		if (CGRectContainsPoint(sprite.boundingBox, touchLocation)) {            
			if (sprite != self.selectedSprite){
				[[LevelManager sharedManager] setSelectedHillsLevelWithDifficulty:[[ConfigManager sharedManager] difficulty] withNumber:i+1];
				Level* level = [[LevelManager sharedManager] selectedLevel];
				if (level.unlocked){
					[sprite runAction:selectIt];
					[self.selectedSprite runAction:rescaleIt];
					self.selectedSprite = sprite;
				}else {
					[self.selectedSprite runAction:rescaleIt];
					self.selectedSprite = nil;
					[[LevelManager sharedManager] setSelectedLevel:nil];
				}

			}
			return;
		}
	}
}


- (void)onEnter
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (void)onExit
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
	
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint source = [self convertTouchToNodeSpace:touch];
	[self selectSpriteForTouch:source];
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{

}

-(void) dealloc{
	[self.easyLevelSprites release];
	self.easyLevelSprites = nil;
	
	[self.selectedLevel release];
	self.selectedLevel = nil;
	self.selectedSprite = nil;
	[super dealloc];
	
}



@end
