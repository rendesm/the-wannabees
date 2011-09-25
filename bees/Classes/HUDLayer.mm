//
//  HUDLayer.m
//  bees
//
//  Created by macbook white on 9/23/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "HUDLayer.h"
#import "TypeEnums.h"

@implementation HUDLayer
@synthesize goals = _goals;

+(id)scene{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HUDLayer *layer = [HUDLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) initLabels{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];	
	
	CCSprite* _rightOrnament;
	CCSprite* _ornament1;
	CCSprite* _ornament2;
	CCSprite* _ornament3;
	CCSprite* _effectSprite;
	

	_item1 = nil;
	_item2 = nil;
	_item3 = nil;
	
	_effectSprite = [CCSprite spriteWithFile:@"darkenCornersFlowersEffect.png"];
	_effectSprite.position = ccp(screenSize.width/2, screenSize.height/2);
	_effectSprite.scale = 0.5;	
	[self addChild:_effectSprite z:600 tag:999];
	
	float ornamentWidth;
	float slotWidth;
	
	_ornament1 = [CCSprite spriteWithSpriteFrameName:@"leftOrnament.png"];
	_ornament2 = [CCSprite spriteWithSpriteFrameName:@"leftOrnament.png"];
	_ornament3 = [CCSprite spriteWithSpriteFrameName:@"leftOrnament.png"];
	_slot1 = [CCSprite spriteWithSpriteFrameName:@"emptySlot.png"];
	_slot2 = [CCSprite spriteWithSpriteFrameName:@"emptySlot.png"];
	_slot3 = [CCSprite spriteWithSpriteFrameName:@"emptySlot.png"]; 
	
	ornamentWidth = _ornament1.contentSize.width;
	slotWidth = _slot1.contentSize.width;
	
	_ornament1.position = ccp(ornamentWidth/2 * _ornament1.scale, 
							  screenSize.height - _slot1.contentSize.height * _slot1.scale);
	_slot1.position = ccp(_ornament1.position.x + ornamentWidth/2 * _ornament1.scale + slotWidth/2 * _slot1.scale,
						  screenSize.height - _slot1.contentSize.height * _slot1.scale);
	
	
	_ornament2.position = ccp(_ornament1.position.x + ornamentWidth * _ornament1.scale +slotWidth/2 * _slot1.scale,
							  _slot1.position.y);
	
	_slot2.position = ccp(_ornament2.position.x + ornamentWidth/2 * _ornament2.scale + slotWidth/2 * _slot2.scale, 
						  _slot1.position.y);
	
	_ornament3.position = ccp(_ornament2.position.x + ornamentWidth * _ornament2.scale +slotWidth/2 * _slot2.scale,
							  _slot2.position.y);
	
	_slot3.position = ccp(_ornament3.position.x + ornamentWidth/2 * _ornament3.scale + slotWidth/2 * _slot3.scale, 
						  _slot1.position.y);
	
	
	[self addChild:_ornament1 z:100 tag:100];
	[self addChild:_ornament2 z:100 tag:100];
	[self addChild:_ornament3 z:100 tag:100];
	
	[self addChild:_slot1 z:100 tag:100];
	[self addChild:_slot2 z:100 tag:100];
	[self addChild:_slot3 z:100 tag:100];
	
	
	_rightOrnament = [CCSprite spriteWithSpriteFrameName:@"leftOrnament.png"];
	_rightOrnament.rotation = 180;
	_rightOrnament.position = ccp(screenSize.width - _rightOrnament.contentSize.width/2, _ornament1.position.y);
	[self addChild:_rightOrnament];
	
	_pointsSprite = [CCSprite spriteWithSpriteFrameName:@"emptySlot.png"];
	//	_pointsSprite.scale = 0.5;
	_pointsSprite.position = ccp(_rightOrnament.position.x - _rightOrnament.contentSize.width/2 - _pointsSprite.contentSize.width/2 * _pointsSprite.scale,
								 _rightOrnament.position.y);
	
	[self addChild:_pointsSprite z:100 tag:100];
	
	_pointsLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:12];
	_pointsLabel.position = _pointsSprite.position;
	_pointsLabel.color = ccWHITE;
	[self addChild:_pointsLabel z: 300 tag:301];
	
	
	//goals section	
	_goal1Slot = [CCSprite spriteWithSpriteFrameName:@"emptySlot.png"];
	_goal2Slot = [CCSprite spriteWithSpriteFrameName:@"emptySlot.png"];
	_goal3Slot = [CCSprite spriteWithSpriteFrameName:@"emptySlot.png"];
	
	_goal1Slot.scale = 0.6;
	_goal2Slot.scale = 0.6;
	_goal3Slot.scale = 0.6;
	
	_goal1Slot.position = ccp(_slot3.position.x + _slot3.contentSize.width*_slot3.scale*2, _slot3.position.y);
	_goal2Slot.position = ccp(_goal1Slot.position.x + _goal1Slot.contentSize.width * _goal1Slot.scale, _slot3.position.y);
	_goal3Slot.position = ccp(_goal2Slot.position.x + _goal2Slot.contentSize.width * _goal2Slot.scale, _slot3.position.y);
	[self addChild:_goal1Slot z:101 tag:101];
	[self addChild:_goal2Slot z:101 tag:101];
	[self addChild:_goal3Slot z:101 tag:101];
}

