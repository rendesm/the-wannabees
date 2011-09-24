//
//  Spore.m
//  bees
//
//  Created by macbook white on 8/4/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "Spore.h"


@implementation Spore
@synthesize sprite = _sprite;

-(id) initForNode:(CCNode*) node{
	if ((self = [super init])){
	/*	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:
		 @"fireBall.plist"];
		
		CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode 
										  batchNodeWithFile:@"fireBall.png"];
		[node addChild:spriteSheet z:300 tag:400];
		
		*/
		
		
		
		/*
		NSMutableArray *moveAnimationFrames = [NSMutableArray array];
		for(int i = 1; i <= 6; ++i) {
			[moveAnimationFrames addObject:
			 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
			  [NSString stringWithFormat:@"fireball_000%d.png", i]]];
		}
		
		CCAnimation *moveAnim = [CCAnimation 
								 animationWithFrames:moveAnimationFrames delay:0.1f];
		
		*/
		_sprite = [CCSprite spriteWithSpriteFrameName:@"fireball_0001.png"];        
	//	_moveAction = [CCRepeatForever actionWithAction:
	//				   [CCAnimate actionWithAnimation:moveAnim restoreOriginalFrame:NO]];
	//	[_sprite runAction:_moveAction];
		
		//_sprite.opacity = 0;
		_sprite.scale = 0.6;
		[node addChild:_sprite];
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
    spriteShapeDef.isSensor = true;
	
    body->CreateFixture(&spriteShapeDef);
}

-(void) dealloc{
	_sprite = nil;
	_moveAction = nil;
	[super dealloc];
}

@end
