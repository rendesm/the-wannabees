//
//  HarvesterLayer.h
//  bees
//
//  Created by Mihaly Rendes on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "Bullet.h"
#import "Eyes.h"

@interface HarvesterLayer : CCLayer {
    CCSprite* _harvesterSprite;
    CCSpriteBatchNode* _batchnode;
    ccTime _timeElapsed;
    ccTime _timeLeftTillNextAppearance;
    bool _canShoot;
    b2World *_world;
    NSMutableArray* _bullets;
    bool _isMoving;
    int _comboFinished;
    int _comboToSendBack;
    float _timeTillShoot;
    float _shootTimer;
    bool _moveInParticle;
    bool _moveOutParticle;
    bool _isIn;
    Eyes* _eyes;
    CCParticleSystemQuad* _emitter;
    bool _useMist;
}

-(void) update:(ccTime)dt;
-(void) harvesterMovedIn;
-(void) createBox2dBodyDefinitionsForHarvester;
-(void) initWithWorld:(b2World*)world;
-(void) sendItBack;

@property (nonatomic, retain) CCSprite* harvesterSprite;
@property (nonatomic, retain) CCSpriteBatchNode* batchnode;
@property (nonatomic) bool canShoot;
@property (nonatomic, retain) NSMutableArray* bullets;
@property (nonatomic) int comboToFinish;
@property (nonatomic) bool moveInParticle;
@property (nonatomic) bool moveOutParticle;
@property (nonatomic) float timeTillShoot;
@property (nonatomic) ccTime timeLeftTillNextAppearance;
@property (nonatomic, retain) Eyes* eyes;
@property (nonatomic) ccTime timeElapsed;
@property (nonatomic) bool isIn;
@property (nonatomic, retain) CCParticleSystemQuad* emitter;
@property (nonatomic) bool useMist;
@end
