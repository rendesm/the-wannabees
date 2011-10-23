//
//  HillsBackgroundLayer.h
//  bees
//
//  Created by Mihaly Rendes on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Fish.h"
@interface DesertBackgroundLayer : CCLayer {
    CCSpriteBatchNode*  _batchnode;
    NSMutableArray* _hills;
    NSMutableArray* _backHills;
    NSMutableArray* _trees;
    NSMutableArray* _backTrees;
    NSMutableArray* _clouds;
    NSMutableArray* _buildings;
    NSMutableArray* _cloudSpeeds;
    bool _backItemOn;
    bool _forItemOn;
    float _forSpeed;
    NSMutableArray* _fish;
    float _maxFishJump;
    float _minFishDistance;
    float _jumpSpeed;
    CCSprite* _overLaySprite;
}

@property (nonatomic, retain) NSMutableArray* hills;
@property (nonatomic, retain) NSMutableArray* backHills;
@property (nonatomic, retain) NSMutableArray* trees;
@property (nonatomic, retain) NSMutableArray* backTrees;
@property (nonatomic, retain) NSMutableArray* clouds;
@property (nonatomic, retain) NSMutableArray* buildings;
@property (nonatomic, retain) NSMutableArray* cloudSpeeds;
@property (nonatomic, retain) CCSpriteBatchNode* batchnode;
@property (nonatomic) float forSpeed;
@property (nonatomic, retain) NSMutableArray* fish;
@property (nonatomic) float minFishDistance;
@property (nonatomic) float jumpSpeed;
@property (nonatomic) float maxFishJump;

-(void) createBackground;
-(void) fadeInOverlay;
-(void) fadeOutOverlay;
-(void) updateBackground:(ccTime)dt;
-(void) respawnContinuosBackGround;
-(void) genBackground;
-(void) respawnRandomItems;
-(void) moveFishToNewPosition:(Fish*) predator;

@end
