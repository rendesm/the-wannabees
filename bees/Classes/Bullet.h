//
//  Bullet.h
//  bees
//
//  Created by Mihaly Rendes on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "TypeEnums.h"

@interface Bullet : NSObject{
    CCSprite* _sprite;
    bool _isOutOfScreen;
    CGPoint _target;
    bool _isMoving;
}

-(void)  createBox2dBodyDefinitionsForBullets:(b2World*)world;
-(void)  shotDone;
-(void)  update;
-(void)  fadeOutDone;

@property (nonatomic, retain) CCSprite* sprite;
@property (nonatomic)bool isOutOfScreen;
@property (nonatomic)CGPoint target;
@property (nonatomic)bool isMoving;

@end
