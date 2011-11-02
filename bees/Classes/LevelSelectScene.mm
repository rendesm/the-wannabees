//
//  LevelSelectScene.m
//  bees
//
//  Created by macbook white on 8/21/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "LevelSelectScene.h"
#import "CaveScene.h"
#import "CampaignScene.h"
#import "MainMenuScene.h"
#import "SeaScene.h"
#import "DesertScene.h"
#import "Level.h"
#import "LevelSelectHills.h"
#import "LevelSelectCaves.h"


@implementation LevelSelectScene
@synthesize levels = _levels, selectedLevel = _selectedLevel;
@synthesize planetAction = _planetAction;
@synthesize emitter = _emitter;

static int _type;

+ (int) getType{
    return _type;
}

+ (void)setType:(int)newType {
    if (_type != newType) {
		_type = newType;
    }
}


+(id)scene:(int)type{
	// 'scene' is an autorelease object.
	[LevelSelectScene setType:type];
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	LevelSelectScene *layer = [LevelSelectScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


+(id)scene{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	LevelSelectScene *layer = [LevelSelectScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) delay:(ccTime)dt{
	_delayTime += dt;
	if (_delayTime >= 0){
		[self initMenus];
	}
}


-(void) loadParticles{
	CGSize size = [[CCDirector sharedDirector] winSize];
	self.emitter = 	[CCParticleSystemQuad particleWithFile:@"levelCloudEmitter.plist"];
	_emitter.position = ccp(size.width - 30 ,  -10);
	_emitter.rotation  = 180;
//	_emitter.scale = 0.8;
	[self addChild:_emitter z:10 tag:500];
}

-(void) unloadParticles{
	[self removeChild:_emitter cleanup:YES];
	self.emitter = nil;
}

-(id)init{
	if( (self=[super init] )) {
		[self schedule:@selector(delay:)];
	//	[[LevelManager sharedManager] readInLevels];
	//	[self readInLevels];
        if ([[ConfigManager sharedManager] music]){
            if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]){
                [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menuMusic.mp3" loop:YES];
            }
        }
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		_selectedLevelTag = 1;
		_rotateDone = YES;
		_selectedWorld = 1;
		/*
		_easy = [CCMenuItemImage 
				 itemFromNormalImage:@"easy.png" selectedImage:@"easyTapped.png" 
				 target:self selector:nil];
		
		_medium = [CCMenuItemImage 
				   itemFromNormalImage:@"medium.png" selectedImage:@"mediumTapped.png" 
				   target:self selector:nil];
		_hard = [CCMenuItemImage 
				 itemFromNormalImage:@"hard.png" selectedImage:@"hardTapped.png" 
				 target:self selector:nil];
		
		CCMenuItemToggle *toggleItem = [CCMenuItemToggle itemWithTarget:self 
															   selector:@selector(difficultyButtonTapped:) items:_easy, _medium, _hard, nil];
		*/
        
        CCMenuItemImage *startButton = [CCMenuItemImage itemFromNormalImage:@"start.png" selectedImage:@"startTapped.png" target:self selector:@selector(launchButtonTapped:)];
        
		CCMenuItemImage *backButton = [CCMenuItemImage 
									   itemFromNormalImage:@"backLevel.png" selectedImage:@"backLevelTapped.png" 
									   target:self selector:@selector(backButtonTapped:)];
		
		_buttonWidth = startButton.contentSize.width;
		_difficultyMenu = [CCMenu menuWithItems:startButton,backButton, nil];
		[_difficultyMenu alignItemsVerticallyWithPadding:20];
         
		[self addChild:_difficultyMenu z:200 tag:2];
		
		_difficultyMenu.position =  ccp( size.width /4 * 3 + size.width, size.height - startButton.contentSize.height - backButton.contentSize.height);
        
		
		_bgPicture = [CCSprite spriteWithFile:@"levelSelectBg.png"];
		_bgPicture.position = ccp(size.width/2 , size.height/2);
		[self addChild:_bgPicture z:0 tag:1];
		
        /*
		CCMenuItemImage *launchButton = [CCMenuItemImage itemFromNormalImage:@"launch.png" selectedImage:@"launchTapped.png"
																	  target:self selector:@selector(launchButtonTapped:)];
		
		_launchMenu = [CCMenu menuWithItems:launchButton, nil];
		_launchMenu.position = ccp(-launchButton.contentSize.width, launchButton.contentSize.height);
		_buttonWidth = launchButton.contentSize.width;
		[self addChild:_launchMenu z:601 tag:601];
         */
		
		[[ConfigManager sharedManager] setDifficulty:EASY];
				
		
		_planet = [CCSprite spriteWithFile:@"planet.png"];
		_planet.position = ccp(size.width + 10, -10);
		[self addChild:_planet z:601 tag:601];
		
		ConfigManager* sharedManager = [ConfigManager sharedManager];
		if (sharedManager.particles){
			[self loadParticles];
		}
	}	
	return self; 
}

-(id) initMenus{
	[self unschedule:@selector(delay:)];
	CGSize size = [[CCDirector sharedDirector] winSize];
	CCAction* actionMoveInRight = [CCMoveTo actionWithDuration:0.5f
													  position: ccp( size.width - _buttonWidth/2, _difficultyMenu.position.y)];
	CCAction* actionMoveDone = [CCCallFuncN actionWithTarget:self 
													selector:@selector(menuMoveFinished:)];
	//CCAction* actionMoveInLeft = [CCMoveTo actionWithDuration:0.5f position:ccp(_buttonWidth/2, _launchMenu.position.y)];
	//[_launchMenu runAction:[CCSequence actions:actionMoveInLeft, actionMoveDone, nil]];
	[_difficultyMenu runAction:[CCSequence actions:actionMoveInRight, actionMoveDone, nil]];	
}



#pragma mark menu actions

-(void)menuMoveFinished:(id)sender{
	CCMenu *moveInFinished = (CCMenu *)sender;
	moveInFinished.isTouchEnabled = YES;
}

#pragma mark options buttons tapped

-(void) difficultyButtonTapped:(id)sender{
	if ([[ConfigManager sharedManager] sounds]){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}	
	CCMenuItemToggle *toggleItem = (CCMenuItemToggle *)sender;
	if (toggleItem.selectedItem == _easy) {
		[[ConfigManager sharedManager] setDifficulty:EASY];
	} else if (toggleItem.selectedItem == _medium) {
		[[ConfigManager sharedManager] setDifficulty:NORMAL];
	}  else if (toggleItem.selectedItem == _hard) {
		[[ConfigManager sharedManager] setDifficulty:HARD];
	}
}

-(void) backButtonTapped:(id)sender{
	if ([[ConfigManager sharedManager] sounds]){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}	
	//[[CCDirector sharedDirector] replaceScene: [CCTransitionSlideInB transitionWithDuration:0.8 scene:[MainMenuScene scene]]];
	[[CCDirector sharedDirector] replaceScene: [MainMenuScene scene]];
}

-(void) launchButtonTapped:(id)sender{
	if ([[ConfigManager sharedManager] sounds]){
		[[SimpleAudioEngine sharedEngine] playEffect:@"tick.wav"];
	}	
	
	switch (_type) {
		case CAMPAIGN:
			if (_selectedWorld == 1) {
				[[CCDirector sharedDirector] replaceScene:[LevelSelectHills scene]];
			}else if (_selectedWorld == 2) {
				[[CCDirector sharedDirector] replaceScene:[LevelSelectCaves scene]];
			}			
			break;
		case SURVIVAL:
			if (_selectedWorld == 1) {
				[[LevelManager sharedManager] setSurvivalLevel:@"GreenHills" withDifficulty: [[ConfigManager sharedManager] difficulty] ];
				[[CCDirector sharedDirector] replaceScene:[CampaignScene scene]];
			}else if (_selectedWorld == 2) {
				[[LevelManager sharedManager] setSurvivalLevel:@"DarkCaves" withDifficulty:  [[ConfigManager sharedManager] difficulty]];
				[[CCDirector sharedDirector] replaceScene:[CaveScene scene]];
			}else if (_selectedWorld == 3){
				[[LevelManager sharedManager] setSurvivalLevel:@"NarrowSea" withDifficulty:  [[ConfigManager sharedManager] difficulty]];
				[[CCDirector sharedDirector] replaceScene:[SeaScene scene]];
			}else if (_selectedWorld == 4){
				[[LevelManager sharedManager] setSurvivalLevel:@"Desert" withDifficulty:  [[ConfigManager sharedManager] difficulty]];
				[[CCDirector sharedDirector] replaceScene:[DesertScene scene]];
			}
			break;
		default:
			break;
	}
		
	/*
	Level* level = [[Level alloc] init];
	self.selectedLevel = [NSString stringWithFormat:@"level%i", _selectedLevelTag + (_selectedWorld - 1) * 3];
	NSDictionary* _currentLevel = [_levels objectForKey:_selectedLevel];	
	level.distanceToGoal = [[_currentLevel objectForKey:@"distanceToGoal"] intValue];
	level.highScorePoints = [[_currentLevel objectForKey:@"highScorePoints"] intValue];
	level.name = _selectedLevel;
	level.backgroundImage = [_currentLevel objectForKey:@"background"] ;
	level.predatorSpeed = [[_currentLevel objectForKey:@"predatorSpeed"] floatValue];
	level.difficulty = _difficulty;
	level.sporeAvailable = [[_currentLevel objectForKey:@"sporeAvailable"] boolValue];
	level.trapAvailable = [[_currentLevel objectForKey:@"trapAvailable"] boolValue];
	
	
	switch (_type) {
		case CAMPAIGN:
			switch (_selectedWorld) {
				case 1:
					[[CCDirector sharedDirector] replaceScene: [CampaignScene scene:level]];
					break;
				case 2:
					[[CCDirector sharedDirector] replaceScene: [CaveScene scene:level]];
					break;

				default:
					break;
			}
			break;
		case SURVIVAL:
			[[CCDirector sharedDirector] replaceScene: [CampaignScene scene:level]];
			break;
		case TIME_RACE:
			[[CCDirector sharedDirector] replaceScene: [CampaignScene scene:level]];
			break;
		default:
			break;
	}
	 */
}

#pragma mark property list for levels 
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
	switch (_type) {
		case CAMPAIGN:
			self.levels = [[NSMutableDictionary alloc] initWithDictionary: (NSDictionary*)[temp objectForKey:@"Campaign"]];
			break;
		case SURVIVAL:
			self.levels = [[NSMutableDictionary alloc] initWithDictionary: (NSDictionary*)[temp objectForKey:@"Survival"]];
			break;
		case TIME_RACE:
			self.levels = [[NSMutableDictionary alloc] initWithDictionary: (NSDictionary*)[temp objectForKey:@"TimeRace"]];
			break;
		default:
			break;
	}
	
}


-(void) rotateDone:(id)sender{
	_rotateDone = YES;
}

-(void)onEnter{	
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];	
	[super onEnter];
}

