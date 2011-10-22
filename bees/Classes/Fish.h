//
//  Fish.h
//  bees
//
//  Created by Mihaly Rendes on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "TypeEnums.h"

@interface Fish : NSObject{
    CCSprite* _sprite;
    bool _isJumping;
    bool _isDead;
    CCAction* _animation;
}

@property(nonatomic, retain)CCSprite* sprite;
@property(nonatomic) bool isJumping;
@property(nonatomic) bool isDead;
@property(nonatomic, retain) CCAction* animation;

- (void)createBox2dBodyDefinitions:(b2World*)world;
- (id)initForNode:(CCNode*)node;
- (void)jumpDone:(id)sprite;
-(id) initForCampaignNode:(CCNode*)node;

@end
