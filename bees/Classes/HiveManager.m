//
//  HiveManager.m
//  bees
//
//  Created by macbook white on 9/12/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "HiveManager.h"


@implementation HiveManager
@synthesize comboFinisher = _comboFinisher;
@synthesize beeMovement = _beeMovement;
@synthesize respawner = _respawner;
@synthesize ownedItems = _ownedItems, unlockedItems = _unlockedItems, secretItems = _secretItems;

static HiveManager *sharedManager = nil;

+ (HiveManager*)sharedManager
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

-(void) dealloc{
	[_beeMovement release];
	[_respawner release];
	[_comboFinisher release];
	[super dealloc];
}

-(void) saveSlotsToPropertyList{
	NSError* error = nil;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"HiveInfo.plist"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath: path]) //4
	{
		NSString *bundle = [[NSBundle mainBundle] pathForResource:@"HiveInfo" ofType:@"plist"]; //5
		[fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
		if (error){
			NSLog(@"error");
		}
	}
	
	NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile: path];
	
	bool changedValues = NO;
	NSDictionary *comboFinisher = [[NSMutableDictionary alloc] initWithDictionary: (NSDictionary*)[data objectForKey:@"ComboFinisher"]];
	if (_comboFinisher.value != [[comboFinisher objectForKey:@"Value"] intValue] || 
		_comboFinisher.type != [[comboFinisher objectForKey:@"Type"] intValue]){
		NSLog(@"comboValue:%i", _comboFinisher.value);
		[comboFinisher setValue:[NSNumber numberWithInt:_comboFinisher.value] forKey:@"Value"];
		[comboFinisher setValue:[NSNumber numberWithInt:_comboFinisher.type] forKey:@"Type"];
		changedValues = YES;
	}

	NSDictionary *respawner = [[NSMutableDictionary alloc] initWithDictionary: (NSDictionary*)[data objectForKey:@"Respawner"]];
	if (_respawner.value != [[respawner objectForKey:@"Value"] intValue] || 
		_respawner.type != [[respawner objectForKey:@"Type"] intValue]){
		NSLog(@"respawnValue:%i", _respawner.value);
		[respawner setValue:[NSNumber numberWithInt:_respawner.value] forKey:@"Value"];
		[respawner setValue:[NSNumber numberWithInt:_respawner.type] forKey:@"Type"];
		changedValues = YES;
	}

	NSDictionary *beeMovement = [[NSMutableDictionary alloc] initWithDictionary: (NSDictionary*)[data objectForKey:@"BeeMovement"]];
	if (_beeMovement.value != [[beeMovement objectForKey:@"Value"] intValue]|| 
		_beeMovement.type != [[beeMovement objectForKey:@"Type"] intValue]){
		NSLog(@"beeMovement:%i", _beeMovement.value);
		[beeMovement setValue:[NSNumber numberWithInt:_beeMovement.value] forKey:@"Value"];
		[beeMovement setValue:[NSNumber numberWithInt:_beeMovement.type]	 forKey:@"Type"];
		changedValues = YES;
	}
	
	if (changedValues) {
		NSLog(@"changedValues");
		[data setValue:beeMovement forKey:@"BeeMovement"];
		[data setValue:respawner forKey:@"Respawner"];
		[data setValue:comboFinisher forKey:@"ComboFinisher"];
	}
	
	if(data && changedValues) {
		[data writeToFile:path atomically:YES];
	}
	else if (error){
		//[error release];
	}
	[data release];	
	[respawner release];
	[comboFinisher release];
	[beeMovement release];
}

-(void) readSlotsPropertyList{
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSString *plistPath;
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
															  NSUserDomainMask, YES) objectAtIndex:0];
	plistPath = [rootPath stringByAppendingPathComponent:@"HiveInfo.plist"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
		plistPath = [[NSBundle mainBundle] pathForResource:@"HiveInfo" ofType:@"plist"];
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
	
	NSMutableDictionary* tmpBeeMovement = [temp objectForKey:@"BeeMovement"];
	self.beeMovement = [[HiveSlot alloc] init];
	self.beeMovement.type =  [[tmpBeeMovement objectForKey:@"Type"] intValue];
	self.beeMovement.value = [[tmpBeeMovement objectForKey:@"Value"] intValue];
	
	NSMutableDictionary* tmpComboFinisher = [temp objectForKey:@"ComboFinisher"];
	self.comboFinisher = [[HiveSlot alloc] init];
	self.comboFinisher.type =  [[tmpComboFinisher objectForKey:@"Type"] intValue];
	self.comboFinisher.value = [[tmpComboFinisher objectForKey:@"Value"] intValue];
	
	NSMutableDictionary* tmpRespawner = [temp objectForKey:@"Respawner"];
	self.respawner = [[HiveSlot alloc] init];
	self.respawner.type =  [[tmpRespawner objectForKey:@"Type"] intValue];
	self.respawner.value = [[tmpRespawner objectForKey:@"Value"] intValue];
}




