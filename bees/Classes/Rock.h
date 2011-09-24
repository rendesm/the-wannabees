//
//  Rock.h
//  bees
//
//  Created by macbook white on 9/2/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "TypeEnums.h"


@interface Rock : NSObject {
	CCSprite* _sprite;
	int _type;
}

@property (nonatomic, retain) CCSprite* sprite;
@property (nonatomic) int type;

- (void)createBox2dBodyDefinitions:(b2World*)world;
- (id) initWithFileName:(NSString*) fileName;


@end
