//
//  GameCenterHelper.h
//  bees
//
//  Created by macbook white on 8/25/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "cocos2d.h"

@interface GameCenterHelper : NSObject <GKLeaderboardViewControllerDelegate> {
	BOOL _gameCenterAvailable;
    BOOL _userAuthenticated;
	NSMutableArray* _unsentScores;
	UIViewController* _GCViewController;
    int _score;
}

@property (assign, readonly) BOOL gameCenterAvailable;
@property (nonatomic, retain) UIViewController* GCViewController;
@property (nonatomic, retain) NSMutableArray* unsentScores;

+ (GameCenterHelper *)sharedInstance;
- (void)authenticateLocalUser;
- (void)reportScore:(NSString *)identifier score:(int)rawScore;

- (void) reportScore: (int64_t) score forCategory: (NSString*) category;
- (void) reloadHighScoresForCategory: (NSString*) category;
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController;
- (void) showLeaderboardForCategory:(NSString *)category;

@end