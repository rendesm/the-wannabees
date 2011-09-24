//
//  Rock.m
//  bees
//
//  Created by macbook white on 9/2/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "Rock.h"


@implementation Rock
@synthesize sprite = _sprite;
@synthesize type = _type;

- (id) initWithFileName:(NSString*) fileName{
	if( (self = [super	 init])){
		self.sprite = [CCSprite spriteWithSpriteFrameName:fileName];
	}
    return self;
}


-(void) createBox2dBodyRock1:(b2World*)world{	
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
	
	//row 1, col 1
	int num = 4;
	b2Vec2 verts[] = {
		b2Vec2(-48.5f / PTM_RATIO, -30.5f / PTM_RATIO),
		b2Vec2(48.0f / PTM_RATIO, -30.0f / PTM_RATIO),
		b2Vec2(-17.5f / PTM_RATIO, 32.8f / PTM_RATIO),
		b2Vec2(-48.2f / PTM_RATIO, -29.8f / PTM_RATIO)
	};
	
	
	
	spriteShape.Set(verts, num);	
	
	b2FixtureDef spriteShapeDef;
	spriteShapeDef.shape = &spriteShape;
	spriteShapeDef.density = 1.0f;
	spriteShapeDef.friction = 1.0f;
	spriteShapeDef.restitution = 1.0f;
	spriteShapeDef.isSensor = true;
	
	body->CreateFixture(&spriteShapeDef);
}


-(void) createBox2dBodyRock2:(b2World*)world{
	//row 1, col 1
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
	//row 1, col 1
	int num = 8;
	b2Vec2 verts[] = {
		b2Vec2(22.8f / PTM_RATIO, -40.5f / PTM_RATIO),
		b2Vec2(18.9f / PTM_RATIO, -14.0f / PTM_RATIO),
		b2Vec2(1.6f / PTM_RATIO, 2.7f / PTM_RATIO),
		b2Vec2(2.3f / PTM_RATIO, 43.0f / PTM_RATIO),
		b2Vec2(-8.7f / PTM_RATIO, 32.4f / PTM_RATIO),
		b2Vec2(-12.9f / PTM_RATIO, -17.5f / PTM_RATIO),
		b2Vec2(-21.4f / PTM_RATIO, -23.2f / PTM_RATIO),
		b2Vec2(-21.7f / PTM_RATIO, -41.9f / PTM_RATIO)
	};	

	spriteShape.Set(verts, num);
	
	b2FixtureDef spriteShapeDef;
	spriteShapeDef.shape = &spriteShape;
	spriteShapeDef.density = 1.0f;
	spriteShapeDef.friction = 1.0f;
	spriteShapeDef.restitution = 1.0f;
	spriteShapeDef.isSensor = true;
	
	body->CreateFixture(&spriteShapeDef);
	
}

-(void) createBox2dBodyTopRock1:(b2World*)world{
	//row 1, col 1
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
	//row 1, col 1
	//row 1, col 1
	int num = 3;
	b2Vec2 verts[] = {
		b2Vec2(-58.7f / PTM_RATIO, 27.5f / PTM_RATIO),
		b2Vec2(2.5f / PTM_RATIO, -35.8f / PTM_RATIO),
		b2Vec2(59.0f / PTM_RATIO, 30.5f / PTM_RATIO)
	};
	
	spriteShape.Set(verts, num);
	
	b2FixtureDef spriteShapeDef;
	spriteShapeDef.shape = &spriteShape;
	spriteShapeDef.density = 1.0f;
	spriteShapeDef.friction = 1.0f;
	spriteShapeDef.restitution = 1.0f;
	spriteShapeDef.isSensor = true;
	
	body->CreateFixture(&spriteShapeDef);
	
}

-(void) createBox2dBodyTopRock2:(b2World*)world{
	//row 1, col 1
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
	//row 1, col 1
	int num = 6;
	b2Vec2 verts[] = {
		b2Vec2(-25.0f / PTM_RATIO, 34.2f / PTM_RATIO),
		b2Vec2(-20.8f / PTM_RATIO, 1.2f / PTM_RATIO),
		b2Vec2(-2.2f / PTM_RATIO, -35.2f / PTM_RATIO),
		b2Vec2(14.5f / PTM_RATIO, -1.8f / PTM_RATIO),
		b2Vec2(25.0f / PTM_RATIO, 34.8f / PTM_RATIO),
		b2Vec2(-25.0f / PTM_RATIO, 36.0f / PTM_RATIO)
	};
	
	spriteShape.Set(verts, num);
	
	b2FixtureDef spriteShapeDef;
	spriteShapeDef.shape = &spriteShape;
	spriteShapeDef.density = 1.0f;
	spriteShapeDef.friction = 1.0f;
	spriteShapeDef.restitution = 1.0f;
	spriteShapeDef.isSensor = true;
	
	body->CreateFixture(&spriteShapeDef);
	
}

#pragma mark BOX2D collision detection
- (void)createBox2dBodyDefinitions:(b2World*)world{
	switch (self.type) {
		case 1:
			[self createBox2dBodyRock1:world];
			break;
		case 2:
			[self createBox2dBodyRock2:world];
			break;
		case 3:
			[self createBox2dBodyTopRock1:world];
			break;
		case 4:
			[self createBox2dBodyTopRock2:world];
			break;
		default:
			break;
	}
}
	   
-(void) dealloc{
   [super dealloc];
   _sprite = nil;
}

@end
