//
//  Bullet.mm
//  bees
//
//  Created by Mihaly Rendes on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet
@synthesize sprite = _sprite;
@synthesize isOutOfScreen = _isOutOfScreen;
@synthesize target = _target;
@synthesize isMoving = _isMoving;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
    }
    
    return self;
}


-(void)  createBox2dBodyDefinitionsForBullets:(b2World*)world{
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
    
    spriteShape.SetAsBox(self.sprite.contentSize.width/PTM_RATIO/6 * self.sprite.scale,
                         self.sprite.contentSize.height/PTM_RATIO/6 * self.sprite.scale);
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

-(void)shotDone{
    CGSize screenSize =  [[CCDirector sharedDirector] winSize];
    _isOutOfScreen = YES;
    self.sprite.position = ccp( -self.sprite.contentSize.width, screenSize.height * CCRANDOM_0_1() * 0.6 + 0.2);
    _isMoving = NO;
}

-(void) fadeOutDone{
    CGSize screenSize =  [[CCDirector sharedDirector] winSize];
    self.sprite.position = ccp( -self.sprite.contentSize.width, screenSize.height * CCRANDOM_0_1() * 0.6 + 0.2);
    self.sprite.opacity = 255;
}

-(void) update{
    if (_isMoving){
        if (_target.x > self.sprite.position.x){
            self.sprite.position = ccp(self.sprite.position.x + CCRANDOM_0_1(), self.sprite.position.y);
        }else if (_target.x < self.sprite.position.x){
            self.sprite.position = ccp(self.sprite.position.x - CCRANDOM_0_1(), self.sprite.position.y);            
        }
        if (_target.y > self.sprite.position.y){
            self.sprite.position = ccp(self.sprite.position.x, self.sprite.position.y + CCRANDOM_0_1());
        }else if (_target.y < self.sprite.position.y){
            self.sprite.position = ccp(self.sprite.position.x, self.sprite.position.y - CCRANDOM_0_1());
        }
    }
}

@end
