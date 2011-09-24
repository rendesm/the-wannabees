//
//  HiveItem.h
//  bees
//
//  Created by macbook white on 9/13/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HiveItem : NSObject {
	bool _owned;
	bool _unlocked;
	int _price;
	int _value;
	int _slotType;
	NSString* _name;
}

@property (nonatomic) bool owned;
@property (nonatomic) bool unlocked;
@property (nonatomic) int  price;
@property (nonatomic) int  value;
@property (nonatomic) int  slotType;
@property (nonatomic, retain) NSString* name;

@end
