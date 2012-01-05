//
//  HarvesterLayer.m
//  bees
//
//  Created by Mihaly Rendes on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HarvesterLayer.h"
#import "ConfigManager.h"
@implementation HarvesterLayer
@synthesize harvesterSprite = _harvesterSprite, batchnode = _batchnode, canShoot = _canShoot, bullets = _bullets;
@synthesize comboToFinish = _comboFinished;
@synthesize moveInParticle = _moveInParticle;
@synthesize moveOutParticle = _moveOutParticle;
@synthesize timeTillShoot = _timeTillShoot;
@synthesize timeLeftTillNextAppearance = _timeLeftTillNextAppearance;
@synthesize eyes = _eyes;
@synthesize timeElapsed = _timeElapsed;
@synthesize isIn = _isIn;
@synthesize emitter = _emitter;
@synthesize useMist = _useMist;

-(void) shoot{
    //find a bullet out of screen
    [_eyes.sprite runAction:_eyes.animation];
    CGSize screenSize =  [[CCDirector sharedDirector] winSize];
    float rnd = CCRANDOM_0_1();
    for (Bullet* bullet in _bullets) {
        if (bullet.isOutOfScreen){
            bullet.target = ccp (screenSize.width + 20, ((CCRANDOM_0_1() * 3) +1) * screenSize.height/5);
            CCAction* moveAction = [CCMoveTo actionWithDuration:12 position:bullet.target];
            CCAction* moveDone = [CCCallFunc actionWithTarget:bullet selector:@selector(shotDone)];
            [bullet.sprite runAction:[CCSequence actions:moveAction,  moveDone, nil]];
            bullet.isMoving = YES;
            bullet.isOutOfScreen = NO;
            _shootTimer = 0;
            break;
        }
    }
}


-(void) initWithWorld:(b2World*)world{
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        _world = world;
        _timeLeftTillNextAppearance = 40;
        // init the batchnode for the harvester
      //  [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB5A1];
        self.batchnode = [CCSpriteBatchNode batchNodeWithFile:@"harvester_default.pvr.ccz"]; // 1
         [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"harvester_default.plist" textureFile:@"harvester_default.pvr.ccz"];
        [self addChild:_batchnode z:100 tag:1]; // 2
    
        //set the combo properties
        self.comboToFinish = 2;
        _comboFinished = 0;
        self.emitter = nil;

        //create the harvestersprite
        self.harvesterSprite = [CCSprite spriteWithSpriteFrameName:@"harvester.png"];
        [_batchnode addChild:_harvesterSprite z:3000 tag:3];
        [self createBox2dBodyDefinitionsForHarvester];        
        //place it outside of the screen
        _harvesterSprite.position = ccp(-_harvesterSprite.contentSize.width, _harvesterSprite.contentSize.height/2);
        _shootTimer = 0;
        _timeTillShoot = 1;
        
        self.eyes = [[Eyes alloc] initForNode:_harvesterSprite];
        _eyes.sprite.position = ccp( _harvesterSprite.contentSize.width - _eyes.sprite.contentSize.width + 5, _harvesterSprite.contentSize.height - 1.5 * _eyes.sprite.contentSize.height);
        self.bullets = [[NSMutableArray alloc] init];

        //create the bullets and hide them 
        for (int i = 0; i <= 1;i++){
            Bullet* bullet = [[Bullet alloc] init];
            CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"bullet.png"];
            bullet.sprite = sprite;
            [_batchnode addChild:sprite z:2 tag:2];
            bullet.sprite.position = ccp( -bullet.sprite.contentSize.width, screenSize.height * CCRANDOM_0_1() * 0.6 + 0.2);
            bullet.isOutOfScreen = YES;
            [bullet createBox2dBodyDefinitionsForBullets:_world];
            [_bullets addObject:bullet];
            [bullet release];
        }
//        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
}

