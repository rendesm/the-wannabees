//
//  Eyes.h
//  bees
//
//  Created by Mihaly Rendes on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "TypeEnums.h"

@interface Eyes : NSObject{
    CCSprite* _sprite;
    CCAction* _animation;
}

@property (nonatomic, retain) CCSprite* sprite;
@property (nonatomic, retain) CCAction* animation;

- (id)initForNode:(CCNode*)node;

@end
