//
//  Cloud.m
//  bees
//
//  Created by macbook white on 7/28/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "Cloud.h"


@implementation Cloud
@synthesize sprite = _sprite;


-(id) initWithFileName:(NSString*)fileName{
	if ((self = [super init])){
		_sprite = [CCSprite spriteWithFile:fileName];
		_emitterNode = [[CCNode alloc] init];
	}
	return self;
}

-(void) generateParticle:(int)type{
	if (type == RAIN){
		_emitter = [CCParticleSystemQuad particleWithFile:@"rain.plist"];
		[_emitterNode  addChild:_emitter z:120];
		_emitter.position = ccp(0,0);
		_emitter.scale = 0.3;
	}
}

-(void) setParticlePosition:(CGPoint) position{
	_emitterNode.position = position;
}

@end
