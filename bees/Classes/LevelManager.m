//
//  LevelManager.m
//  bees
//
//  Created by macbook white on 9/15/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "LevelManager.h"


@implementation LevelManager
@synthesize campaignLevels = _campaignLevels, timeRaceLevels = _timeRaceLevels, survivalLevels = _survivalLevels;
@synthesize selectedLevel = _selectedLevel;

static LevelManager *sharedManager = nil;

+ (LevelManager*)sharedManager
{
    if (sharedManager == nil) {
        sharedManager = [[super allocWithZone:NULL] init];
    }
    return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedManager] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

-(id) init{
	if ((self = [super init])){
		[self readInLevels];
	}
	return self;
}

-(void) setSelectedHillsLevelWithDifficulty:(int)difficulty withNumber:(int)number{
	NSString* tmpString = [NSString stringWithFormat:@"%i",number];
	self.selectedLevel = [self.campaignLevels objectForKey:tmpString];
	self.selectedLevel.difficulty = difficulty;
	_selectedLevelType == CAMPAIGN;
}

-(void) readInLevels{
	self.campaignLevels = [[NSMutableDictionary alloc]init];
	self.survivalLevels = [[NSMutableDictionary alloc]init];
	self.timeRaceLevels = [[NSMutableDictionary alloc]init];
	NSLog(@"reading levels");
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSString *plistPath;
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
															  NSUserDomainMask, YES) objectAtIndex:0];
	plistPath = [rootPath stringByAppendingPathComponent:@"Levels.plist"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
		plistPath = [[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"];
	}
	
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
										  propertyListFromData:plistXML
										  mutabilityOption:NSPropertyListMutableContainersAndLeaves
										  format:&format
										  errorDescription:&errorDesc];
	if (!temp) {
		NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
	}
	
	NSDictionary* campaignLevels = [[NSMutableDictionary alloc] initWithDictionary: (NSDictionary*)[temp objectForKey:@"Campaign"]];
	for (NSString* key in campaignLevels){
		Level* level = [[Level alloc] init] ;
		NSDictionary* item = [campaignLevels objectForKey:key];
		//self.selectedLevel = [NSString stringWithFormat:@"level%i", _selectedLevelTag + (_selectedWorld - 1) * 3];
		level.distanceToGoal = [[item objectForKey:@"distanceToGoal"] intValue];
		level.highScorePoints = [[item objectForKey:@"highScorePoints"] intValue];
		level.name = key;
		level.backgroundImage = [item objectForKey:@"background"] ;
		level.predatorSpeed = [[item objectForKey:@"predatorSpeed"] floatValue];
		level.difficulty = 0;
		level.sporeAvailable = [[item objectForKey:@"sporeAvailable"] boolValue];
		level.trapAvailable = [[item objectForKey:@"trapAvailable"] boolValue];
		level.completed = [[item objectForKey:@"completed"] boolValue];
		level.unlocked = [[item objectForKey:@"unlocked"] boolValue];
		[self.campaignLevels setObject:level forKey:key];
		[level release];
	}
	
	NSDictionary* survivalLevels = [[NSMutableDictionary alloc] initWithDictionary: (NSDictionary*)[temp objectForKey:@"Survival"]];
	for (NSString* key in survivalLevels){
		Level* level = [[Level alloc] init] ;
		NSDictionary* item = [survivalLevels objectForKey:key];
		//self.selectedLevel = [NSString stringWithFormat:@"level%i", _selectedLevelTag + (_selectedWorld - 1) * 3];
		level.distanceToGoal = -1;
		level.highScorePoints = [[item objectForKey:@"highScorePoints"] intValue];
		level.name = key;
		NSLog(@"reading in level:%@", level.name);
		level.backgroundImage = [item objectForKey:@"background"] ;
		level.predatorSpeed = [[item objectForKey:@"predatorSpeed"] floatValue];
		level.difficulty = 0;
		level.sporeAvailable = [[item objectForKey:@"sporeAvailable"] boolValue];
		level.trapAvailable = [[item objectForKey:@"trapAvailable"] boolValue];
		level.completed = [[item objectForKey:@"completed"] boolValue];
		level.unlocked = [[item objectForKey:@"unlocked"] boolValue];
		[self.survivalLevels setObject:level forKey:key];
		[level release];
	}
	[campaignLevels release];
	campaignLevels = nil;
	[survivalLevels release];
	survivalLevels = nil;
	
	self.timeRaceLevels = [[NSMutableDictionary alloc] initWithDictionary: (NSDictionary*)[temp objectForKey:@"TimeRace"]];	
}

-(void) saveSelectedLevel{
	NSError* error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Levels.plist"];

	NSFileManager *fileManager = [NSFileManager defaultManager];

	if (![fileManager fileExistsAtPath: path]) //4
	{
		NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"]; //5
		[fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
	}

	NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
	
	if (_selectedLevelType == CAMPAIGN){
		NSMutableDictionary *campaignData = [[NSMutableDictionary alloc] initWithDictionary: (NSDictionary*)[data objectForKey:@"Campaign"]];
		NSDictionary *levelData = [[NSMutableDictionary alloc] initWithDictionary: (NSDictionary*)[campaignData objectForKey:_selectedLevel.name]];
		
		[levelData setValue:[NSNumber numberWithInt: _selectedLevel.completed]  forKey:@"completed"];
		[levelData setValue:[NSNumber numberWithInt:self.selectedLevel.highScorePoints] forKey:@"highScorePoints"];
		[campaignData setValue:levelData forKey:_selectedLevel.name];
		
		if (_selectedLevel.completed){
			NSLog(@"trying to unlock next level");
			
			int nextId = [_selectedLevel.name intValue];
			nextId++;
			NSString* nextName = [NSString stringWithFormat:@"%i", nextId];
			
			//first set the instance in memory
			Level* nextLevel = [_campaignLevels objectForKey:nextName];
			nextLevel.unlocked = YES;
			
			NSDictionary *nextLevelData = [[NSMutableDictionary alloc] initWithDictionary: (NSDictionary*)[campaignData objectForKey: nextName]];
			[nextLevelData setValue:[NSNumber numberWithBool:YES]  forKey:@"unlocked"];
			[campaignData setValue:nextLevelData forKey:nextName];
		}
		[data setObject:campaignData forKey:@"Campaign"];
	}else if (_selectedLevelType == SURVIVAL){
		NSMutableDictionary *survivalData = [[NSMutableDictionary alloc] initWithDictionary: (NSDictionary*)[data objectForKey:@"Survival"]];
		NSMutableDictionary *levelData = [[NSMutableDictionary alloc] initWithDictionary: (NSDictionary*)[survivalData objectForKey:_selectedLevel.name]];
		[levelData setValue:[NSNumber numberWithInt: self.selectedLevel.highScorePoints] forKey:@"highScorePoints"];
		[survivalData setValue:levelData forKey:_selectedLevel.name];
		[data setObject:survivalData forKey:@"Survival"];
	}

	if(data) {
		[data writeToFile:path atomically:YES];
	}
	else {
		[error release];
	}
	[data release];
}

-(void) setSurvivalLevel:(NSString*)name withDifficulty:(int)difficulty{
	self.selectedLevel = [self.survivalLevels objectForKey:name];
	self.selectedLevel.difficulty = difficulty;
	_selectedLevelType = SURVIVAL;
}

-(void) dealloc{
	[_campaignLevels release];
	_campaignLevels = nil;
	[_survivalLevels release];
	_survivalLevels = nil;
	[_timeRaceLevels release];
	_timeRaceLevels = nil;
	[super dealloc];
}

@end
