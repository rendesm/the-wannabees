//
//  Point.h
//  bees
//
//  Created by macbook white on 7/28/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "TypeEnums.h"

@interface Points : NSObject {
	CCSprite* _sprite;
	CGRect _scaledBoundingBox;
	int _value;
	int _collistionType;
	bool _taken;
	int _type;
    bool _isOnScreen;
    bool _moveDone;
    bool _moving;
    CCAction* _moveAction;
}


@property (nonatomic) bool taken;
@property (nonatomic, retain) CCSprite* sprite;
@property (nonatomic) CGRect scaledBoundingBox;
@property (nonatomic) int value;
@property (nonatomic) int collisionType;
@property (nonatomic) int type;
@property (nonatomic) bool isOnScreen;
@property (nonatomic, retain) CCAction* moveAction;
@property (nonatomic) bool moveDone;
@property (nonatomic) bool moving;
-(id)   initWithFileName:(NSString*) fileName withValue:(int)value;
-(void) createBox2dBodyDefinitions:(b2World*)world;
-(void) update;
-(void) startRotate;
@end
