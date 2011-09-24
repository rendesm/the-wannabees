//
//  Alchemy.m
//  bees
//
//  Created by macbook white on 8/14/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "Alchemy.h"


@implementation Alchemy
@synthesize world = _world;

-(id) init{
	if ((self = [super init])){
		_slot1 = 0;
		_slot2 = 0;
		_slot3 = 0;
		_effect = 0;
	}
	return self;
}

-(void) generateEffect{
	if (_slot1 > 0 && _slot2 > 0 && _slot3 > 0){
		//get the effect from the database
		//right now just use 3 hardcoded values
		if (_slot1 == YELLOW_SLOT && _slot2 == YELLOW_SLOT && _slot3 == YELLOW_SLOT){
			_effect = BOMB_EFFECT;
		}else if (_slot1 == RED_SLOT && _slot2 == RED_SLOT && _slot3 == RED_SLOT){
			_effect = SPEED_EFFECT;
		}else if (_slot1 == BLUE_SLOT && _slot2 == BLUE_SLOT && _slot3 == BLUE_SLOT){
			_effect = DISEASE_EFFECT;
		}else if (_slot1 == BLUE_SLOT && _slot2 == YELLOW_SLOT && _slot3 == YELLOW_SLOT){
			_effect = SHRINK_EFFECT;
		}else if (_slot1 == RED_SLOT){
			_effect = SPEED_EFFECT;
		}else if (_slot1 == YELLOW_SLOT){
			_effect = SHRINK_EFFECT;
		}
		else {
			_effect = 0;
		}
	
		[_world applyEffect:_effect];

		_slot1 = 0;
		_slot2 = 0;
		_slot3 = 0;
	}	
}

-(void) addItem:(int) item{
	if (_slot1 == 0){
		_slot1 = item;
	}else if (_slot2 == 0){
		_slot2 = item;
	}else if (_slot3 == 0){
		_slot3 = item;
	} 
	
	if (_slot1 > 0 && _slot2 > 0 && _slot3 > 0){
		[self generateEffect];
	}
}

-(void) clearItems{
	_slot1 = 0;
	_slot2 = 0;
	_slot3 = 0;
}

-(void) dealloc{
	[_world release];
	_world = nil;
	[super dealloc];
}

@end
