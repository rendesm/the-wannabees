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
	bodyDef.allowSleep = true;
	bodyDef.awake = true;
	b2Body* body;
	body = world->CreateBody(&bodyDef);
	
	b2PolygonShape spriteShape;
	
    //row 1, col 1
    int num = 6;
    b2Vec2 verts[] = {
        b2Vec2(-57.5f / PTM_RATIO, -35.5f / PTM_RATIO),
        b2Vec2(56.0f / PTM_RATIO, -35.5f / PTM_RATIO),
        b2Vec2(35.5f / PTM_RATIO, 37.0f / PTM_RATIO),
        b2Vec2(-1.5f / PTM_RATIO, 37.5f / PTM_RATIO),
        b2Vec2(-44.0f / PTM_RATIO, -4.0f / PTM_RATIO),
        b2Vec2(-58.5f / PTM_RATIO, -35.0f / PTM_RATIO)
    };
	
	spriteShape.Set(verts, num);	
	
	b2FixtureDef spriteShapeDef;
	spriteShapeDef.shape = &spriteShape;
	spriteShapeDef.density = 1.0f;
	spriteShapeDef.friction = 1.0f;
	spriteShapeDef.restitution = 1.0f;
	spriteShapeDef.isSensor = true;
    
    b2Filter filter;
    
    enum CollideBits { none = 0, player = 0x0001, predator = 0x0002, harvester = 0x0004, point = 0x0008, bird = 0x0010, bullet = 0x0020 };
    
	filter.categoryBits = bullet;
	//filter.maskBits = 0xFFFF ;
    filter.maskBits = player | predator;
	filter.groupIndex = 0;
	
	spriteShapeDef.filter = filter;
	
	body->CreateFixture(&spriteShapeDef);
}


-(void) createBox2dBodyRock2:(b2World*)world{
	//row 1, col 1
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
    //row 1, col 1
    /*
    int num = 6;
    b2Vec2 verts[] = {
        b2Vec2(-27.5f / PTM_RATIO, -57.0f / PTM_RATIO),
        b2Vec2(66.5f / PTM_RATIO, -57.5f / PTM_RATIO),
        b2Vec2(43.5f / PTM_RATIO, 17.5f / PTM_RATIO),
        b2Vec2(15.0f / PTM_RATIO, 56.0f / PTM_RATIO),
        b2Vec2(-7.5f / PTM_RATIO, 46.5f / PTM_RATIO),
        b2Vec2(-28.5f / PTM_RATIO, -52.0f / PTM_RATIO)
    };*/
    
    //row 1, col 1
    int num = 7;
    b2Vec2 verts[] = {
        b2Vec2(45.0f / PTM_RATIO, -59.0f / PTM_RATIO),
        b2Vec2(23.0f / PTM_RATIO, 20.0f / PTM_RATIO),
        b2Vec2(3.0f / PTM_RATIO, 31.0f / PTM_RATIO),
        b2Vec2(-6.5f / PTM_RATIO, 60.0f / PTM_RATIO),
        b2Vec2(-27.0f / PTM_RATIO, 56.5f / PTM_RATIO),
        b2Vec2(-46.0f / PTM_RATIO, -8.0f / PTM_RATIO),
        b2Vec2(-49.0f / PTM_RATIO, -58.0f / PTM_RATIO)
    };
    


	spriteShape.Set(verts, num);
	
	b2FixtureDef spriteShapeDef;
	spriteShapeDef.shape = &spriteShape;
	spriteShapeDef.density = 1.0f;
	spriteShapeDef.friction = 1.0f;
	spriteShapeDef.restitution = 1.0f;
	spriteShapeDef.isSensor = true;
    
    b2Filter filter;
    
    enum CollideBits { none = 0, player = 0x0001, predator = 0x0002, harvester = 0x0004, point = 0x0008, bird = 0x0010, bullet = 0x0020 };
    
	filter.categoryBits = bullet;
	//filter.maskBits = 0xFFFF ;
    filter.maskBits = player | predator;
	filter.groupIndex = 0;
	
	spriteShapeDef.filter = filter;
	
	body->CreateFixture(&spriteShapeDef);
	
}