-(void) readItemsPropertyList{
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSString *plistPath;
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
															  NSUserDomainMask, YES) objectAtIndex:0];
	plistPath = [rootPath stringByAppendingPathComponent:@"HiveItems.plist"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
		plistPath = [[NSBundle mainBundle] pathForResource:@"HiveItems" ofType:@"plist"];
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
	
	
	for (NSString* item in temp){
		HiveItem *hiveItem = [[HiveItem alloc] init];
		NSDictionary* tmpItem = [temp objectForKey:item];
		hiveItem.slotType = [[tmpItem objectForKey:@"SlotType"] intValue];
		hiveItem.price = [[tmpItem objectForKey:@"Price"] intValue];
		hiveItem.unlocked = [[tmpItem objectForKey:@"Unlocked"] boolValue];
		hiveItem.owned = [[tmpItem	objectForKey:@"Owned"] boolValue];
		hiveItem.name = [tmpItem objectForKey:@"Name"] ;	
		if (hiveItem.unlocked && hiveItem.owned){
			[_ownedItems addObject:hiveItem];
		}else if (hiveItem.unlocked && !hiveItem.owned){
			[_unlockedItems addObject:hiveItem];
		}else {
			[_secretItems addObject:hiveItem];
		}
		[hiveItem release];
	}
	
	
}


-(void)saveItemsToPropertyList{
	NSError* error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"HiveItems.plist"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath: path]) //4
	{
		NSString *bundle = [[NSBundle mainBundle] pathForResource:@"HiveItems" ofType:@"plist"]; //5
		[fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
	}
	
	NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
	[data removeAllObjects];
	
	for (int i = 0; i < [_ownedItems count]; i++) {
		HiveItem* item = [_ownedItems objectAtIndex:i];
		NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
		[tmpDict setObject:[NSNumber numberWithInt:item.price] forKey:@"Price"];
		[tmpDict setObject:[NSNumber numberWithInt:item.slotType] forKey:@"SlotType"];
		[tmpDict setObject:[NSNumber numberWithInt:item.value] forKey:@"Value"];
		[tmpDict setObject:[NSNumber numberWithBool:item.owned] forKey:@"Owned"];
		[tmpDict setObject:[NSNumber numberWithBool:item.unlocked] forKey:@"Unlocked"];
		[tmpDict setObject:item.name forKey:@"Name"];
		[data setObject:tmpDict forKey:[NSString stringWithFormat: @"owned%i",i]];
		[tmpDict release];
	}
	
	for (int i = 0; i < [_unlockedItems count]; i++) {
		HiveItem* item = [_unlockedItems objectAtIndex:i];
		NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
		[tmpDict setObject:[NSNumber numberWithInt:item.price] forKey:@"Price"];
		[tmpDict setObject:[NSNumber numberWithInt:item.slotType] forKey:@"SlotType"];
		[tmpDict setObject:[NSNumber numberWithInt:item.value] forKey:@"Value"];
		[tmpDict setObject:[NSNumber numberWithBool:item.owned] forKey:@"Owned"];
		[tmpDict setObject:[NSNumber numberWithBool:item.unlocked] forKey:@"Unlocked"];
		[tmpDict setObject:item.name forKey:@"Name"];
		[data setObject:tmpDict forKey:[NSString stringWithFormat: @"unlocked%i",i]];
		[tmpDict release];
	}
	
	for (int i = 0; i < [_secretItems count]; i++) {
		HiveItem* item = [_secretItems objectAtIndex:i];
		NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
		[tmpDict setObject:[NSNumber numberWithInt:item.price] forKey:@"Price"];
		[tmpDict setObject:[NSNumber numberWithInt:item.slotType] forKey:@"SlotType"];
		[tmpDict setObject:[NSNumber numberWithInt:item.value] forKey:@"Value"];
		[tmpDict setObject:[NSNumber numberWithBool:item.owned] forKey:@"Owned"];
		[tmpDict setObject:[NSNumber numberWithBool:item.unlocked] forKey:@"Unlocked"];
		[tmpDict setObject:item.name forKey:@"Name"];
		[data setObject:tmpDict forKey:[NSString stringWithFormat: @"secret%i",i]];
		[tmpDict release];
	}
	
	if(data) {
		[data writeToFile:path atomically:YES];
	}
	else {
		[error release];
	}
	[data release];	
	
}

@end
