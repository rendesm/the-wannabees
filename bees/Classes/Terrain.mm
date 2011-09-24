//
//  Terrain.m
//  bees
//
//  Created by macbook white on 7/18/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "Terrain.h"


@implementation Terrain
@synthesize stripes = _stripes;

- (void) resetBox2DBody {
    if(_body) {
        _world->DestroyBody(_body);
    }
    b2BodyDef bd;
    bd.position.Set(0, 0);
    _body = _world->CreateBody(&bd);
    b2PolygonShape shape;
    b2Vec2 p1, p2;
    for (int i=0; i<_nBorderVertices-1; i++) {
        p1 = b2Vec2(_borderVertices[i].x/PTM_RATIO * self.scale,_borderVertices[i].y/PTM_RATIO * self.scale);
        p2 = b2Vec2(_borderVertices[i+1].x/PTM_RATIO * self.scale,_borderVertices[i+1].y/PTM_RATIO * self.scale);
        shape.SetAsEdge(p1, p2);
		b2FixtureDef spriteShapeDef;
		spriteShapeDef.shape = &shape;
		spriteShapeDef.density = 1.0f;
		spriteShapeDef.friction = 1.0f;
		spriteShapeDef.restitution = 1.0f;
		spriteShapeDef.isSensor = true;
        _body->CreateFixture(&spriteShapeDef);
    }
}

- (id)initWithWorld:(b2World *)world {
    if ((self = [super init])) {
        _world = world;
		self.scale = 0.5;
        [self generateHills];
        [self resetHillVertices];

    }
    return self;
}

- (void) resetHillVertices{
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	
	static int prevFromKeyPointI = -1;
	static int prevToKeyPointI = -1;
	// key points interval for drawing
    while (_hillKeyPoints[_fromKeyPointI+1].x < _offsetX-screenSize.width/2/self.scale) {
        _fromKeyPointI++;
    }
    while (_hillKeyPoints[_toKeyPointI].x < _offsetX+screenSize.width*3/2/self.scale) {
        _toKeyPointI++;
    }
		
	//if (prevFromKeyPointI != _fromKeyPointI || prevToKeyPointI != _toKeyPointI) {
		/*
		// vertices for visible area
		_nHillVertices = 0;
		_nBorderVertices = 0;
		CGPoint p0, p1, pt0, pt1;
		p0 = _hillKeyPoints[_fromKeyPointI];
		for (int i=_fromKeyPointI+1; i<_toKeyPointI+1; i++) {
			p1 = _hillKeyPoints[i];
			
			// triangle strip between p0 and p1
			int hSegments = floorf((p1.x-p0.x)/kHillSegmentWidth);
			float dx = (p1.x - p0.x) / hSegments;
			pt0 = p0;
			
			for (int j=1; j<hSegments+1; j++) {
				pt1 = p1;

				_hillVertices[_nHillVertices] = CGPointMake(pt0.x, 0);
				_hillTexCoords[_nHillVertices++] = CGPointMake(pt0.x/512, 1.0f);
				_hillVertices[_nHillVertices] = CGPointMake(pt1.x, 0);
				_hillTexCoords[_nHillVertices++] = CGPointMake(pt1.x/512, 1.0f);
				
				_hillVertices[_nHillVertices] = CGPointMake(pt0.x, pt0.y);
				_hillTexCoords[_nHillVertices++] = CGPointMake(pt0.x/512, 0);
				_hillVertices[_nHillVertices] = CGPointMake(pt1.x, pt1.y);
				_hillTexCoords[_nHillVertices++] = CGPointMake(pt1.x/512, 0);
				
				pt0 = pt1;
			}
			
			p0 = p1;
		}
		
		prevFromKeyPointI = _fromKeyPointI;
		prevToKeyPointI = _toKeyPointI;    
		 */  // vertices for visible area
		if (prevFromKeyPointI != _fromKeyPointI || prevToKeyPointI != _toKeyPointI) {
			
			// vertices for visible area
			_nHillVertices = 0;
			_nBorderVertices = 0;
			CGPoint p0, p1, pt0, pt1;
			p0 = _hillKeyPoints[_fromKeyPointI];
			for (int i=_fromKeyPointI+1; i<_toKeyPointI+1; i++) {
				p1 = _hillKeyPoints[i];
				
				// triangle strip between p0 and p1
				int hSegments = floorf((p1.x-p0.x)/kHillSegmentWidth);
				float dx = (p1.x - p0.x) / hSegments;
				float da = M_PI / hSegments;
				float ymid = (p0.y + p1.y) / 2;
				float ampl = (p0.y - p1.y) / 2;
				pt0 = p0;
				_borderVertices[_nBorderVertices++] = pt0;
				for (int j=1; j<hSegments+1; j++) {
					pt1.x = p0.x + j*dx;
					pt1.y = ymid + ampl * cosf(da*j);
					_borderVertices[_nBorderVertices++] = pt1;
					
					_hillVertices[_nHillVertices] = CGPointMake(pt0.x, 0);
					_hillTexCoords[_nHillVertices++] = CGPointMake(pt0.x/512, 1.0f);
					_hillVertices[_nHillVertices] = CGPointMake(pt1.x, 0);
					_hillTexCoords[_nHillVertices++] = CGPointMake(pt1.x/512, 1.0f);
					
					_hillVertices[_nHillVertices] = CGPointMake(pt0.x, pt0.y);
					_hillTexCoords[_nHillVertices++] = CGPointMake(pt0.x/512, 0);
					_hillVertices[_nHillVertices] = CGPointMake(pt1.x, pt1.y);
					_hillTexCoords[_nHillVertices++] = CGPointMake(pt1.x/512, 0);
					
					pt0 = pt1;
				}
				
				p0 = p1;
			}
			
			prevFromKeyPointI = _fromKeyPointI;
			prevToKeyPointI = _toKeyPointI;  
		}
}


	 
-(void) generateHills{
	CGSize winSize = [CCDirector sharedDirector].winSize;
	float x = 0;
	float y = winSize.width/2;
	for (int i = 0; i < kMaxHillKeyPoints; i++){
		_hillKeyPoints[i] = CGPointMake(x,y);
		x += winSize.width/2;
		y = random() % (int) winSize.height/2;
		while (true) {
			if(y <= winSize.height/4){
				y = random() % (int) winSize.height/2;
			}
			else {
				break;
			}
		}
	}
}

-(id) init{
	if ((self = [super init])){
		[self generateHills];
		[self resetHillVertices];
		self.scale = 0.5;
	}
	return self;
}

-(void) draw{
	glBindTexture(GL_TEXTURE_2D, _stripes.texture.name);
	glDisableClientState(GL_COLOR_ARRAY);
	
	glColor4f(1, 1, 1, 1);
	glVertexPointer(2, GL_FLOAT, 0, _hillVertices);
	glTexCoordPointer(2, GL_FLOAT, 0, _hillTexCoords);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)_nHillVertices);
	
	
	
	/*
	for (int i = MAX(_fromKeyPointI, 1); i <= _toKeyPointI; ++i){
		ccDrawLine(_hillKeyPoints[i-1], _hillKeyPoints[i]);
	 
	}*/
}

- (void) setOffsetX:(float)newOffsetX {
    _offsetX += newOffsetX / self.scale;
    //self.position = CGPointMake(-_offsetX*self.scale, 0);
	[self draw];
	[self resetHillVertices];
}

- (void)dealloc {
    [_stripes release];
    _stripes = NULL;
    [super dealloc];
}


@end
