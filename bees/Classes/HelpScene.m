//
//  HelpScene.m
//  bees
//
//  Created by Mihaly Rendes on 11/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HelpScene.h"

@implementation HelpScene
@synthesize background = _background, currentText = _currentText, currentLabel = _currentLabel;
@synthesize arrow = _arrow;
@class MainMenuScene;
+(id)scene{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelpScene *layer =  [[[HelpScene alloc] init] autorelease];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init{
    if ((self = [super init])){
        _currentTutorial = 0;
        self.currentText = @"Touch the screen to step in the tutorial";
        self.currentLabel = [[CCLabelTTF alloc] initWithString:_currentText fontName:@"Marker Felt" fontSize:18];
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        self.currentLabel.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:self.currentLabel z:2];
        
        self.background = [CCSprite spriteWithFile:[NSString stringWithFormat:@"tutorial1.png", _currentTutorial]];
        self.background.position = ccp(screenSize.width/2, screenSize.height/2);
        self.arrow = [CCSprite spriteWithFile:@"rightArrow.png"];
        self.arrow.position = ccp(screenSize.width/2 + 10, screenSize.height * 0.7);
        self.arrow.rotation = -90;
        self.arrow.opacity = 0;
        [self addChild:self.arrow z: 3];
        [self addChild:self.background];
    }
    return self;
}

-(void) createTutorialText{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    switch (_currentTutorial) {
        case 1:
            self.currentText = @"Touch the screen to move the bees to that location.";
            break;
        case 2:
            self.currentText = @"Drag your fingers around to make the bees follow your movement";
            break;
        case 3:
            self.currentText = @"Pickup flowers to increase your points.";
            break;
        case 4:
            [self.arrow runAction:[CCFadeIn actionWithDuration:0.2]];
            self.currentText = @"These icons indicate the combo you have to finish";
            break;
        case 5:
            self.currentText = @"To increase your bonus multoplier by 2x";
            break;
        case 6:
            [self.arrow runAction:[CCFadeOut actionWithDuration:0.2]];
            self.currentText = @"Failing a combo resets your bonus..."; 
            break;
        case 7:
            self.currentText = @"... and brings the evil darkness a bit closer...";
            break;
        case 8:
            self.currentText = @"to banish the darkness, finish 2 combos";
            break;
        case 9:
            self.currentText = @"oh and I forgot...";
            break;
        case 10:
            self.currentText = @"avoid everything else!!!";
            break;
        default:
            break;
    }
    self.currentLabel.string = _currentText;
    self.currentLabel.position = ccp(screenSize.width/2, screenSize.height/2);
}

-(void) nextTutorial{
    _currentTutorial++;
    if (_currentTutorial == 6){
        self.background = [CCSprite spriteWithFile:[NSString stringWithFormat:@"tutorial1.png", _currentTutorial]];
    }else if (_currentTutorial > 10){
        [[CCDirector sharedDirector] replaceScene:[MainMenuScene scene]];
    }
    [self createTutorialText];
}


-(void) onEnter{
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

-(void) onExit{
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self nextTutorial];
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	
}

-(void) dealloc{
    self.background = nil;
    self.currentLabel = nil;
    [super dealloc];
}


@end
