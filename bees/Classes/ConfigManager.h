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
	int  _difficulty;
}

@property (nonatomic) bool music;
@property (nonatomic) bool sounds;
@property (nonatomic) bool particles;
@property (nonatomic) int  difficulty;

@end
