//
//  LevelManager.h
//  bees
//
//  Created by macbook white on 9/15/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Level.h"
#import "TypeEnums.h"

@interface LevelManager : NSObject {
	NSMutableDictionary* _campaignLevels;
	NSMutableDictionary* _timeRaceLevels;
	NSMutableDictionary* _survivalLevels;
	Level* _selectedLevel;
	int _selectedLevelType;
    int _world;
}

@property (nonatomic, retain) NSMutableDictionary* campaignLevels;
@property (nonatomic, retain) NSMutableDictionary* timeRaceLevels;
@property (nonatomic, retain) NSMutableDictionary* survivalLevels;
@property (nonatomic, retain) Level* selectedLevel;
@property (nonatomic) int world;


-(void) readInLevels;
-(void) saveSelectedLevel;
-(void) setSelectedHillsLevelWithDifficulty:(int)difficulty withNumber:(int)number;
-(void) setSurvivalLevel:(NSString*)name withDifficulty:(int)difficulty;

@end
