//
//  Sea.m
//  bees
//
//  Created by macbook white on 9/21/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "Sea.h"


@implementation Sea
@synthesize sprite = _sprite;

-(id) initForNode:(CCNode*)node{
	if ((self = [super init])){
		self.sprite = [CCSprite spriteWithSpriteFrameName:@"bootmSea.png"];
        self.sprite.scale = 0.7;
		[node addChild:self.sprite z:4 tag:200];
	}
	return self;
}


#pragma mark BOX2D collision detection
- (void)createBox2dBodyDefinitions:(b2World*)world{
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(_sprite.position.x/PTM_RATIO, _sprite.position.y/PTM_RATIO);
    bodyDef.userData = self;
	bodyDef.fixedRotation = true;
	bodyDef.allowSleep = false;
	bodyDef.awake = true;
    bodyDef.bullet = true;
    

	b2Body* body;
	body = world->CreateBody(&bodyDef);
	
    b2PolygonShape spriteShape;
	
    spriteShape.SetAsBox(_sprite.contentSize.width/PTM_RATIO * 0.5  * _sprite.scale,
                         _sprite.contentSize.height/PTM_RATIO * 0.35 * _sprite.scale);
    b2FixtureDef spriteShapeDef;
    spriteShapeDef.shape = &spriteShape;
    spriteShapeDef.density = 1.0f;
	spriteShapeDef.friction = 1.0f;
	spriteShapeDef.restitution = 1.0f;
    spriteShapeDef.isSensor = false;
    
    b2Filter filter;
    
    enum CollideBits { none = 0, player = 0x0001, predator = 0x0002, harvester = 0x0004, point = 0x0008, bird = 0x0010, bullet = 0x0020 };
    
	filter.categoryBits = bird;
	//filter.maskBits = 0xFFFF ;
    filter.maskBits = player;
	filter.groupIndex = 0;
	
	spriteShapeDef.filter = filter;
	
    body->CreateFixture(&spriteShapeDef);
}

-(void) dealloc{
	self.sprite = nil;
	[super dealloc];
}
@end
