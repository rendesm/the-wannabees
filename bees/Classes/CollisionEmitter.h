//
//  collisionEmitter.h
//  bees
//
//  Created by macbook white on 8/14/11.
//  Copyright 2011 nincs. All rights reserved.
//


#import "cocos2d.h"
#import "Box2D.h"
#import "TypeEnums.h"

@interface CollisionEmitter : NSObject {
	CCParticleSystemQuad *_emitter;
	CCSprite *_sprite;
	CCNode* _emitterNode;
}

@property (nonatomic, retain) CCParticleSystemQuad* emitter;
@property (nonatomic, retain) CCSprite* sprite;
@property (nonatomic, retain) CCNode* emitterNode;

-(id) initWithFileName:(NSString*) fileName forNode:(CCNode*)node;
- (void)createBox2dBodyDefinitions:(b2World*)world;
@end
