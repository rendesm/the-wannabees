//
//  PointTaken.h
//  bees
//
//  Created by macbook white on 8/13/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PointTaken : CCActionInterval{
	CGPoint _toPoint;
	CGPoint _fromPoint;
	CGPoint _dPoint;
	float	_dOpacity;
}

+(id) actionWithDuration:(ccTime)d moveTo:(CGPoint)toPoint;
-(id) initWithDuration:(ccTime)d moveTo:(CGPoint)toPoint;

@end
