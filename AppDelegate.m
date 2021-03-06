//
//  AppDelegate.m
//  SharkFeed
//
//  Created by Yifan Xiao on 11/20/15.
//  Copyright © 2015 Yifan Xiao. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"header"] forBarMetrics:UIBarMetricsDefault];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.splashScreenController = [storyboard instantiateViewControllerWithIdentifier:@"splashScreen"];
    [self.window addSubview:self.splashScreenController.view];
    [self.window makeKeyAndVisible];
    [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(onSlashScreenDone) userInfo:nil repeats:NO];
    
    return YES;
}

-(void)onSlashScreenDone{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [self.splashScreenController.view removeFromSuperview];
    self.flickrViewController = [storyboard instantiateViewControllerWithIdentifier:photoViewControllerReuseIdentidier];
    [self.window addSubview:self.flickrViewController.view];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = self.flickrViewController;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
