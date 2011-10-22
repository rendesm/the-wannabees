//
//  beesAppDelegate.h
//  bees
//
//  Created by macbook white on 7/18/11.
//  Copyright nincs 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface beesAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RootViewController* viewController;

@end
