//
//  LevelSelectCaves.h
//  bees
//
//  Created by macbook white on 9/17/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "Level.h"
#import "TypeEnums.h"



@interface LevelSelectCaves : CCLayer {
	CCSprite* _background;
	CCMenu* _launchMenu;
	
	NSMutableArray* _easyLevelSprites;
	
	CCParticleSystemQuad *_emitter;
	bool _tappable;
	CCSprite* _selectedSprite;
	float _buttonHeight;
}

@property (nonatomic, retain) CCSprite* background;
@property (nonatomic, retain) CCMenu* launchMenu;
@property (nonatomic, retain) CCParticleSystemQuad* emitter;

@property (nonatomic, retain) NSMutableArray* easyLevelSprites;
@property (nonatomic, retain) CCSprite* selectedSprite;

@property (nonatomic, retain) Level* selectedLevel;

@end
