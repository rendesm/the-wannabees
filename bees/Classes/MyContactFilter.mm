//
//  MyContactFilter.m
//  bees
//
//  Created by macbook white on 8/20/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "MyContactFilter.h"

MyContactFilter::MyContactFilter(){
}

MyContactFilter::~MyContactFilter() {
}

bool MyContactFilter::ShouldCollide(b2Fixture* fixtureA, b2Fixture* fixtureB){
	b2Body *bodyA = fixtureA->GetBody();
	b2Body *bodyB = fixtureB->GetBody();
	if (bodyA->GetUserData()  != NULL && bodyB->GetUserData() != NULL){
		if ([bodyA->GetUserData() isKindOfClass:[Boid class]] && [bodyB->GetUserData() isKindOfClass:[Boid class]] &&
			![bodyB->GetUserData() isKindOfClass:[Predator class]] && ![bodyA->GetUserData() isKindOfClass:[Predator class]]){
			return false;
		}else if ([bodyA->GetUserData() isKindOfClass:[Points class]] && [bodyB->GetUserData() isKindOfClass:[Predator class]] ) {
			return false;
		}
		else if ([bodyA->GetUserData() isKindOfClass:[Predator class]] && [bodyB->GetUserData() isKindOfClass:[Points class]] ) {
			return false;
		}else if ([bodyA->GetUserData() isKindOfClass:[Atka class]] && [bodyB->GetUserData() isKindOfClass:[Spore class]] ) {
			return false;
		}else if ([bodyA->GetUserData() isKindOfClass:[Spore class]] && [bodyB->GetUserData() isKindOfClass:[Atka class]] ) {
			return false;
		}else if ([bodyA->GetUserData() isKindOfClass:[Atka class]] && [bodyB->GetUserData() isKindOfClass:[Points class]] ) {
			return false;
		}else if ([bodyA->GetUserData() isKindOfClass:[Points class]] && [bodyB->GetUserData() isKindOfClass:[Atka class]] ) {
			return false;
		}else if ([bodyA->GetUserData() isKindOfClass:[Spore class]] && [bodyB->GetUserData() isKindOfClass:[Points class]] ) {
			return false;
		}else if ([bodyA->GetUserData() isKindOfClass:[Points class]] && [bodyB->GetUserData() isKindOfClass:[Spore class]] ) {
			return false;
		}
	}else{
		return true;
	}
}




@end
