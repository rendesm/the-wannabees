//
//  Terrain.h
//  bees
//
//  Created by macbook white on 7/18/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "BeeImports.h"

#define kMaxHillKeyPoints 1000
#define kMaxBorderVertices 800 
#define kMaxHillVertices 4000
#define kHillSegmentWidth 10 //120
@interface Terrain : CCNode {
    int _offsetX;
    CGPoint _hillKeyPoints[kMaxHillKeyPoints];
    CCSprite *_stripes;
	int _fromKeyPointI;
	int _toKeyPointI;
	
	int _nHillVertices;
	CGPoint _hillVertices[kMaxHillVertices];
	CGPoint _hillTexCoords[kMaxHillVertices];
	int _nBorderVertices;
	CGPoint _borderVertices[kMaxBorderVertices];
	
	b2World *_world;
	b2Body *_body;
//	GLESDebugDraw * _debugDraw;	
}

@property (retain) CCSprite * stripes;
- (void) setOffsetX:(float)newOffsetX;
- (void) resetHillVertices;
- (id)initWithWorld:(b2World *)world;
-(void) generateHills;

@end