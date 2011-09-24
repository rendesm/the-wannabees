//
//  ComboFinisher.m
//  bees
//
//  Created by macbook white on 9/20/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "ComboFinisher.h"


@implementation ComboFinisher
@synthesize sprite = _sprite, taken = _taken, type = _type;


-(id) initWithFileName:(NSString*) fileName{
	if ((self = [super init])){
		self.sprite = [CCSprite spriteWithSpriteFrameName:fileName];
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
	bodyDef.allowSleep = false;
	bodyDef.awake = true;
	b2Body* body;
	body = world->CreateBody(&bodyDef);
	
    b2PolygonShape spriteShape;
	
    spriteShape.SetAsBox(self.sprite.contentSize.width/PTM_RATIO/2 * self.sprite.scale,
                         self.sprite.contentSize.height/PTM_RATIO/2 * self.sprite.scale);
    b2FixtureDef spriteShapeDef;
    spriteShapeDef.shape = &spriteShape;
    spriteShapeDef.density = 1.0f;
	spriteShapeDef.friction = 1.0f;
	spriteShapeDef.restitution = 1.0f;
    spriteShapeDef.isSensor = true;
	
    body->CreateFixture(&spriteShapeDef);
}

-(void) dealloc{
	[super dealloc];
	_sprite = nil;
}


@end
