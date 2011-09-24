//
//  Atka.h
//  bees
//
//  Created by macbook white on 8/5/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "TypeEnums.h"


@interface Atka : NSObject {
	CCSprite *_sprite;
	CCAction *_moveAction;
}

-(id) initForNode:(CCNode*) node;
- (void)createBox2dBodyDefinitions:(b2World*)world;

@property (nonatomic, retain) CCSprite* sprite;

@end
