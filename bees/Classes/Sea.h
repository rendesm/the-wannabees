//
//  Sea.h
//  bees
//
//  Created by macbook white on 9/21/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"
#import "Box2D.h"
#import "TypeEnums.h"

@interface Sea : NSObject {
	CCSprite* _sprite;
}

@property (nonatomic, retain) CCSprite* sprite;

- (void)createBox2dBodyDefinitions:(b2World*)world;
-(id) initForNode:(CCNode*)node;

@end
