//
//  AppDelegate.m
//  Galarie
//
//  Created by Pratik on 10-02-14.
//  Copyright (c) 2014 Appacitive. All rights reserved.
//

#import "AppDelegate.h"
#import <Appacitive/AppacitiveSDK.h>

@implementation AppDelegate

@synthesize navController, mainViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Appacitive registerAPIKey:@"YOUR_API_KEY_HERE" useLiveEnvironment:NO];
    [[APLogger sharedLogger] enableLogging:YES];
    [[APLogger sharedLogger] enableVerboseMode:YES];
    
    self.mainViewController = [[AlbumListViewController alloc]init];
    
    navController = (UINavigationController *)self.window.rootViewController;
    
    mainViewController = (AlbumListViewController *)[navController topViewController];
    
    [self.window makeKeyAndVisible];
    
    [mainViewController performSegueWithIdentifier:@"showLoginView" sender:self];
    
    return YES;
}

@end
