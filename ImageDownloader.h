//
//  ImageDownloader.h
//  SharkFeed
//
//  Created by Yifan Xiao on 11/21/15.
//  Copyright © 2015 Yifan Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrPhoto.h"

@interface ImageDownloader : NSObject

@property (nonatomic, strong) FlickrPhoto * record;
@property (nonatomic, copy) void (^completionHandler)(void);

- (void)startDownload:(int)type;
- (void)cancelDownload;

@end
