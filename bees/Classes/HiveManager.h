//
//  HiveManager.h
//  bees
//
//  Created by macbook white on 9/12/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiveSlot.h"
#import "HiveItem.h"

@interface HiveManager : NSObject {
	HiveSlot* _comboFinisher;
	HiveSlot* _respawner;
	HiveSlot* _beeMovement;
	
	NSMutableArray* _ownedItems;
	NSMutableArray* _unlockedItems;
	NSMutableArray* _secretItems;
}

@property (nonatomic, retain) HiveSlot* comboFinisher;
@property (nonatomic, retain) HiveSlot* respawner;
@property (nonatomic, retain) HiveSlot* beeMovement;
@property (nonatomic, retain) NSMutableArray* ownedItems;
@property (nonatomic, retain) NSMutableArray* unlockedItems;
@property (nonatomic, retain) NSMutableArray* secretItems;


-(void) saveSlotsToPropertyList;
-(void) readSlotsPropertyList;

-(void)saveItemsToPropertyList;
-(void)readItemsPropertyList;


@end
