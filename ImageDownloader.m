//
//  ImageDownloader.m
//  SharkFeed
//
//  Created by Yifan Xiao on 11/21/15.
//  Copyright © 2015 Yifan Xiao. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader ()

@property (nonatomic, strong) NSURLSessionDataTask *sessionTask;

@end

@implementation ImageDownloader

-(void) startDownload:(int)type{
    
    NSURLRequest *request = nil;
    
    if (type == FlickrThumbnailImage) {
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.record.thumbnailURL]];
    }
    else if(type == FlickrLargeImage){
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.record.largeURL]];
    }

    
    // create an session data task to obtain and download the app icon
    self.sessionTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           
                                                           if (error != nil)
                                                           {
                                                               if ([error code] == NSURLErrorAppTransportSecurityRequiresSecureConnection)
                                                               {
                                                                   abort();
                                                               }
                                                           }
                                                           
                                                           [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                                                               UIImage *image = [[UIImage alloc] initWithData:data];
    
                                                                if(type == FlickrThumbnailImage)
                                                                {
                                                                    
                                                                   if (image.size.width != 100 || image.size.height != 100)
                                                                   {
                                                                       CGSize itemSize = CGSizeMake(100, 100);
                                                                       UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
                                                                       CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                                                                       [image drawInRect:imageRect];
                                                                       self.record.thumbnail = UIGraphicsGetImageFromCurrentImageContext();
                                                                       UIGraphicsEndImageContext();
                                                                   }
                                                                   else
                                                                   {
                                                                       self.record.thumbnail = image;
                                                                   }
                                                                }
                                                                else{
                                                                    self.record.largeImage = image;
                                                                }
                                                               
                                                               // call our completion handler to tell our client that our icon is ready for display
                                                               if (self.completionHandler != nil)
                                                               {
                                                                   self.completionHandler();
                                                               }
                                                           }];
                                                           
                                                       } ];
    
    [self.sessionTask resume];
    
}

- (void)cancelDownload
{
    [self.sessionTask cancel];
    _sessionTask = nil;
}

@end
