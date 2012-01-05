//
//  HelpScene.h
//  bees
//
//  Created by Mihaly Rendes on 11/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
@class MainMenuScene;
@interface HelpScene : CCLayer {
    CCSprite* _background;
    int _currentTutorial;
    NSString* _currentText;
    CCLabelTTF* _currentLabel;
    CCSprite* _arrow;
}

@property (nonatomic, retain) CCSprite* background;
@property (nonatomic, retain) NSString* currentText;
@property (nonatomic, retain) CCLabelTTF* currentLabel;
@property (nonatomic, retain) CCSprite* arrow;


@end
