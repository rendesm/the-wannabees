//
//  collisionEmitter.m
//  bees
//
//  Created by macbook white on 8/14/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "CollisionEmitter.h"


@implementation CollisionEmitter
@synthesize emitter = _emitter, sprite = _sprite, emitterNode = _emitterNode;


-(id) initWithFileName:(NSString*) fileName forNode:(CCNode*)node{
	if ((self = [super init])){
		self.emitterNode = [[CCNode alloc]init];
		self.emitter = [CCParticleSystemQuad particleWithFile:fileName];
		 _emitter.scale = 0.4;
		[node addChild:_emitter z: 300 tag:6000];
		self.sprite = [CCSprite spriteWithFile:@"leaf2.png"];
		self.sprite.position = _emitter.position;
		[node addChild:_sprite z:299 tag:5999];
		_sprite.scale = 0.5;
	}
	return self;
}

#pragma mark BOX2D collision detection
- (void)createBox2dBodyDefinitions:(b2World*)world{
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(self.sprite.position.x/PTM_RATIO, self.sprite.position.y/PTM_RATIO);
    bodyDef.userData = self;
	bodyDef.fixedRotation = true;
	bodyDef.allowSleep = true;
	bodyDef.awake = true;
	b2Body* body;
	body = world->CreateBody(&bodyDef);
	
    b2PolygonShape spriteShape;
	
    spriteShape.SetAsBox(self.sprite.contentSize.width/PTM_RATIO/2 * _sprite.scale,
                         self.sprite.contentSize.height/PTM_RATIO/2 * _sprite.scale);
    b2FixtureDef spriteShapeDef;
    spriteShapeDef.shape = &spriteShape;
    spriteShapeDef.density = 1.0f;
	spriteShapeDef.friction = 1.0f;
	spriteShapeDef.restitution = 1.0f;
    spriteShapeDef.isSensor = true;
	
    body->CreateFixture(&spriteShapeDef);
}

-(void) dealloc{
	[_emitter release];
	_emitter = nil;
	[super dealloc];
}

@end
