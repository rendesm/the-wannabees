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



@end
