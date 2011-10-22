//
//  BackgroundLayer.h
//  bees
//
//  Created by Mihaly Rendes on 10/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BackgroundLayer : CCLayer {
    NSMutableArray* _backgrounds;
}

@property(nonatomic, retain) NSMutableArray* backgrounds;


-(void)addBackgrounds:(NSMutableArray*) backgrounds forZ:(int)z;
-(void)update:(ccTime)dt;
@end
