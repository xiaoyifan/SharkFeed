//
//  Flickr.m
//  Flickr Search
//
//  Created by Brandon Trebitowski on 6/28/12.
//  Copyright (c) 2012 Brandon Trebitowski. All rights reserved.
//

#import "Flickr.h"

@interface Flickr ()

@end
@implementation Flickr

+ (NSString *)flickrSearchURLForPage:(int)page
{
    return [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=shark&format=json&nojsoncallback=1&page=%d&extras=url_t,url_c,url_l,url_o", apiKey,page];
}

+(NSString *)flickrPhotoDetailURLForPhoto:(long long)photoID{
    
    return [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=%@&photo_id=%lld&format=json&nojsoncallback=1", apiKey, photoID];
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
                            NSMutableArray *flickrPhotos = [NSMutableArray new];
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
                                photo.author = objPhoto[@"owner"];
                                photo.title = objPhoto[@"title"];
                                photo.imageCache = [NSCache new];
                                
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

- (void)searchFlickrUserWithPhoto:(long long)photoID WithcompletionBlock:(FlickrUserCompletionBlock)completionBlock{
  
    NSString *searchURL = [Flickr flickrPhotoDetailURLForPhoto:photoID];

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
                        
                        NSString * status = dictionary[@"stat"];
                        if ([status isEqualToString:@"fail"]) {
                            NSError * error = [[NSError alloc] initWithDomain:@"FlickrSearch" code:0 userInfo:@{NSLocalizedFailureReasonErrorKey: dictionary[@"message"]}];
                            completionBlock(nil, error);
                        } else {
                            
                            NSMutableDictionary *userDict = dictionary[@"photo"][@"owner"];

                            FlickrUser *user = [FlickrUser new];
                            user.user_id = userDict[@"nsid"];
                            user.username = userDict[@"username"];
                            user.realname = userDict[@"realname"];
                            user.location = userDict[@"location"];
                            user.iconServer = [userDict[@"iconserver"] intValue];
                            user.iconFarm = [userDict[@"iconfarm"] intValue];
                            
                            completionBlock(user,nil);
                        }
                    }
                    
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                }
                else{
                    
                    completionBlock(nil, error);
                    
                }
                
            }] resume];
    
}

- (void)getSelfieImageForUser:(FlickrUser *)user WithcompletionBlock:(FlickrImageCompletionBlock)completionBlock{
    
    //URL format: http://farm{icon-farm}.staticflickr.com/{icon-server}/buddyicons/{nsid}.jpg
    
    NSString *searchURL = [NSString stringWithFormat:@"https://farm%ld.staticflickr.com/%ld/buddyicons/%@.jpg", (long)user.iconFarm, (long)user.iconServer, user.user_id];
    
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
                    
                    UIImage *image = [UIImage imageWithData:data];
                    completionBlock(image,nil);
                    
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                }
                else{
                    
                    completionBlock(nil, error);
                    
                }
                
            }] resume];  
    
}

@end
