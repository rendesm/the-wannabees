//
//  ClippingNode.m
//  bees
//
//  Created by Mihaly Rendes on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "ClippingNode.h"

@interface ClippingNode (PrivateMethods)
-(void) deviceOrientationChanged:(NSNotification*)notification;
@end

@implementation ClippingNode

-(id) init
{
    if ((self = [super init]))
    {
        // register for device orientation change events
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) 
                                                     name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

-(void) dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [super dealloc];
}

-(CGRect) clippingRegion
{
    return clippingRegionInNodeCoordinates;
}

-(void) setClippingRegion:(CGRect)region
{
    // keep the original region coordinates in case the user wants them back unchanged
    clippingRegionInNodeCoordinates = region;
    self.position = clippingRegionInNodeCoordinates.origin;
    self.contentSize = clippingRegionInNodeCoordinates.size;
    
    CCDirector* director = [CCDirector sharedDirector];
    CGSize screenSize = [director winSize];
    
    // glScissor requires the coordinates to be rotated to portrait mode
    switch (director.deviceOrientation)
    {
        default:
        case kCCDeviceOrientationPortrait:
            // do nothing, coords are already correct
            break;
            
        case kCCDeviceOrientationPortraitUpsideDown:
            region.origin.x = screenSize.width - region.size.width - region.origin.x;
            region.origin.y = screenSize.height - region.size.height - region.origin.y;
            break;
            
        case kCCDeviceOrientationLandscapeLeft:
            region.origin = CGPointMake(region.origin.y, screenSize.width - region.size.width - region.origin.x);
            region.size = CGSizeMake(region.size.height, region.size.width);
            break;
            
        case kCCDeviceOrientationLandscapeRight:
            region.origin = CGPointMake(screenSize.height - region.size.height - region.origin.y, region.origin.x);
            region.size = CGSizeMake(region.size.height, region.size.width);
            break;
    }
    
    // convert to retina coordinates if needed
    region = CC_RECT_POINTS_TO_PIXELS(region);
    
    // respect scaling
    clippingRegion = CGRectMake(region.origin.x * scaleX_, region.origin.y * scaleY_, 
                                region.size.width * scaleX_, region.size.height * scaleY_);
}

-(void) setScale:(float)newScale
{
    [super setScale:newScale];
    // re-adjust the clipping region according to the current scale factor
    [self setClippingRegion:clippingRegionInNodeCoordinates];
}

-(void) deviceOrientationChanged:(NSNotification*)notification
{
    // re-adjust the clipping region according to the current orientation
    [self setClippingRegion:clippingRegionInNodeCoordinates];
}

-(void) visit
{
    glPushMatrix();
    glEnable(GL_SCISSOR_TEST);
    glScissor(clippingRegion.origin.x + positionInPixels_.x, clippingRegion.origin.y + positionInPixels_.y,
              clippingRegion.size.width, clippingRegion.size.height);
    
    [super visit];
    
    glDisable(GL_SCISSOR_TEST);
    glPopMatrix();
}

@end