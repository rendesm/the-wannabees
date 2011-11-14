//
//  HelpLayer.h
//  bees
//
//  Created by Mihaly Rendes on 11/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "MainMenuScene.h"

@interface HelpLayer : CCLayer {
    CCSprite* _currentPicture;
    CCLabelBMFont* _currentTitle;
    CCMenu* _menu;
}
@property (nonatomic, retain) CCSprite* currentPicture;
@property (nonatomic, retain) CCLabelBMFont* currentTitle;
@property (nonatomic, retain) CCMenu* menu;

@end
