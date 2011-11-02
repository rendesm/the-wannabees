//
//  Predator.h
//  bees
//
//  Created by macbook white on 7/20/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "Boid.h"
#import "TypeEnums.h"


@interface Predator : Boid {
	float _life;
	CGPoint _target;
	bool _isHungry;
	float _stamina;
	int _type;
    bool _isOutOfScreen;
}

@property (nonatomic) float life;
@property (nonatomic) CGPoint target;
@property (nonatomic) int type;
@property (nonatomic) float stamina;
@property (nonatomic) bool isOutOfScreen;

-(void)update:(ccTime)dt;

-(void) attackTarget;

-(void) gotHit:(float)damage;
-(void) escape;
-(void) berserk;
- (void)createBox2dBodyDefinitions:(b2World*)world;


@end
