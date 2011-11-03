//
//  Snake.h
//  bees
//
//  Created by Mihaly Rendes on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "cocos2d.h"
#import "Box2D.h"
#import "TypeEnums.h"

@interface Snake : NSObject {
	CCSprite*   _sprite;
    bool        _isOnScreen;
    CCAction* _animation;
}

@property (nonatomic, retain) CCSprite* sprite;
@property (nonatomic) bool   isOnScreen;
@property (nonatomic, retain) CCAction* animation;

- (void) createBox2dBodyDefinitions:(b2World*)world;
- (id)   initForDesertNode:(CCNode*)node;

@end