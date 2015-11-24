//
//  AppDelegate.h
//  SharkFeed
//
//  Created by Yifan Xiao on 11/20/15.
//  Copyright © 2015 Yifan Xiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFMainCollectionViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) UIViewController *splashScreenController;
@property (nonatomic, retain) SFMainCollectionViewController * flickrViewController;

@end

