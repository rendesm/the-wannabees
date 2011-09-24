//
//  Atka.m
//  bees
//
//  Created by macbook white on 8/5/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "Atka.h"


@implementation Atka
@synthesize sprite = _sprite;

-(id) initForNode:(CCNode*) node{
	if ((self = [super init])){
		/*
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:
		 @"atka.plist"];
		
		CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode 
										  batchNodeWithFile:@"atka.png"];
		[node addChild:spriteSheet z:300 tag:400];
		*/
		
		/*NSMutableArray *moveAnimationFrames = [[NSMutableArray alloc] init];
		
		
		for(int i = 1; i <= 6; ++i) {
			[moveAnimationFrames addObject:
			 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
			  [NSString stringWithFormat:@"atka%d.png", i]]];
		}
		 
				
		
		CCAnimation *moveAnim = [CCAnimation 
								 animationWithFrames:moveAnimationFrames delay:0.05f];
		*/
		
		_sprite = [CCSprite spriteWithSpriteFrameName:@"atka1.png"];
        _sprite.scale = 0.8;
		_sprite.opacity =  180;
	//	_moveAction = [CCRepeatForever actionWithAction:
	//				   [CCAnimate actionWithAnimation:moveAnim restoreOriginalFrame:NO ]];
	//	[_sprite runAction:_moveAction];
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
	
    spriteShape.SetAsBox(_sprite.contentSize.width/PTM_RATIO/2  * _sprite.scale,
                         _sprite.contentSize.height/PTM_RATIO/2  * _sprite.scale);
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