//
//  HiveScene.m
//  bees
//
//  Created by macbook white on 9/12/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "HiveScene.h"
#import "LevelSelectScene.h"
#import "CaveScene.h"
#import "CampaignScene.h"
#import "MainMenuScene.h"
#import "Level.h"

@implementation HiveScene

+(id)scene{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object 
	HiveScene *layer = [HiveScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init{
	if ((self = [super init])){
		
		//add a button
		CCMenuItemImage *backButton = [CCMenuItemImage 
									   itemFromNormalImage:@"back.png" selectedImage:@"backTapped.png" 
									   target:self selector:@selector(backTapped)];
		
		CCMenu* playMenu = [CCMenu menuWithItems:backButton,nil];
		[self addChild:playMenu z:201 tag:3];
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		playMenu.position =  ccp( size.width - backButton.contentSize.width/3 * 2, size.height - 60 );
		
		HiveManager* sharedManager = [HiveManager sharedManager];
		[sharedManager readSlotsPropertyList];
		[sharedManager saveSlotsToPropertyList];
		
		NSString* string = [NSString stringWithFormat:@"BeeMovement with type:%i   with Value:%i", sharedManager.beeMovement.type, sharedManager.beeMovement.value];
		NSString* string2 = [NSString stringWithFormat:@"Combo with type:%i   with Value:%i", sharedManager.comboFinisher.type, sharedManager.comboFinisher.value];
		NSString* string3 = [NSString stringWithFormat:@"Respaw with type:%i   with Value:%i", sharedManager.respawner.type, sharedManager.respawner.value];
		CCLabelTTF* comboFinisher = [[CCLabelTTF alloc] initWithString:string fontName:@"Arial" fontSize:12];
		CCLabelTTF* comboFinisher2 = [[CCLabelTTF alloc] initWithString:string2 fontName:@"Arial" fontSize:12];
		CCLabelTTF* comboFinisher3 = [[CCLabelTTF alloc] initWithString:string3 fontName:@"Arial" fontSize:12];
		comboFinisher.position = ccp(120,220);
		comboFinisher2.position = ccp(120,120);
		comboFinisher3.position = ccp(120,20);
		[self addChild:comboFinisher z:50 tag:60];
		[self addChild:comboFinisher2 z:50 tag:60];
		[self addChild:comboFinisher3 z:50 tag:60];
		
		[sharedManager readItemsPropertyList];
		[sharedManager saveItemsToPropertyList];
	}
	return self;
}

-(void) backTapped {
	[[CCDirector sharedDirector] replaceScene:[MainMenuScene scene]];
}

@end
