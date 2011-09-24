//
//  Cloud.h
//  bees
//
//  Created by macbook white on 7/28/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "cocos2d.h"
#import "TypeEnums.h"

@interface Cloud : CCSprite {
	CCSprite* _sprite;
	CCParticleSystemQuad* _emitter;
	CCNode* _emitterNode;
}

@property (nonatomic, retain) CCSprite* sprite;


-(void) generateParticle:(int)type;
-(void) setParticlePosition:(CGPoint) position;

@end