-(void) createBox2dBodyRock3:(b2World*)world{
	//row 1, col 1
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

    //row 1, col 1
    int num = 6;
    b2Vec2 verts[] = {
        b2Vec2(64.0f / PTM_RATIO, -30.1f / PTM_RATIO),
        b2Vec2(46.3f / PTM_RATIO, 7.1f / PTM_RATIO),
        b2Vec2(21.6f / PTM_RATIO, 28.3f / PTM_RATIO),
        b2Vec2(-25.1f / PTM_RATIO, 29.0f / PTM_RATIO),
        b2Vec2(-36.8f / PTM_RATIO, 0.7f / PTM_RATIO),
        b2Vec2(-64.0f / PTM_RATIO, -29.7f / PTM_RATIO)
    };
    
    

    
	spriteShape.Set(verts, num);
	
	b2FixtureDef spriteShapeDef;
	spriteShapeDef.shape = &spriteShape;
	spriteShapeDef.density = 1.0f;
	spriteShapeDef.friction = 1.0f;
	spriteShapeDef.restitution = 1.0f;
	spriteShapeDef.isSensor = true;
    
    b2Filter filter;
    
    enum CollideBits { none = 0, player = 0x0001, predator = 0x0002, harvester = 0x0004, point = 0x0008, bird = 0x0010, bullet = 0x0020 };
    
	filter.categoryBits = bullet;
	//filter.maskBits = 0xFFFF ;
    filter.maskBits = player | predator;
	filter.groupIndex = 0;
	
	spriteShapeDef.filter = filter;
	
	body->CreateFixture(&spriteShapeDef);
	
}


-(void) createBox2dBodyTopRock1:(b2World*)world{
	//row 1, col 1
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

    //row 1, col 1
    int num = 7;
    b2Vec2 verts[] = {
        b2Vec2(-51.5f / PTM_RATIO, 48.5f / PTM_RATIO),
        b2Vec2(-50.5f / PTM_RATIO, -4.0f / PTM_RATIO),
        b2Vec2(-12.0f / PTM_RATIO, -48.0f / PTM_RATIO),
        b2Vec2(16.0f / PTM_RATIO, -44.5f / PTM_RATIO),
        b2Vec2(18.0f / PTM_RATIO, -22.5f / PTM_RATIO),
        b2Vec2(44.0f / PTM_RATIO, -6.0f / PTM_RATIO),
        b2Vec2(53.0f / PTM_RATIO, 50.0f / PTM_RATIO)
    };
    
    spriteShape.Set(verts, num);
	
	b2FixtureDef spriteShapeDef;
	spriteShapeDef.shape = &spriteShape;
	spriteShapeDef.density = 1.0f;
	spriteShapeDef.friction = 1.0f;
	spriteShapeDef.restitution = 1.0f;
	spriteShapeDef.isSensor = true;
    
    b2Filter filter;
    
    enum CollideBits { none = 0, player = 0x0001, predator = 0x0002, harvester = 0x0004, point = 0x0008, bird = 0x0010, bullet = 0x0020 };
    
	filter.categoryBits = bullet;
	//filter.maskBits = 0xFFFF ;
    filter.maskBits = player | predator;
	filter.groupIndex = 0;
	
	spriteShapeDef.filter = filter;
	
	body->CreateFixture(&spriteShapeDef);
	
}

-(void) createBox2dBodyTopRock2:(b2World*)world{
	//row 1, col 1
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
    //row 1, col 1
    int num = 5;
    b2Vec2 verts[] = {
        b2Vec2(-45.0f / PTM_RATIO, 35.5f / PTM_RATIO),
        b2Vec2(-40.0f / PTM_RATIO, 1.5f / PTM_RATIO),
        b2Vec2(0.0f / PTM_RATIO, -36.5f / PTM_RATIO),
        b2Vec2(39.5f / PTM_RATIO, -14.0f / PTM_RATIO),
        b2Vec2(48.0f / PTM_RATIO, 36.5f / PTM_RATIO)
    };
    

	spriteShape.Set(verts, num);
	
	b2FixtureDef spriteShapeDef;
	spriteShapeDef.shape = &spriteShape;
	spriteShapeDef.density = 1.0f;
	spriteShapeDef.friction = 1.0f;
	spriteShapeDef.restitution = 1.0f;
	spriteShapeDef.isSensor = false;
    
    b2Filter filter;
    
    enum CollideBits { none = 0, player = 0x0001, predator = 0x0002, harvester = 0x0004, point = 0x0008, bird = 0x0010, bullet = 0x0020 };
    
	filter.categoryBits = bullet;
	//filter.maskBits = 0xFFFF ;
    filter.maskBits = player | predator;
	filter.groupIndex = 0;
	
	spriteShapeDef.filter = filter;
	
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
        case 5:
			[self createBox2dBodyRock3:world];
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
