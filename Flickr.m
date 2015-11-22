//
//  Flickr.m
//  Flickr Search
//
//  Created by Brandon Trebitowski on 6/28/12.
//  Copyright (c) 2012 Brandon Trebitowski. All rights reserved.
//

#import "Flickr.h"
#import "FlickrPhoto.h"

@interface Flickr ()

@property (nonatomic, strong) NSOperationQueue *queue;

@end
@implementation Flickr

+ (NSString *)flickrSearchURLForPage:(int)page
{
    return [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=shark&format=json&nojsoncallback=1&page=%d&extras=url_t,url_c,url_l,url_o", apiKey,page];
}

+ (NSString *)flickrPhotoURLForFlickrPhoto:(FlickrPhoto *) flickrPhoto size:(NSString *) size
{
    if(!size)
    {
        size = @"m";
    }
    return [NSString stringWithFormat:@"http://farm%ld.staticflickr.com/%ld/%lld_%@_%@.jpg",(long)flickrPhoto.farm,(long)flickrPhoto.server,flickrPhoto.photoID,flickrPhoto.secret,size];
}

- (void)searchFlickrInPage:(int)page WithcompletionBlock:(FlickrSearchCompletionBlock) completionBlock
{
    NSString *searchURL = [Flickr flickrSearchURLForPage:page];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Create NSUrlSession
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Create data download task
    [[session dataTaskWithURL:[NSURL URLWithString:searchURL]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                
                NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                
                if (httpResp.statusCode == 200) {
                    self.queue = [NSOperationQueue new];
                    NSError *jsonError;
                    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                               options:NSJSONReadingAllowFragments
                                                                                 error:&jsonError];
                    
                    if(jsonError != nil)
                    {
                        completionBlock(nil,error);
                    }
                    else
                    {
                        self.pageNum = [[dictionary valueForKeyPath:@"photos.pages"] integerValue];
                        
                        NSString * status = dictionary[@"stat"];
                        if ([status isEqualToString:@"fail"]) {
                            NSError * error = [[NSError alloc] initWithDomain:@"FlickrSearch" code:0 userInfo:@{NSLocalizedFailureReasonErrorKey: dictionary[@"message"]}];
                            completionBlock(nil, error);
                        } else {
                            
                            NSArray *objPhotos = dictionary[@"photos"][@"photo"];
                            NSMutableArray *flickrPhotos = [@[] mutableCopy];
                            for(NSMutableDictionary *objPhoto in objPhotos)
                            {
                                FlickrPhoto *photo = [[FlickrPhoto alloc] init];
                                photo.farm = [objPhoto[@"farm"] intValue];
                                photo.server = [objPhoto[@"server"] intValue];
                                photo.secret = objPhoto[@"secret"];
                                photo.photoID = [objPhoto[@"id"] longLongValue];
                                photo.thumbnailURL = objPhoto[@"url_t"];
                                photo.largeURL = objPhoto[@"url_l"];
                                photo.title = objPhoto[@"title"];
                                
                                [flickrPhotos addObject:photo];
                            }
                            
                            completionBlock(flickrPhotos,nil);
                        }
                    }
                    
                    
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                }
                else{
                    
                    completionBlock(nil, error);
                    
                }
                
            }] resume];

}

+ (void)loadImageForPhoto:(FlickrPhoto *)flickrPhoto thumbnail:(BOOL)thumbnail completionBlock:(FlickrPhotoCompletionBlock) completionBlock
{
    
    NSString *size = thumbnail ? @"m" : @"b";
    
    NSString *searchURL = [Flickr flickrPhotoURLForFlickrPhoto:flickrPhoto size:size];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSError *error = nil;
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:searchURL]
                                                  options:0
                                                    error:&error];
        if(error)
        {
            completionBlock(nil,error);
        }
        else
        {
            UIImage *image = [UIImage imageWithData:imageData];
            if([size isEqualToString:@"m"])
            {
                flickrPhoto.thumbnail = image;
            }
            else
            {
                flickrPhoto.largeImage = image;
            }
            completionBlock(image,nil);
        }
        
    });
}



@end
