//
//  Flickr.h
//  Flickr Search
//
//  Created by Brandon Trebitowski on 6/28/12.
//  Copyright (c) 2012 Brandon Trebitowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "FlickrUser.h"

@class FlickrPhoto;

typedef void (^FlickrSearchCompletionBlock)(NSArray *results, NSError *error);
typedef void (^FlickrUserCompletionBlock)(FlickrUser *user, NSError *error);
typedef void (^FlickrImageCompletionBlock)(UIImage *image, NSError *error);

@interface Flickr : NSObject

@property(strong) NSString *apiKey;
@property (nonatomic, assign) NSInteger pageNum;

- (void)searchFlickrInPage:(int)page WithcompletionBlock:(FlickrSearchCompletionBlock) completionBlock;
- (void)searchFlickrUserWithPhoto:(long long)photoID WithcompletionBlock:(FlickrUserCompletionBlock)completionBlock;
- (void)getSelfieImageForUser:(FlickrUser *)user WithcompletionBlock:(FlickrImageCompletionBlock)completionBlock;

@end
