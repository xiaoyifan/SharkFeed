//
//  FlickrPhoto.h
//  Flickr Search
//
//  Created by Brandon Trebitowski on 6/28/12.
//  Copyright (c) 2012 Brandon Trebitowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    ThumbnailImage = 0,
    MediumSizeImage,
    LargeSizeImage,
    OriginalSizeImage
} ImageSize;

@interface FlickrPhoto : NSObject

// Lookup info
@property(nonatomic) long long photoID;
@property(nonatomic) NSInteger farm;
@property(nonatomic) NSInteger server;
@property(nonatomic,strong) NSString *secret;

@property(nonatomic, strong) NSString *thumbnailURL;
@property(nonatomic, strong) NSString *mediumURL;
@property(nonatomic, strong) NSString *largeURL;
@property(nonatomic, strong) NSString *originalURL;

@property(nonatomic, strong) NSString *photoDescription;

@property (nonatomic, strong) NSString * author;
@property (nonatomic, strong) NSString * title;

@property (nonatomic, strong) NSCache *imageCache;

@end
