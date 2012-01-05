//
//  IntroScene.h
//  bees
//
//  Created by Mihaly Rendes on 11/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
@class MainMenuScene;
@interface IntroScene : CCLayer {
    CCSprite* _defaultSprite;
    ccTime    _timeElapsed;
}

+(id)scene;

@end
