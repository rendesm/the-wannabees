//
//  ConfigManager.h
//  bees
//
//  Created by macbook white on 9/5/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ConfigManager : NSObject {
	bool _music;
	bool _sounds;
	bool _particles;
    int  _gfx;
	int  _difficulty;
}

@property (nonatomic) bool music;
@property (nonatomic) bool sounds;
@property (nonatomic) bool particles;
@property (nonatomic) int  difficulty;
@property (nonatomic) int  gfx;

+ (ConfigManager*)sharedManager;
-(void) readInPropertyList;
-(void) switchMusic;
-(void) switchSounds;
-(void) switchParticles;
-(void) incrGfx;
-(void) savePropertyList;
@end
