//
//  Snake.m
//  bees
//
//  Created by Mihaly Rendes on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Snake.h"

@implementation Snake
@synthesize animation = _animation;
@synthesize isOnScreen = _isOnScreen;
@synthesize sprite = _sprite;

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
    //row 1, col 1
    int num = 7;
    b2Vec2 verts[] = {
        b2Vec2(47.2f / PTM_RATIO, -29.9f / PTM_RATIO),
        b2Vec2(-3.4f / PTM_RATIO, -16.8f / PTM_RATIO),
        b2Vec2(6.9f / PTM_RATIO, 38.7f / PTM_RATIO),
        b2Vec2(-29.5f / PTM_RATIO, 36.2f / PTM_RATIO),
        b2Vec2(-38.0f / PTM_RATIO, 26.0f / PTM_RATIO),
        b2Vec2(-7.6f / PTM_RATIO, 20.7f / PTM_RATIO),
        b2Vec2(-12.9f / PTM_RATIO, -40.5f / PTM_RATIO)
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
    filter.maskBits = player;
	filter.groupIndex = 0;
	
	spriteShapeDef.filter = filter;
	
	body->CreateFixture(&spriteShapeDef);
	
}

-(id) initForDesertNode:(CCNode*)node{
    if ((self = [super init])){
		self.sprite = [CCSprite spriteWithSpriteFrameName:@"snake0.png"];
        NSMutableArray *moveAnimationFrames = [NSMutableArray array];
        for(int i = 1; i <= 6; ++i) {
            NSString* frameName = [NSString stringWithFormat:@"snake%i.png",i];
            [moveAnimationFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
        }
        
        //        self.sprite.scale = 1.0;
        CCAnimation *moveAnim = [CCAnimation 
                                 animationWithFrames:moveAnimationFrames delay:0.1];
        
        CCAction* moveAction = [CCRepeatForever actionWithAction:
                                [CCAnimate actionWithAnimation:moveAnim restoreOriginalFrame:YES]];
        self.animation = moveAction;
        
      	[node addChild:self.sprite z:225 tag:200];
        [self.sprite runAction:moveAction];
	}
	return self;
}

-(void)dealloc{
    self.animation = nil;
    self.sprite = nil;
    [super dealloc];
}

@end
