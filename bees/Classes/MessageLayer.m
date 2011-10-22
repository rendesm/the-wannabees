//
//  MessageLayer.m
//  bees
//
//  Created by Mihaly Rendes on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageLayer.h"


@implementation MessageLayer
@synthesize messageBuffer;

+(id)scene{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MessageLayer *layer = [MessageLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) actionMessageFinished:(id)sender{
	[self removeChild:(CCLabelBMFont*)sender cleanup:YES];
    _messageInProgress = NO;
    if (_messageBuffer != nil){
        [self displayMessage:_messageBuffer];
        self.messageBuffer = nil;
    }
}

-(void) actionSpriteDone:(id)sender{
    [self removeChild:(CCSprite*)sender cleanup:YES];
}

-(void) displayMessage:(NSString*)message{
    if (_messageInProgress){
        if (_messageBuffer != nil) {
            self.messageBuffer = message;
        }else{
            //loose the message
        }
    }else{
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        CCLabelBMFont* renderedMessage = [[CCLabelBMFont alloc]initWithString:message fntFile:@"markerfelt.fnt"];
        renderedMessage.position = ccp(-screenSize.width/2, screenSize.height/4);
        CCSprite* textSprite = [CCSprite spriteWithFile:@"defaultText.png"];
        textSprite.position = renderedMessage.position;
        textSprite.opacity = 180;
        
        [self addChild:renderedMessage];
        CCAction *moveIn = [CCMoveTo actionWithDuration:0.2 position:ccp(textSprite.contentSize.width/2, screenSize.height/4 - 3)];
        CCAction *fadeOut = [CCFadeOut actionWithDuration:1];
        CCAction *messageDone = [CCCallFunc actionWithTarget:self selector:@selector(actionMessageFinished:)];
        renderedMessage.scale = 0.3;
        [renderedMessage runAction:[CCSequence actions:moveIn, fadeOut, messageDone,nil]];
        _messageInProgress = YES;
        
       
        CCAction *moveInSprite = [CCMoveTo actionWithDuration:0.2 position:ccp(textSprite.contentSize.width/2 - 5, screenSize.height/4)];
        CCAction *fadeOutSprite = [CCFadeOut actionWithDuration:1];
        CCAction *spriteDone = [CCCallFunc actionWithTarget:self selector:@selector(actionSpriteDone:)];
        [self addChild:textSprite z:-1 tag:1];
        [textSprite runAction:[CCSequence actions:moveInSprite,fadeOutSprite,spriteDone, nil]];
    }
}

-(void) displayWarning:(NSString*)message{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    CCLabelBMFont* renderedMessage = [[CCLabelBMFont alloc] initWithString:message fntFile:@"markerfelt.fnt"];
    renderedMessage.position = ccp(screenSize.width/2, screenSize.height * 0.75);
    renderedMessage.scale = 0;
    [self addChild:renderedMessage];
    CCAction* scaleIn = [CCScaleTo actionWithDuration:0.5 scale:0.7];
    CCAction *fadeOut = [CCFadeOut actionWithDuration:1];
    [renderedMessage runAction:[CCSequence actions:scaleIn, fadeOut, nil]];
}

@end
