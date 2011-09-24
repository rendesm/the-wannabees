//
//  Spore.h
//  bees
//
//  Created by macbook white on 8/4/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "TypeEnums.h"

@interface Spore : NSObject {
	CCSprite *_sprite;
	CCAction *_moveAction;
	CCNode *_emitterNode;
}

-(id) initForNode:(CCNode*) node;
- (void)createBox2dBodyDefinitions:(b2World*)world;

@property (nonatomic, retain) CCSprite* sprite;
@property (nonatomic, retain) CCNode* emitterNode;


@end
