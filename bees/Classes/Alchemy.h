//
//  Alchemy.h
//  bees
//
//  Created by macbook white on 8/14/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeEnums.h"
#import "cocos2d.h"
@class HelloWorld;

@interface Alchemy : NSObject {
	int _slot1;
	int _slot2;
	int _slot3;
	int _effect;
	CCNode* _world;
}

-(void) addItem:(int) item;
-(void) generateEffect;
-(void) clearItems;

@property (nonatomic, retain) CCNode* world;

@end
