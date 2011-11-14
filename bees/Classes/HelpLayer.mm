//
//  HelpLayer.m
//  bees
//
//  Created by Mihaly Rendes on 11/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HelpLayer.h"


@implementation HelpLayer
@synthesize currentTitle = _currentTitle, currentPicture = _currentPicture, menu = _menu;


-(id) init{
    if ((self = [super init])){
        
    }
    return self;
}



- (void)onEnter
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (void)onExit
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	
}






@end
