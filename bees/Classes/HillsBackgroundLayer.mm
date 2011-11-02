//
//  HillsBackgroundLayer.m
//  bees
//
//  Created by Mihaly Rendes on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HillsBackgroundLayer.h"
#import "ConfigManager.h"

@implementation HillsBackgroundLayer
@synthesize batchnode = _batchnode, hills = _hills, backHills = _backHills, trees = _trees, backTrees = _backTrees, clouds = _clouds, buildings = _buildings;
@synthesize forSpeed = _forSpeed;
@synthesize cloudSpeeds = _cloudSpeeds;
@synthesize fish = _fish;
@synthesize minFishDistance = _minFishDistance;
@synthesize jumpSpeed = _jumpSpeed;
@synthesize maxFishJump = _maxFishJump;

+(id)scene{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HillsBackgroundLayer *layer = [HillsBackgroundLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init{
    if ((self = [super init])){
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        self.batchnode = [CCSpriteBatchNode batchNodeWithFile:@"trees_default.pvr.ccz"];
        [self addChild:_batchnode];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"trees_default.plist" textureFile:@"trees_default.pvr.ccz"];
        
        self.hills = [[NSMutableArray alloc] init];
        self.backHills = [[NSMutableArray alloc] init];
        self.trees = [[NSMutableArray alloc] init];
        self.backTrees = [[NSMutableArray alloc] init];
     //   self.clouds = [[NSMutableArray alloc] init];
        self.cloudSpeeds = [[NSMutableArray alloc] init];
        self.fish = [[NSMutableArray alloc] init];
        _maxFishJump = screenSize.height/3;
    }
    return self;
}



- (ccColor4F)randomBrightColor {
    
    while (true) {
        float requiredBrightness = 192;
        ccColor4B randomColor = 
        ccc4(arc4random() % 255,
             arc4random() % 255, 
             arc4random() % 255, 
             255);
        if (randomColor.r > requiredBrightness || 
            randomColor.g > requiredBrightness ||
            randomColor.b > requiredBrightness) {
            return ccc4FFromccc4B(randomColor);
        }        
    }
}

-(CCSprite *)spriteWithColor:(ccColor4F)bgColor textureSize:(float)textureSize withNoise:(NSString*)inNoise withGradientAlpha:(float)gradientAlpha{
    // 1: Create new CCRenderTexture
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureSize height:textureSize];
	
    // 2: Call CCRenderTexture:begin
    [rt beginWithClear:bgColor.r g:bgColor.g b:bgColor.b a:bgColor.a];
	
    // 3: Draw into the texture
    // We'll add this later
	CCSprite *noise = [CCSprite spriteWithSpriteFrameName:@"green.png"];
    [noise setBlendFunc:(ccBlendFunc){GL_DST_COLOR, GL_ZERO}];
	noise.position = ccp(textureSize/2, textureSize/2);
	[noise visit];
	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
	CGPoint vertices[4];
	ccColor4F colors[4];
	int nVertices = 0;
	
	vertices[nVertices] = CGPointMake(0, 0);
	colors[nVertices++] = (ccColor4F){0, 0, 0, 0 };
	vertices[nVertices] = CGPointMake(textureSize, 0);
	colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
	vertices[nVertices] = CGPointMake(0, textureSize);
	colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
	vertices[nVertices] = CGPointMake(textureSize, textureSize);
	colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glColorPointer(4, GL_FLOAT, 0, colors);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nVertices);
	
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	
	// 4: Call CCRenderTexture:end
	[rt end];
    
    
    // 5: Create a new Sprite from the texture
    return [CCSprite spriteWithTexture:rt.sprite.texture];
}