-(void) clearItems{
	if (_item1) {
		[self removeChild:_item1 cleanup:YES];
		_item1 = nil;
	}
	if (_item2){
		[self removeChild:_item2 cleanup:YES];
		_item2 = nil;
	}
	if (_item3){
		[self removeChild:_item3 cleanup:YES];
		_item3 = nil;
	}
}


-(void) clearGoals{
	[self removeChild:_goal1Sprite cleanup:YES];
	_goal1Sprite = nil;
	[self removeChild:_goal2Sprite cleanup:YES];
	_goal2Sprite = nil;
	[self removeChild:_goal3Sprite cleanup:YES];
	_goal3Sprite = nil;
}


-(void) createGoalSpritesForGoals{
	int goal1 = [[_goals objectAtIndex:0] intValue];
	int goal2 = [[_goals objectAtIndex:1] intValue];
	int goal3 = [[_goals objectAtIndex:2] intValue];
	
	_goal1Sprite = [self createGoalSprite:_goal1Sprite forGoal:goal1];
	_goal2Sprite = [self createGoalSprite:_goal2Sprite forGoal:goal2];
	_goal3Sprite = [self createGoalSprite:_goal3Sprite forGoal:goal3];
	
	_goal1Sprite.scale = 0.6;
	_goal2Sprite.scale = 0.6;
	_goal3Sprite.scale = 0.6;
	
	_goal1Sprite.position = _goal1Slot.position;
	_goal2Sprite.position = _goal2Slot.position;
	_goal3Sprite.position = _goal3Slot.position;
	
	[self addChild:_goal1Sprite z:101 tag:101];
	[self addChild:_goal2Sprite z:101 tag:101];
	[self addChild:_goal3Sprite z:101 tag:101];
}


-(void)addItem:(NSString*)item{
	if (_item1 == nil) {
		_item1 = [CCSprite spriteWithSpriteFrameName:item];
		_item1.position = _slot1.position;
		[self addChild:_item1 z:110 tag:100];
	}else if(_item2 == nil){
		_item2 = [CCSprite spriteWithSpriteFrameName:item];
		_item2.position = _slot2.position;
		[self addChild:_item2 z:110 tag:100];
	}else if(_item3 == nil){
		_item3 = [CCSprite spriteWithSpriteFrameName:item];
		_item3.position = _slot3.position;
		[self addChild:_item3 z:110 tag:100];
	}
}

-(CCSprite*)createGoalSprite:(CCSprite*) sprite forGoal:(int)goal{
	if (goal == RED_SLOT){
		sprite = [CCSprite spriteWithSpriteFrameName:@"redFlower.png"];
	}else if (goal == BLUE_SLOT) {
		sprite = [CCSprite spriteWithSpriteFrameName:@"blueFlower.png"];
	}else if (goal == YELLOW_SLOT) {
		sprite = [CCSprite spriteWithSpriteFrameName:@"yellowFlower.png"];
	}
	return sprite;
}


-(void) updatePoints:(int)pointsGathered{
 [_pointsLabel setString:[NSString stringWithFormat:@"%i", pointsGathered]];   
}


@end
