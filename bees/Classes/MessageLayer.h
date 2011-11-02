//
//  MessageLayer.h
//  bees
//
//  Created by Mihaly Rendes on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MessageLayer : CCLayer {
    bool _messageInProgress;
    NSString* _messageBuffer;
    CCLabelBMFont* _currentMessage;
}

-(void) displayMessage:(NSString*)message;
-(void) displayWarning:(NSString*)message;
@property (nonatomic, retain) NSString* messageBuffer;
@property (nonatomic, retain) CCLabelBMFont* currentMessage;
@end