-(void) createBackground{
    [self unschedule:@selector(loadingTerrain)];
    
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    float hillHeight;
    for (int i = 0; i < 2; i++){
        CCSprite* hill = [CCSprite spriteWithSpriteFrameName:@"domb.png"];
        hill.position = ccp((i)*hill.contentSize.width + hill.contentSize.width/2 - i * 2 - 20, hill.contentSize.height/2);
        [self.hills addObject:hill];
        [hill.texture setAliasTexParameters];
        [self.batchnode addChild:hill z:50 tag:5];
        hillHeight = hill.contentSize.height/4;
    }
    
    float backHillHeight;
    for (int i = 0; i < 2; i ++){
        CCSprite* backHill = [CCSprite spriteWithSpriteFrameName:@"dombok.png"];
        backHill.position = ccp((i)*backHill.contentSize.width + backHill.contentSize.width/2 - 20 - 0.5 * i, hillHeight + backHill.contentSize.height/2 );
        [self.backHills addObject:backHill];
        [backHill.texture setAliasTexParameters];
        [self.batchnode addChild:backHill z:10+i tag:2];
        backHillHeight = backHill.position.y + backHill.contentSize.height/6;
    }
        
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];

    for (int i = 0; i < 2; i++){
        float rnd = CCRANDOM_0_1() * 2 + 1;
        CCSprite* tree = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"tree%i.png", i+1]];
        tree.position = ccp((i +1) * tree.contentSize.width + tree.contentSize.width/2, tree.contentSize.height/2 * tree.scale);
        [self.trees addObject:tree];
        [self.batchnode addChild:tree z:40 tag:4];
    }
    
    float backTreeWidth;
    for (int i = 3; i > 0; i--){
        float rnd = CCRANDOM_0_1() * 2 + 1;
        CCSprite* backTree = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"backTree%i.png",i]];
        backTree.position = ccp((4 - i) * backTree.contentSize.width + (3-i) * backTree.contentSize.width/2, backTree.contentSize.height/2 * backTree.scale  + hillHeight + 10);
        backTreeWidth = backTree.contentSize.width;
        [self.backTrees addObject:backTree];
        [self.batchnode addChild:backTree z:2 tag:1];
    }
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

    /*
    for (int i = 0; i < 3; i++){
        CCSprite* building = [CCSprite spriteWithSpriteFrameName:@"templom.png"];
        building.position = ccp(4 *backTreeWidth + building.contentSize.width/2,  building.contentSize.height/2);
        [self.batchnode addChild:building z:3 tag:3];
        [self.buildings addObject:building];
    }
    */
   
    /*
	for (int i= 0; i <1; i++){
        CCSprite* bgCloud = [CCSprite spriteWithSpriteFrameName:@"cloud.png"];
		bgCloud.opacity = 200;
		[_clouds addObject:bgCloud];
        
        bgCloud.position = ccp(bgCloud.contentSize.width, bgCloud.contentSize.height);
        [self.batchnode addChild:bgCloud z:1 tag:1];
        float rnd = CCRANDOM_0_1()* (1.0 - 0.6) + 0.6;
        bgCloud.scale = rnd;
	//	float rndOffset =  CCRANDOM_0_1() * (1000-400) + 400;
        float cloudSpeed = CCRANDOM_0_1() + 0.5;
        [self.cloudSpeeds addObject:[NSNumber numberWithFloat:cloudSpeed]];

        CGSize screenSize = [[CCDirector sharedDirector] winSize];
		bgCloud.position = ccp(screenSize.width + bgCloud.contentSize.width * i * bgCloud.scale, 
											 screenSize.height - bgCloud.contentSize.height * bgCloud.scale);
	}*/
    
    self.jumpSpeed = 3.5f;
    self.minFishDistance = 0;
    
    for (int i = 0; i < 1;i++){
        Fish* fish  = [[Fish alloc] initForCampaignNode:self.batchnode] ;
        [self moveFishToNewPosition:fish];
        [self.fish addObject:fish];
    }


}

-(void) updateBackground:(ccTime)dt{
    int backItemOn = 0;
    int forItemOn = 0;
    for (CCSprite* backTree in self.backTrees){
        backTree.position = ccpAdd(backTree.position, ccp(_forSpeed/12 * (dt*60), 0));
    //    backTree.position = ccpAdd(backTree.position, ccp(-0.25, 0));
    }
    for (CCSprite* hill in self.backHills){
        hill.position = ccpAdd(hill.position, ccp(_forSpeed/7 , 0));
    }
    
    
    for (CCSprite* tree in self.trees){
        tree.position = ccpAdd(tree.position, ccp(_forSpeed / 3.5  * (dt*60), 0));
//        tree.position = ccpAdd(tree.position, ccp(_forSpeed / 2.5, 0));
        if (tree.position.x + tree.contentSize.width/2 >= 0){
        }
    }
    
    for (CCSprite* hill in self.hills){
        hill.position = ccpAdd(hill.position, ccp(2* _forSpeed  * (dt*60), 0));
   //     hill.position = ccpAdd(hill.position, ccp(2* _forSpeed, 0));
    }
    
    for (Fish* fish in self.fish){
        fish.sprite.position = ccpAdd(fish.sprite.position, ccp(_forSpeed, 0));
    }
}


