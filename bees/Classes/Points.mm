//
//  Point.m
//  bees
//
//  Created by macbook white on 7/28/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "Points.h"


@implementation Points
@synthesize sprite = _sprite;
@synthesize scaledBoundingBox = _scaledBoundingBox;
@synthesize value = _value;
@synthesize collisionType = _collistionType;
@synthesize taken = _taken;
@synthesize type = _type;
@synthesize isOnScreen = _isOnScreen;
@synthesize moveAction = _moveAction, moveDone = _moveDone, moving = _moving;

-(id) initWithFileName:(NSString*) fileName withValue:(int)value{
	if ((self = [super init])){
		self.sprite = [CCSprite spriteWithSpriteFrameName:fileName];
		_value = value;
        self.sprite.scale = 0.7;
        [self startRotate];
        self.moveDone = NO;
        self.moving = NO;
	}
	return self;
}


-(void) startRotate{
    CCAction* rotateLeft = [CCRotateBy actionWithDuration:1 angle:90];
    CCAction* rotateRight = [CCRotateBy actionWithDuration:1 angle:-90];
    [self.sprite runAction:[CCRepeatForever actionWithAction:[CCSequence actions:rotateLeft, rotateRight, nil]]];
}

#pragma mark BOX2D collision detection
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
	
    spriteShape.SetAsBox(self.sprite.contentSize.width/PTM_RATIO/2 * self.sprite.scale,
                         self.sprite.contentSize.height/PTM_RATIO/2 * self.sprite.scale);
    b2FixtureDef spriteShapeDef;
    spriteShapeDef.shape = &spriteShape;
    spriteShapeDef.density = 1.0f;
	spriteShapeDef.friction = 1.0f;
	spriteShapeDef.restitution = 1.0f;
    spriteShapeDef.isSensor = false;
    b2Filter filter;
    
    enum CollideBits { none = 0, player = 0x0001, predator = 0x0002, harvester = 0x0004, point = 0x0008, bird = 0x0010, bullet = 0x0020 };
    
	filter.categoryBits = point;
	//filter.maskBits = 0xFFFF ;
    filter.maskBits = player;
	filter.groupIndex = 0;
	
	spriteShapeDef.filter = filter;
    body->CreateFixture(&spriteShapeDef);
}

-(void) moveDone{
    self.isOnScreen = NO;
    self.moving = NO;
    self.moveDone = YES;
}

-(void) update{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    CCAction* callback = [CCCallFunc actionWithTarget:self selector:@selector(moveDone)];
    if (self.sprite.position.y < screenSize.height/2){
        CCAction* moveUp   = [CCMoveTo actionWithDuration:7 position:ccp(self.sprite.position.x, screenSize.height + self.sprite.contentSize.height * self.sprite.scale)];
        [self.sprite runAction:[CCSequence actions:moveUp, callback, nil]];
    }else{
        CCAction* moveDown   = [CCMoveTo actionWithDuration:7 position:ccp(self.sprite.position.x, -self.sprite.contentSize.height * self.sprite.scale)];
        self.moveAction = [CCSequence actions:moveDown, callback, nil];
        [self.sprite runAction:self.moveAction];        
    }
    self.moving = YES;
    self.moveDone = NO;
}

-(void) dealloc{
	[super dealloc];
//	self.sprite = nil;
    self.moveAction = nil;
}

@end
