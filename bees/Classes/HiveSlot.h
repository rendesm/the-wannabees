//
//  HiveSlot.h
//  bees
//
//  Created by macbook white on 9/12/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HiveSlot : NSObject {
	int _type; 
	int _value;
}

@property (nonatomic) int type;
@property (nonatomic) int value;

@end
