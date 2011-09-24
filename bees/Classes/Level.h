//
//  Level.h
//  bees
//
//  Created by macbook white on 8/10/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Level : NSObject {
	int _highScoreDistance;
	int _highScorePoints;
	float _distanceToGoal;
	NSString* _name;
	NSString* _backgroundImage;
	float _predatorSpeed;
	int _difficulty;
	bool _trapAvailable;
	bool _sporeAvailable;
	bool _completed;
	bool _unlocked;
}
@property (nonatomic) int highScoreDistance;
@property (nonatomic) int highScorePoints;
@property (nonatomic) float distanceToGoal;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* backgroundImage;
@property (nonatomic) float  predatorSpeed;
@property (nonatomic) int difficulty;
@property (nonatomic) bool trapAvailable;
@property (nonatomic) bool sporeAvailable;
@property (nonatomic) bool completed;
@property (nonatomic) bool unlocked;

@end
