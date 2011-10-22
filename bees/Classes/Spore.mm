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
@synthesize animation = _animation;

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
		/*
        NSMutableArray *moveAnimationFrames = [NSMutableArray array];
        for(int i = 0; i <= 8; ++i) {
            [moveAnimationFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"bird%d.png", i]]];
        }
        
        for(int i = 7; i <= 1; --i) {
            [moveAnimationFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"bird%d.png", i]]];
        }
        
        
        CCAnimation *moveAnim = [CCAnimation 
                                 animationWithFrames:moveAnimationFrames delay:0.05f];
        
        */
		_sprite = [CCSprite spriteWithSpriteFrameName:@"madarka2.png"];        
//        _moveAction = [CCRepeatForever actionWithAction:
  //                     [CCAnimate actionWithAnimation:moveAnim restoreOriginalFrame:YES]];
    //    [_sprite runAction:_moveAction];
		
		//_sprite.opacity = 0;
        _sprite.scale = 0.6;
		[node addChild:_sprite z:502 tag:502];
	//	_moveAction = [CCRepeatForever actionWithAction:
	//				   [CCAnimate actionWithAnimation:moveAnim restoreOriginalFrame:NO]];
	//	[_sprite runAction:_moveAction];
		
		//_sprite.opacity = 0;
//		_sprite.scale = 1.6;
		//[node addChild:_sprite];
	}
	return self;
}


-(id) initForCaveNode:(CCNode*) node{
	if ((self = [super init])){
        /*	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:
		 @"fireBall.plist"];
         
         CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode 
         batchNodeWithFile:@"fireBall.png"];
         [node addChild:spriteSheet z:300 tag:400];
         
         */
		 
		_sprite = [CCSprite spriteWithSpriteFrameName:@"gas.png"];        
        //_sprite.opacity = 0;
        //_sprite.scale = 0.6;
		[node addChild:_sprite z:502 tag:502];
	}
	return self;
}


-(id) initForSeaNode:(CCNode*) node{
    if ((self = [super init])){
    self.sprite = [CCSprite spriteWithSpriteFrameName:@"tmadar0.png"];
    NSMutableArray *moveAnimationFrames = [NSMutableArray array];
    for(int i = 1; i <= 8; ++i) {
        NSString* frameName = [NSString stringWithFormat:@"tmadar%i.png",i];
        [moveAnimationFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
    }
    
    //        self.sprite.scale = 1.0;
    CCAnimation *moveAnim = [CCAnimation 
                             animationWithFrames:moveAnimationFrames delay:0.025f];
    
    CCAction* moveAction = [CCRepeatForever actionWithAction:
                            [CCAnimate actionWithAnimation:moveAnim restoreOriginalFrame:YES]];
    self.animation = moveAction;
    
    [node addChild:self.sprite z:225 tag:200];
    [self.sprite runAction:moveAction];
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
    
	filter.categoryBits = harvester;
	//filter.maskBits = 0xFFFF ;
    filter.maskBits = player | predator;
	filter.groupIndex = 0;
	
	spriteShapeDef.filter = filter;
	
    body->CreateFixture(&spriteShapeDef);
}

-(void)createBox2dBodyDefinitionsBird:(b2World*)world{
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
    int num = 5;
    b2Vec2 verts[] = {
        b2Vec2(328.0f / PTM_RATIO, 2.0f / PTM_RATIO),
        b2Vec2(-24.0f / PTM_RATIO, 294.0f / PTM_RATIO),
        b2Vec2(-392.0f / PTM_RATIO, 274.0f / PTM_RATIO),
        b2Vec2(-436.0f / PTM_RATIO, 2.0f / PTM_RATIO),
        b2Vec2(-128.0f / PTM_RATIO, -74.0f / PTM_RATIO)
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
    
	filter.categoryBits = harvester;
	//filter.maskBits = 0xFFFF ;
    filter.maskBits = player | predator;
	filter.groupIndex = 0;
	
	spriteShapeDef.filter = filter;
	
	body->CreateFixture(&spriteShapeDef);    
}



-(void)createBox2dBodyDefinitionsSeaBird:(b2World*)world{
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
    int num = 7;
    b2Vec2 verts[] = {
        b2Vec2(22.9f / PTM_RATIO, -11.2f / PTM_RATIO),
        b2Vec2(23.1f / PTM_RATIO, 5.7f / PTM_RATIO),
        b2Vec2(9.6f / PTM_RATIO, 13.5f / PTM_RATIO),
        b2Vec2(-1.7f / PTM_RATIO, 8.2f / PTM_RATIO),
        b2Vec2(-23.1f / PTM_RATIO, 5.9f / PTM_RATIO),
        b2Vec2(0.8f / PTM_RATIO, 2.9f / PTM_RATIO),
        b2Vec2(7.5f / PTM_RATIO, -12.3f / PTM_RATIO)
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
    
	filter.categoryBits = harvester;
	//filter.maskBits = 0xFFFF ;
    filter.maskBits = player | predator;
	filter.groupIndex = 0;
	
	spriteShapeDef.filter = filter;
	
	body->CreateFixture(&spriteShapeDef);    
}


-(void) dealloc{
	_sprite = nil;
	_moveAction = nil;
	[super dealloc];
}

@end
