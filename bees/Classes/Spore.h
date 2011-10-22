//
//  Spore.h
//  bees
//
//  Created by macbook white on 8/4/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "TypeEnums.h"

@interface Spore : NSObject {
	CCSprite *_sprite;
	CCAction *_moveAction;
	CCNode *_emitterNode;
    CCAction* _animation;
}

-(id) initForNode:(CCNode*) node;
-(id) initForCaveNode:(CCNode*) node;
-(id) initForSeaNode:(CCNode*) node;
- (void)createBox2dBodyDefinitions:(b2World*)world;
-(void)createBox2dBodyDefinitionsBird:(b2World*)world;
-(void)createBox2dBodyDefinitionsSeaBird:(b2World*)world;

@property (nonatomic, retain) CCSprite* sprite;
@property (nonatomic, retain) CCNode* emitterNode;
@property (nonatomic, retain) CCAction* animation;


@end
