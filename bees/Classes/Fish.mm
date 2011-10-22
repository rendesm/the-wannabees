//
//  Fish.m
//  bees
//
//  Created by Mihaly Rendes on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Fish.h"

@implementation Fish
@synthesize sprite = _sprite, isJumping = _isJumping;
@synthesize isDead;
@synthesize animation = _animation;

-(id) initForNode:(CCNode*)node{
	if ((self = [super init])){
		self.sprite = [CCSprite spriteWithSpriteFrameName:@"hal1.png"];
        
        
        NSMutableArray *moveAnimationFrames = [NSMutableArray array];
        for(int i = 1; i <= 6; ++i) {
            [moveAnimationFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"hal%d.png", i]]];
        }
        
//        self.sprite.scale = 1.0;
		[node addChild:self.sprite z:3 tag:200];
        CCAnimation *moveAnim = [CCAnimation 
                                 animationWithFrames:moveAnimationFrames delay:0.1f];
        
        
        CCAction* moveAction = [CCRepeatForever actionWithAction:
                                [CCAnimate actionWithAnimation:moveAnim restoreOriginalFrame:YES]];
        self.animation = moveAction;
      //  [_sprite runAction:moveAction];

        _isJumping = NO;
        _isDead = NO;
	}
	return self;
}

-(id) initForCampaignNode:(CCNode*)node{
    if ((self = [super init])){
		self.sprite = [CCSprite spriteWithSpriteFrameName:@"madarka1.png"];
        NSMutableArray *moveAnimationFrames = [NSMutableArray array];
        for(int i = 2; i <= 12; ++i) {
            NSString* frameName = [NSString stringWithFormat:@"madarka%i.png",i];
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
        _isJumping = NO;
        _isDead = NO;
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
	
    spriteShape.SetAsBox(_sprite.contentSize.width/PTM_RATIO * 0.5  * _sprite.scale,
                         _sprite.contentSize.height/PTM_RATIO * 0.5 * _sprite.scale);
    b2FixtureDef spriteShapeDef;
    spriteShapeDef.shape = &spriteShape;
    spriteShapeDef.density = 1.0f;
	spriteShapeDef.friction = 1.0f;
	spriteShapeDef.restitution = 1.0f;
    spriteShapeDef.isSensor = true;
    
    b2Filter filter;
    
    enum CollideBits { none = 0, player = 0x0001, predator = 0x0002, harvester = 0x0004, point = 0x0008, bird = 0x0010, bullet = 0x0020 };
    
	filter.categoryBits = predator;
	//filter.maskBits = 0xFFFF ;
    filter.maskBits = player | harvester | bird | bullet;
	filter.groupIndex = 0;
	
	spriteShapeDef.filter = filter;
	
    body->CreateFixture(&spriteShapeDef);
}


- (id)init
{
    self = [super init];
    if (self) {
        _isJumping = NO;
    }
    
    return self;
}

-(void)jumpDone:(id)sprite{
    self.isJumping = NO;
}

-(void) dealloc{
	self.sprite = nil;
	[super dealloc];
}


@end
