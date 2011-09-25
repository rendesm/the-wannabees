//
//  PointTaken.m
//  bees
//
//  Created by macbook white on 8/13/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "PointTaken.h"


@implementation PointTaken

+(id) actionWithDuration:(ccTime)d moveTo:(CGPoint)toPoint{
	return [[[self alloc] initWithDuration:d moveTo:toPoint] autorelease];
}

-(id) initWithDuration:(ccTime)d moveTo:(CGPoint)toPoint{
	if ( (self=[super initWithDuration:d] ) )
		_toPoint = toPoint;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] moveTo: _toPoint];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	_fromPoint = ((CCSprite*)self.target).position;
	_dPoint = ccp((_toPoint.x - _fromPoint.x)/self.duration, (_toPoint.y - _fromPoint.y)/self.duration);
}


/*
-(void) start
{
	[super start];
}*/

-(void) update: (ccTime) t
{		
	((CCSprite*)self.target).position = ccp(_fromPoint.x + _dPoint.x * t, _fromPoint.y - _dPoint.y * t);
	((CCSprite*)self.target).scale = 1-t;

}

@end
