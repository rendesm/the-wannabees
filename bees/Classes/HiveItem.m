//
//  HiveItem.m
//  bees
//
//  Created by macbook white on 9/13/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "HiveItem.h"


@implementation HiveItem
@synthesize name = _name, slotType = _slotType, unlocked = _unlocked, owned = _owned, price = _price;



-(void) dealloc{
	self.name = nil;
	[super dealloc];
}

@end
