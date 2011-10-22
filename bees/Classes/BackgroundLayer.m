//
//  BackgroundLayer.m
//  bees
//
//  Created by Mihaly Rendes on 10/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BackgroundLayer.h"


@implementation BackgroundLayer
@synthesize backgrounds = _backgrounds;

+(id)scene{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	BackgroundLayer *layer = [BackgroundLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id)init{
    if (self = [super init]){
        self.backgrounds = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)addBackgrounds:(NSMutableArray*) backgrounds forZ:(int)z {
    for (CCSprite* sprite in backgrounds){
        [self addChild:sprite z:z tag:z];
        [sprite.texture setAliasTexParameters];
        [self.backgrounds addObject:sprite];
    }
}

-(void)update:(ccTime)dt{
    for (CCSprite* background in _backgrounds){
        if (background.position.x + background.contentSize.width/2 <= 0){
            background.position = ccpAdd(background.position, ccp((([self.backgrounds count]) * background.contentSize.width )- 3, 0));
        }else{
            background.position = ccp(background.position.x - 0.5, background.position.y);
        }
    }
}

-(void) dealloc{
    
    [super dealloc];
}

@end
