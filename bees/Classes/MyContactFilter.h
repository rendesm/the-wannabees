//
//  MyContactFilter.h
//  bees
//
//  Created by macbook white on 8/20/11.
//  Copyright 2011 nincs. All rights reserved.
//

//#import "Box2D.h"
#import "BeeImports.h"

class MyContactFilter : public b2ContactFilter {
public:	
	MyContactFilter();
    ~MyContactFilter();
	bool ShouldCollide(b2Fixture* fixtureA, b2Fixture* fixtureB);
};
