//
//  Guano.h
//  bees
//
//  Created by macbook white on 9/10/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "cocos2d.h"
#import "Box2D.h"
#import "TypeEnums.h"


@interface Guano : NSObject {
	CCSprite* _sprite;
	bool _isActive;
	float _speed;
}

@property (nonatomic, retain) CCSprite* sprite;
@property (nonatomic) bool isActive;
@property (nonatomic) float speed;

- (void)createBox2dBodyDefinitions:(b2World*)world;
- (id) initWithFileName:(NSString*) fileName;

@end
