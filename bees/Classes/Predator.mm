//
//  Predator.m
//  bees
//
//  Created by macbook white on 7/20/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "Predator.h"


@implementation Predator
@synthesize life = _life, target = _target;
@synthesize type = _type, stamina = _stamina;
@synthesize isOutOfScreen = _isOutOfScreen;


-(void) update:(ccTime) dt{
	_stamina -= dt;
	if (_stamina <= 0){
		[self escape];
		[super update];
	}else{
		switch (_type) {
			case AGGRESSIVE:
				[self wander:0.1];
				[self attackTarget];
				[super update];
				break;
				
			case PASSIVE:
				[self wander:0.2];
				[self attackTarget];
				[super update];
				break;
				
			case LAZY:
				[self wander:0.2];
				[self attackTarget];
				[super update];
				break;
				
			case DUMB:
				[self wander:0.4];
				[self attackTarget];
				[super update];
				
			default:
				break;
		}
	}
}

-(void) attackTarget{
	[super seek:_target usingMultiplier:0.35f];
}

-(void) escape{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	int rndMax = screenSize.height/4.0;
	float rndY = arc4random() % rndMax;
	_target = ccp( - screenSize.width * 3, screenSize.height/2 );
}

-(void) berserk{
	self.maxSpeed +=0.2;
	_stamina +=1;
}


#pragma mark BOX2D collision detection
- (void)createBox2dBodyDefinitions:(b2World*)world{
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    bodyDef.userData = self;
	bodyDef.fixedRotation = false;
    bodyDef.allowSleep = true;
	b2Body* body;
	body = world->CreateBody(&bodyDef);
	
    b2PolygonShape spriteShape;
    spriteShape.SetAsBox(self.contentSize.width/PTM_RATIO/2 * self.scale ,
                         self.contentSize.height/PTM_RATIO/2 * self.scale);
    b2FixtureDef spriteShapeDef;
    spriteShapeDef.shape = &spriteShape;
    spriteShapeDef.density = 1.0f;
	spriteShapeDef.friction = 1.0f;
	spriteShapeDef.restitution = 1.0f;
    spriteShapeDef.isSensor = false;
    enum CollideBits { none = 0, player = 0x0001, predator = 0x0002, harvester = 0x0004, point = 0x0008, bird = 0x0010, bullet = 0x0020 };    b2Filter filter;
	filter.categoryBits = predator;
	//filter.maskBits = 0xFFFF ;
    filter.maskBits = player;
    filter.groupIndex = 0;
	
	spriteShapeDef.filter = filter;

    body->CreateFixture(&spriteShapeDef);
}


-(void) gotHit:(float)damage{
	_life -= damage;
	switch (_type) {
		case AGGRESSIVE:
			if (_life == 1) {
				[self escape];
			}else if (_life > 1 && _life <=3){
				[self berserk];
			}
			break;
		case PASSIVE:
			if (_life <= 3){
				[self escape];
			}
			break;
		case DUMB:
			break;
			
		case LAZY:
			if (_life < 4) {
				[self escape];
			}
			break;
		default:
			break;
	}
}

-(void) dealloc{
	[super dealloc];
}


@end
