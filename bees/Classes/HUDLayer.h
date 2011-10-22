//
//  HUDLayer.h
//  bees
//
//  Created by macbook white on 9/23/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface HUDLayer : CCLayer {
	CCSprite *_pointsSprite;
	CCLabelBMFont* _pointsLabel;
	CCSprite *_item1;
	CCSprite *_item2;
	CCSprite *_item3;
	CCSprite* _goal1Sprite;
	CCSprite* _goal2Sprite;
	CCSprite* _goal3Sprite;
	CCSprite* _goal1Slot;
	CCSprite* _goal2Slot;
	CCSprite* _goal3Slot;
	CCSprite* _slot1;
	CCSprite* _slot2;
	CCSprite* _slot3;
	
	NSMutableArray* _goals;
}

-(void) initLabels;
-(void) clearItems;
-(void) clearGoals;
-(CCSprite*)createGoalSprite:(CCSprite*) sprite forGoal:(int)goal;
-(void) createGoalSpritesForGoals;
-(void)addItem:(NSString*)item;
-(void) updatePoints:(int)pointsGathered;

@property (nonatomic, retain) NSMutableArray* goals;

@end
