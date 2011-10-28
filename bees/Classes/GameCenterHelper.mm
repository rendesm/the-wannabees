//
//  GameCenterHelper.m
//  bees
//
//  Created by macbook white on 8/25/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "GameCenterHelper.h"
#import "beesAppDelegate.h"

@implementation GameCenterHelper
@synthesize gameCenterAvailable = _gameCenterAvailable;
@synthesize GCViewController = _GCViewController;
@synthesize unsentScores = _unsentScores;

#pragma mark Initialization

static GameCenterHelper *sharedHelper = nil;
+ (GameCenterHelper *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[GameCenterHelper alloc] init];
    }
    return sharedHelper;
}

- (BOOL)isGameCenterAvailable {
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer 
										   options:NSNumericSearch] != NSOrderedAscending);
	
    return (gcClass && osVersionSupported);
}

- (id)init {
    if ((self = [super init])) {
        _gameCenterAvailable = [self isGameCenterAvailable];
        if (_gameCenterAvailable) {
            self.GCViewController = [[UIViewController alloc] init];
            NSNotificationCenter *nc = 
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self 
                   selector:@selector(authenticationChanged) 
                       name:GKPlayerAuthenticationDidChangeNotificationName 
                     object:nil];
        }
		//self.unsentScores = [[NSMutableArray alloc]init];
		
    }
    return self;
}

- (void)authenticationChanged {    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !_userAuthenticated) {
		NSLog(@"Authentication changed: player authenticated.");
		_userAuthenticated = TRUE;      
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && _userAuthenticated) {
		NSLog(@"Authentication changed: player not authenticated");
		_userAuthenticated = FALSE;
    }
}

#pragma mark User functions

- (void)authenticateLocalUser { 
	
    if (!_gameCenterAvailable) return;
	
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {     
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];        
    } else {
        NSLog(@"Already authenticated!");
    }
}



- (void)reportScore:(int64_t)score forCategory:(NSString *)category
{
	// Only execute if OS supports Game Center & player is logged in
	if (_gameCenterAvailable)
	{
		// Create score object
		GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];
		// Set the score value
		scoreReporter.value = score;
		
		// Try to send
		[scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
			if (error != nil)
			{
				// Handle reporting error here by adding object to a serializable array, to be sent again later
				[self.unsentScores addObject:scoreReporter];
			}
		}];
	}
}

- (void)sendScore:(GKScore *)score {
    if (score == nil){
        NSLog(@"nil score");
    }

    [score reportScoreWithCompletionHandler:^(NSError *error)
    //{ dispatch_async(dispatch_get_main_queue(), ^(void) 
        { if (error == NULL) { 
            NSLog(@"Successfully sent score!");
            _score = 0;
        }else { 
            [self.unsentScores addObject:score ];
            NSLog(@"Score failed to send... will try again later. Reason: %@", error.localizedDescription);
        } 
        }
                   //  ); 
    //}
     ]; 
}

- (void)reportScore:(NSString *)identifier score:(int)rawScore{

    GKScore *score = [[[GKScore alloc] initWithCategory:@"21"] autorelease];
    score.value = rawScore;

    _score = rawScore;
   // [self save]; 
    if (!_gameCenterAvailable || !_userAuthenticated) return; 
    [self sendScore:score];
}



- (void)showLeaderboardForCategory:(NSString *)category{
    
    beesAppDelegate *delegate = [UIApplication sharedApplication].delegate; 
    
	if (_gameCenterAvailable){
		GKLeaderboardViewController *gkLeaderBoardController = [[GKLeaderboardViewController alloc]init];
		if (gkLeaderBoardController != nil){
			gkLeaderBoardController.leaderboardDelegate = self;
			gkLeaderBoardController.category = @"PointsHills";
			gkLeaderBoardController.timeScope = GKLeaderboardTimeScopeAllTime;   
            [delegate.window.rootViewController presentModalViewController:gkLeaderBoardController animated:YES];
		}
	}
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController{
	[self.GCViewController dismissModalViewControllerAnimated:YES];
	[self.GCViewController release];
}

@end
