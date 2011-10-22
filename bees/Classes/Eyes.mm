//
//  Eyes.m
//  bees
//
//  Created by Mihaly Rendes on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Eyes.h"

@implementation Eyes
@synthesize sprite = _sprite;
@synthesize animation = _animation;

- (id)initForNode:(CCNode*)node{
    self = [super init];
    if (self) {
        self.sprite = [CCSprite spriteWithSpriteFrameName:@"eye_p0.png"];

        NSMutableArray *moveAnimationFrames = [NSMutableArray array];
        for(int i = 1; i <= 10; ++i) {
            [moveAnimationFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"eye_p%d.png", i]]];
        }
        
        for (int i = 10; i >=1; i--){
            [moveAnimationFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"eye_p%d.png", i]]];
        }
        
        [node addChild:self.sprite z:300 tag:200];
        CCAnimation *moveAnim = [CCAnimation animationWithFrames:moveAnimationFrames delay:0.025f];
        
        CCAction* moveAction =  [CCAnimate actionWithAnimation:moveAnim restoreOriginalFrame:YES];
        self.animation = moveAction;
      //  [_sprite runAction:self.animation];
    }
    return self;
}

-(void) dealloc{
    self.animation = nil;
    self.sprite = nil;
    [super dealloc];
}

@end
