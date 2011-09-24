//
//  Bat.h
//  bees
//
//  Created by macbook white on 9/6/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "TypeEnums.h"

@interface Bat : NSObject {
	CCSprite* _sprite;
	ccTime _timeLeftForGuano;
	ccTime _maxGuanoTime;
	CCNode* _parentNode;
	int _life;
}

@property (nonatomic, retain) CCSprite* sprite;
@property (nonatomic) ccTime maxGuanoTime;
@property (nonatomic) ccTime timeLeftForGuano;
@property (nonatomic) int life;

- (void)createBox2dBodyDefinitions:(b2World*)world;
- (id) initForPosition:(CGPoint)point forNode:(CCNode*)node withTime:(ccTime)time;

@end