#pragma mark Box2D body definitions 
-(void) createBox2dBodyDefinitionsForHarvester{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(-200, -200);
    bodyDef.userData = @"harvester";
    bodyDef.fixedRotation = true;
    bodyDef.allowSleep = false;
    bodyDef.awake = true;
    b2Body* body;
    body = _world->CreateBody(&bodyDef);
    
    b2PolygonShape spriteShape;
    
    //row 1, col 1
    int num = 7;
    b2Vec2 verts[] = {
        b2Vec2(10.0f / PTM_RATIO, -155.0f / PTM_RATIO),
        b2Vec2(17.5f / PTM_RATIO, -130.0f / PTM_RATIO),
        b2Vec2(17.0f / PTM_RATIO, -113.0f / PTM_RATIO),
        b2Vec2(70.0f / PTM_RATIO, -35.5f / PTM_RATIO),
        b2Vec2(33.0f / PTM_RATIO, 44.0f / PTM_RATIO),
        b2Vec2(47.5f / PTM_RATIO, 84.5f / PTM_RATIO),
        b2Vec2(5.5f / PTM_RATIO, 156.0f / PTM_RATIO)
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
    
	filter.categoryBits = harvester;
	//filter.maskBits = 0xFFFF ;
    filter.maskBits = player;
	filter.groupIndex = 0;
	
	spriteShapeDef.filter = filter;
    
    body->CreateFixture(&spriteShapeDef);
}



#pragma mark update and movement
-(void) harvesterMovedIn{
    _canShoot = YES;
}

/*
 
 -(void) update:(ccTime)dt{
 CGSize screenSize =  [[CCDirector sharedDirector] winSize];
 if (!self.moveInParticle && !self.moveOutParticle && !_isIn){
 _timeElapsed += dt;
 }
 
 if (_timeElapsed >= _timeLeftTillNextAppearance && self.moveInParticle == NO && _isIn == NO && self.moveOutParticle == NO){
 //move in the harvester
 _timeElapsed = 0;
 self.moveInParticle = YES;
 }
 
 
 
 CCAction* moveOut = [CCMoveTo actionWithDuration:2 position:ccp(self.harvesterSprite.contentSize.width/3, self.harvesterSprite.position.y)];
 
 
 if (self.moveInParticle && (self.harvesterSprite.position.x <= self.harvesterSprite.contentSize.width/7)){
 self.harvesterSprite.position = ccp(self.harvesterSprite.position.x + self.harvesterSprite.contentSize.width/180.0f, _harvesterSprite.contentSize.height/2);
 }else if (self.moveInParticle){
 self.moveInParticle = NO;
 _isIn = YES;
 }else if (_isIn){
 _shootTimer += dt;
 if (_shootTimer >= _timeTillShoot){
 _shootTimer = 0;
 [self shoot];
 }
 }else if (self.moveOutParticle && (self.harvesterSprite.position.x >= -self.harvesterSprite.contentSize.width/2)){
 _comboFinished = 0;
 self.harvesterSprite.position = ccp(self.harvesterSprite.position.x - self.harvesterSprite.contentSize.width/180.0f, _harvesterSprite.contentSize.height/2);
 }else if (self.moveOutParticle){
 for (Bullet* bullet in self.bullets){
 bullet.isMoving = NO;
 bullet.isOutOfScreen = YES;
 CCAction* fadeOut = [CCFadeOut actionWithDuration:1];
 CCAction* fadeOutDone = [CCCallFunc actionWithTarget:bullet selector:@selector(fadeOutDone)];
 [bullet.sprite runAction:[CCSequence actions:fadeOut, fadeOutDone, nil]];
 }
 self.moveOutParticle = NO;
 self.moveInParticle = NO;
 _isIn = NO;
 _shootTimer = 0;
 _comboFinished = 0;
 }
 
 
 for (Bullet* bullet in self.bullets){
 if (bullet.isMoving){
 [bullet update];
 }
  }
 }
 */

-(void)moveInDone{
    self.isIn = YES;
    self.moveInParticle = NO;
    self.moveOutParticle = NO;
    _comboFinished = 0;
    _timeElapsed = 0;
    _comboToSendBack = 2;
}

-(void)moveOutDone{
    self.isIn = NO;
    self.moveOutParticle = NO;
    self.moveInParticle = NO;
    _timeElapsed = 0;
    _comboFinished = 0;
    if (self.emitter != nil){
        [self removeChild:self.emitter cleanup:YES];
        self.emitter = nil;
    }
}

-(void) update:(ccTime)dt{
    CGSize screenSize =  [[CCDirector sharedDirector] winSize];
    if (!self.moveInParticle && !self.moveOutParticle && !_isIn){
        _timeElapsed += dt;
    }

    if (_timeElapsed >= _timeLeftTillNextAppearance && self.moveInParticle == NO && _isIn == NO && self.moveOutParticle == NO){
        //move in the harvester
        _timeElapsed = 0;
        self.moveInParticle = YES;
        CCAction* moveIn = [CCMoveTo actionWithDuration:2 position:ccp(self.harvesterSprite.contentSize.width/3, self.harvesterSprite.position.y)];
        CCCallFunc* moveInDone = [CCCallFunc actionWithTarget:self selector:@selector(moveInDone)];
        [self.harvesterSprite runAction:[CCSequence actions:moveIn, moveInDone,nil]];
        
        if (self.emitter == nil && [[ConfigManager sharedManager] particles] && self.useMist){
            self.emitter = [CCParticleSystemQuad particleWithFile:@"mist2.plist"];
            self.emitter.position = ccp(_harvesterSprite.position.x -_harvesterSprite.contentSize.width, 0);
            self.emitter.scale = 0.5;
            self.emitter.rotation = 180;
            [self addChild:self.emitter z: 3200 tag: 200];
            CCAction* moveIn2 = [CCMoveTo actionWithDuration:2 position:ccp(self.harvesterSprite.contentSize.width/3, 0)];
            [self.emitter runAction:moveIn2];
        }
    }
    
    if (_isIn){
        _shootTimer += dt;
        if (_shootTimer >= _timeTillShoot){
            _shootTimer = 0;
            [self shoot];
        }
    }
    
}

-(void) sendItBack{
    if (_isIn){
        _comboFinished += 1;
        if (_comboToSendBack <= _comboFinished){
            CGSize screenSize = [[CCDirector sharedDirector] winSize];
            _comboFinished = 0;
            _isIn = NO;
            self.moveInParticle = NO;
            self.moveOutParticle = YES;
            CCAction* moveOut = [CCMoveTo actionWithDuration:1.5 position:ccp(-self.harvesterSprite.contentSize.width, self.harvesterSprite.position.y)];
            CCCallFunc* moveOutDone = [CCCallFunc actionWithTarget:self selector:@selector(moveOutDone)];
            [self.harvesterSprite runAction:[CCSequence actions:moveOut, moveOutDone, nil]];
            
            if (self.emitter != nil){
                CCAction* moveOut2 = [CCMoveTo actionWithDuration:1.5 position:ccp(-self.harvesterSprite.contentSize.width * 2, self.harvesterSprite.position.y)];
                [self.emitter runAction:moveOut2];
            }
            
            for (Bullet* bullet in self.bullets){
                [bullet.sprite stopAllActions];
                bullet.isMoving = NO;
                bullet.isOutOfScreen = YES;
                CCAction* fadeOut = [CCFadeOut actionWithDuration:1];
                CCAction* fadeOutDone = [CCCallFunc actionWithTarget:bullet selector:@selector(fadeOutDone)];
                [bullet.sprite runAction:[CCSequence actions:fadeOut, fadeOutDone, nil]];
            }
        }
    }
}

-(void) dealloc{
    [self.bullets removeAllObjects];
    [self.bullets release];
    self.bullets = nil;
    [_eyes release];
    self.harvesterSprite = nil;
    self.emitter = nil;
    [super dealloc];
}

@end
