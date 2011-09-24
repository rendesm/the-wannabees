//
//  Level.m
//  bees
//
//  Created by macbook white on 8/10/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "Level.h"


@implementation Level
@synthesize distanceToGoal = _distanceToGoal;
@synthesize highScoreDistance = _highScoreDistance;
@synthesize highScorePoints = _highScorePoints;
@synthesize name = _name;
@synthesize backgroundImage = _backgroundImage;
@synthesize predatorSpeed = _predatorSpeed;
@synthesize difficulty = _difficulty;
@synthesize sporeAvailable = _sporeAvailable;
@synthesize trapAvailable = _trapAvailable;
@synthesize completed = _completed;
@synthesize unlocked = _unlocked;

-(id) init{
	if ((self = [super init])){
		
	}
	return self;
}

@end
