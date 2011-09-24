//
//  ComboFinisher.h
//  bees
//
//  Created by macbook white on 9/20/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "TypeEnums.h" 

@interface ComboFinisher : NSObject {
	CCSprite* _sprite;
	bool _taken;
	int _type;
}

@property (nonatomic, retain) CCSprite* sprite;
@property (nonatomic) bool taken;
@property (nonatomic) int type;

-(id) initWithFileName:(NSString*) fileName;
- (void)createBox2dBodyDefinitions:(b2World*)world;

@end
