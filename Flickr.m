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
                                photo.mediumURL = objPhoto[@"url_c"];
                                photo.largeURL = objPhoto[@"url_l"];
                                photo.originalURL = objPhoto[@"url_o"];
                                
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

@end
