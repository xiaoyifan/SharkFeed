//
//  FlickrUser.h
//  SharkFeed
//
//  Created by Yifan Xiao on 11/22/15.
//  Copyright © 2015 Yifan Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrUser : NSObject

@property(nonatomic, strong) NSString *user_id;
@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSString *realname;
@property(nonatomic) NSInteger iconServer;
@property(nonatomic) NSInteger iconFarm;
@property(nonatomic, strong) NSString *location;
@end
