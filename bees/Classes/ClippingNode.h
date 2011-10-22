//
//  ClippingNode.h
//  bees
//
//  Created by Mihaly Rendes on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"

/** Restricts (clips) drawing of all children to a specific region. */
@interface ClippingNode : CCNode 
{
    CGRect clippingRegionInNodeCoordinates;
    CGRect clippingRegion;
}

@property (nonatomic) CGRect clippingRegion;

@end