-(void) respawnContinuosBackGround{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    for (CCSprite* backHill in self.backHills){
        if (backHill.position.x + backHill.contentSize.width/2 <= 0){
            backHill.position = ccpAdd(backHill.position, ccp(backHill.contentSize.width * 2 - [self.backHills count] * 0.5,0));
        }
    }
    
    for (int i = 0; i < [self.hills count]; i++){
        CCSprite* hill =  [self.hills objectAtIndex:i];
        if (hill.position.x + hill.contentSize.width/2 <= 0){
            hill.position = ccpAdd(hill.position, ccp(hill.contentSize.width * 2 - [self.hills count] * 2, 0));
        }
    }
    
    for (int i = 0; i < [self.clouds count]; i++){
        CCSprite* cloud = [self.clouds objectAtIndex:i];
        if (cloud.position.x + cloud.contentSize.width/2 < 0){
            float rnd = CCRANDOM_0_1()  + 0.5;
            [self.cloudSpeeds replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:rnd]];
            float rndY = CCRANDOM_0_1() * (5-3) + 3;
            cloud.scale = CCRANDOM_0_1() * (1-0.4)+ 0.4;
            cloud.position = ccp(cloud.position.x + screenSize.width + cloud.contentSize.width * 2 * cloud.scale,  screenSize.height/5 * rndY);
        }
    }
    
    for (int i = 0; i < [self.trees count]; i++){
        CCSprite* tree = [self.trees objectAtIndex:i];
        if (tree.position.x + tree.contentSize.width/2 * tree.scale < 0){
            float rnd = CCRANDOM_0_1() * 1.3 + 2.2;
            tree.position = ccp(screenSize.width + tree.contentSize.width * tree.scale * rnd + tree.contentSize.width * rnd, tree.position.y);
        }
    }
         
    for (int i = 0; i < [self.backTrees count]; i++){
        CCSprite* tree = [self.backTrees objectAtIndex:i];
        if (tree.position.x + tree.contentSize.width/2 * tree.scale < 0){
            float rnd = CCRANDOM_0_1() * 1.3 + 2.2;
            tree.position = ccp(screenSize.width + tree.contentSize.width * tree.scale * rnd, tree.position.y);
        }
    }

}

-(void) respawnRandomItems{
    float rnd = CCRANDOM_0_1()* (4.0 - 1.0) + 1.0;
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    for (CCSprite* tree in self.trees){
        if (tree.position.x + tree.contentSize.width/2 * tree.scale < 0){
            tree.position = ccp(screenSize.width + tree.contentSize.width , tree.position.y );
        }
    }
    
    for (int i = 0; i < [self.backTrees count]; i++){
        CCSprite* backTree = [self.backTrees objectAtIndex:i];
        if (backTree.position.x + backTree.contentSize.width/2 * backTree.scale < 0){
            backTree.position = ccpAdd(backTree.position, ccp(screenSize.width * 1.5,0));
            for (int j = 0; j < [self.backTrees count]-1; j++) {
                CCSprite* backTreePrevious = [self.backTrees objectAtIndex:i];
                if (backTreePrevious.position.x - backTreePrevious.contentSize.width/2 * backTreePrevious.scale >  screenSize.width){
                    backTree.position = ccpAdd(backTree.position, ccp(backTreePrevious.contentSize.width, 0));
                }
            }
        }
    }
}

-(void) genBackground{
    CCSprite* backGround = [CCSprite spriteWithSpriteFrameName:@"green.png"];

    ccColor4F bgColor = ccc4FFromccc4B(ccc4(153, 0, 51, 255));
    //[self randomBrightColor];
	
    CGSize winSize = [CCDirector sharedDirector].winSize;
    _overLaySprite = [self spriteWithColor:bgColor textureSize:512 withNoise:@"green.png" withGradientAlpha:0.7f];
   // _overLaySprite = [CCSprite spriteWithSpriteFrameName:@"green.png"];
    ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
    [_overLaySprite.texture setTexParameters:&tp];
    
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    [self addChild:_overLaySprite z:-1 tag:-1];
    _overLaySprite.opacity = 0;
    backGround.position = ccp(screenSize.width/2, screenSize.height/2);
    [self addChild:backGround z:-2 tag:1];
    _overLaySprite.position = backGround.position;
}

-(void) fadeInOverlay{
    [_overLaySprite runAction:[CCFadeTo actionWithDuration:2 opacity:255]];
    NSLog(@"fadeinoverlay");
}


-(void) fadeOutOverlay{
    [_overLaySprite runAction:[CCFadeOut actionWithDuration:1]];
}

-(void) updateFish{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    for (Fish* fish in _fish){
        if (fish.sprite.position.x + fish.sprite.contentSize.width/2 * fish.sprite.scale < 0 && fish.isJumping == NO){
            //respawn the fish
            [self moveFishToNewPosition:fish];
        }else if (!fish.isJumping){
            if (fish.sprite.position.x - fish.sprite.contentSize.width/2 * fish.sprite.scale <= screenSize.width){
                [fish.sprite stopAllActions];
                [fish.sprite runAction:fish.animation];
                CCAction* jump = [CCJumpTo actionWithDuration:_jumpSpeed position:ccp(fish.sprite.position.x + _forSpeed * 60, fish.sprite.position.y) height:_maxFishJump jumps:1];
                CCAction* jumpDone = [CCCallFunc actionWithTarget:fish selector:@selector(jumpDone:)];
                [fish.sprite runAction:[CCSequence actions:jump, jumpDone, nil]];
                fish.isJumping = YES;
            }
        }
    }
}



-(void) moveFishToNewPosition:(Fish*) predator{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
    if (_minFishDistance == 0){
        _minFishDistance = 1000;
    }
    predator.sprite.position = ccp(screenSize.width + _minFishDistance, 0);	
    predator.isJumping = NO;
}


-(void)dealloc{
    self.trees = nil;
    self.backTrees = nil;
    self.hills = nil;
    self.backHills = nil;
    self.clouds = nil;
    [super dealloc];
}

@end
