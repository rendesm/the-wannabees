//
//  Bat.m
//  bees
//
//  Created by macbook white on 9/6/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "Bat.h"


@implementation Bat
@synthesize sprite = _sprite;
@synthesize maxGuanoTime = _maxGuanoTime;
@synthesize timeLeftForGuano = _timeLeftForGuano;
@synthesize life = _life;

-(id) initForPosition:(CGPoint)point forNode:(CCNode*)node withTime:(ccTime)time{
	if ((self = [super init])){
		self.sprite = [CCSprite spriteWithSpriteFrameName:@"bat.png"];
		self.sprite.position = point;
		[node addChild:self.sprite z:99 tag:200];
		self.maxGuanoTime = time;
		_timeLeftForGuano = self.maxGuanoTime;
		_parentNode = node;
		_life = 6;
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
	bodyDef.allowSleep = true;
	bodyDef.awake = true;
	b2Body* body;
	body = world->CreateBody(&bodyDef);
	
    b2PolygonShape spriteShape;
	
    spriteShape.SetAsBox(_sprite.contentSize.width/PTM_RATIO/4  * _sprite.scale,
                         _sprite.contentSize.height/PTM_RATIO/4  * _sprite.scale);
    b2FixtureDef spriteShapeDef;
    spriteShapeDef.shape = &spriteShape;
    spriteShapeDef.density = 1.0f;
	spriteShapeDef.friction = 1.0f;
	spriteShapeDef.restitution = 1.0f;
    spriteShapeDef.isSensor = false;
    
    b2Filter filter;
    
    enum CollideBits { none = 0, player = 0x0001, predator = 0x0002, harvester = 0x0004, point = 0x0008, bird = 0x0010, bullet = 0x0020 };
    
	filter.categoryBits = predator;
	//filter.maskBits = 0xFFFF ;
    filter.maskBits = player;
	filter.groupIndex = 0;
	
	spriteShapeDef.filter = filter;
	
    body->CreateFixture(&spriteShapeDef);
}


@end