-(void)onExit{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}



- (void)selectSpriteForTouch:(CGPoint)touchLocation {
	if (CGRectContainsPoint(_planet.boundingBox, touchLocation)) {            
		_planetWasTouched = YES;
	}else{
		_planetWasTouched = NO;
	}
}


-(BOOL)ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event{
	_source = [self convertTouchToNodeSpace:touch];
	[self selectSpriteForTouch:_source];
	return YES;
}


-(void)ccTouchEnded:(UITouch*)touch withEvent:(UIEvent*)event{
	CGPoint destination = [self convertTouchToNodeSpace:touch];
	int incrementWorld = 0;
	if (_planetWasTouched && _rotateDone){
		float distance = sqrt(pow(destination.x - _source.x, 2) + pow(destination.y - _source.y, 2));
		if (distance > 5) { //Make sure it's not just a tap
            _rotateDone = NO;
			CGPoint direction = ccpNormalize(ccp(destination.x-_source.x,destination.y-_source.y));
			if (fabsl(direction.x) >= fabsl(direction.y)) {
				if (direction.x>=0) {
					//rotate the planet clockwise 
					self.planetAction = [CCEaseSineInOut actionWithAction:[CCRotateBy actionWithDuration:0.5 angle:90]];
					incrementWorld = -1;
				}else {
					self.planetAction = [CCEaseSineInOut actionWithAction:[CCRotateBy actionWithDuration:0.5 angle:-90]];
					incrementWorld = 1;
				}
			}else{
				if (direction.y >= 0){
					self.planetAction = [CCEaseSineInOut actionWithAction:[CCRotateBy actionWithDuration:0.5 angle:90]];
					incrementWorld = -1;
				}else{
					self.planetAction = [CCEaseSineInOut actionWithAction:[CCRotateBy actionWithDuration:0.5 angle:-90]];
					incrementWorld = 1;
				}
			}
			
			_selectedWorld += incrementWorld;
			
			if (_selectedWorld == 0){
				_selectedWorld = 4;
			}else if (_selectedWorld == 5) {
				_selectedWorld = 1;
			}
			
			CCAction* rotateFinished = [CCCallFuncN actionWithTarget:self 
												selector:@selector(rotateDone:)];
			[_planet runAction:[CCSequence actions: _planetAction, rotateFinished, nil]];
		}
	}
}

-(void) dealloc{
	_emitter = nil;
	_planet = nil;
	 _bgPicture = nil;
	_difficultyMenu = nil;
	_launchMenu = nil;
	_easy = nil;
	_medium = nil;
	_hard = nil;
	[_levels release];
	_levels = nil;
	_selectedLevel = nil;
	_levelSelectMenu = nil;
	_planetAction = nil;	
	[super dealloc];
}

@end
