//
//  GameCenterHelper.m
//  bees
//
//  Created by macbook white on 8/25/11.
//  Copyright 2011 nincs. All rights reserved.
//

#import "GameCenterHelper.h"


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
	//	[self showLeaderboardForCategory:@"com.mihalyrendes.thewannabees.21"];
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


- (void)showLeaderboardForCategory:(NSString *)category{
	if (_gameCenterAvailable){
		GKLeaderboardViewController *gkLeaderBoardController = [[GKLeaderboardViewController alloc]init];
		if (gkLeaderBoardController != nil){
			gkLeaderBoardController.leaderboardDelegate = self;
			gkLeaderBoardController.category = category;
			gkLeaderBoardController.timeScope = GKLeaderboardTimeScopeAllTime;   
			self.GCViewController  = [[UIViewController alloc] init];
			[[[CCDirector sharedDirector] openGLView] addSubview:self.GCViewController.view];
			[self.GCViewController presentModalViewController:gkLeaderBoardController animated:YES];
		}
	}
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController{
	[self.GCViewController dismissModalViewControllerAnimated:YES];
	[self.GCViewController release];
}

@end
