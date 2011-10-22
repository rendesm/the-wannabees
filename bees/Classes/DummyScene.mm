//
//  DummyScene.m
//  bees
//
//  Created by Mihaly Rendes on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DummyScene.h"


@implementation DummyScene


+(id)scene:(int)sceneToSwitch{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
    // 'layer' is an autorelease object.
	DummyScene *layer =  [[[DummyScene alloc] initWithSwitch:sceneToSwitch] autorelease];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


-(id) initWithSwitch:(int)sceneToSwitch{
    if (sceneToSwitch == 0){
        [[CCDirector sharedDirector] replaceScene:[CampaignScene scene]];
    }else if (sceneToSwitch == 1){
        
    }else if (sceneToSwitch == 2){
        
    }
    
    return self;
}

@end
