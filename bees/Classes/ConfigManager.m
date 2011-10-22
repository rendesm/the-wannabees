//
//  ConfigManager.m
//  bees
//
//  Created by macbook white on 9/5/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "ConfigManager.h"


@implementation ConfigManager
@synthesize music = _music;
@synthesize sounds = _sounds;
@synthesize particles = _particles;
@synthesize difficulty = _difficulty;
@synthesize gfx = _gfx;

static ConfigManager *sharedConfigManager = nil;

+ (ConfigManager*)sharedManager
{
    if (sharedConfigManager == nil) {
        sharedConfigManager = [[super allocWithZone:NULL] init];
    }
    return sharedConfigManager;
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
    if (self = [super init]){
        [self readInPropertyList];
    }
    return self;
}


-(void) readInPropertyList{
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSString *plistPath;
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
															  NSUserDomainMask, YES) objectAtIndex:0];
	plistPath = [rootPath stringByAppendingPathComponent:@"GameInfo.plist"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
		plistPath = [[NSBundle mainBundle] pathForResource:@"GameInfo" ofType:@"plist"];
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
    
	self.music = [[temp objectForKey:@"Music"] boolValue];
	self.sounds = [[temp objectForKey:@"Sounds"] boolValue];
	self.particles = [[temp objectForKey:@"Particles"] boolValue];
    self.gfx = [[temp objectForKey:@"Gfx"] intValue];
}
	

-(void) savePropertyList{
	NSError* error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"GameInfo.plist"];
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath: path]) //4
	{
		NSString *bundle = [[NSBundle mainBundle] pathForResource:@"GameInfo" ofType:@"plist"]; //5
		[fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
	}
	
	NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
	
	[data setObject:[NSNumber numberWithBool: self.music] forKey:@"Music"];
	[data setObject:[NSNumber numberWithBool: self.sounds] forKey:@"Sounds"];
	[data setObject:[NSNumber numberWithBool: self.particles] forKey:@"Particles"];
    [data setObject:[NSNumber numberWithInt:  self.gfx] forKey:@"Gfx"];
	if(data) {
		[data writeToFile:path atomically:YES];
	}
	else {
		[error release];
	}
	[data release];
}


-(void) switchMusic{
    self.music = !self.music;
}

-(void) switchSounds{
    self.sounds = !self.sounds;
}

-(void) switchParticles{
    self.particles = !self.particles;
}

-(void) incrGfx{
    if (self.gfx < 3){
        self.gfx++;
    }else{
        self.gfx = 1;
    }
}


@end
