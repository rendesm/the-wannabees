//
//  IntroScene.m
//  bees
//
//  Created by Mihaly Rendes on 11/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IntroScene.h"
#import "MainMenuScene.h"
#import "ConfigManager.h"

@implementation IntroScene

+(id)scene{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
    // 'layer' is an autorelease object.
	IntroScene *layer =  [[[IntroScene alloc] init] autorelease];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) next:(ccTime)dt{
    _timeElapsed += dt;
    if (_timeElapsed > 1.0f){
        [self unschedule:@selector(next:)];
        [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:2.0f scene:[MainMenuScene scene] withColor:ccWHITE]];
    }
}


-(id) init{
    if ((self = [super init])){
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        _defaultSprite = [CCSprite spriteWithFile:@"Default.png"];
        _defaultSprite.rotation = -90;
        [self addChild:_defaultSprite];
        _defaultSprite.position = ccp(winSize.width/2, winSize.height/2);
        _timeElapsed = 0;
        if ([ConfigManager sharedManager].music && ![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]){
			[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Wannabeesmenu.caf" loop:YES];
        }

        [self schedule:@selector(next:)];
    }
    return self;
}


@end
