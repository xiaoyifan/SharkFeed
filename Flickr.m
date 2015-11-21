//
//  Flickr.m
//  Flickr Search
//
//  Created by Brandon Trebitowski on 6/28/12.
//  Copyright (c) 2012 Brandon Trebitowski. All rights reserved.
//

#import "Flickr.h"
#import "FlickrPhoto.h"

@implementation Flickr

+ (NSString *)flickrSearchURL
{
    return [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=shark&format=json&nojsoncallback=1&page=1&extras=url_t,url_c,url_l,url_o", apiKey];
}

+ (NSString *)flickrPhotoURLForFlickrPhoto:(FlickrPhoto *) flickrPhoto size:(NSString *) size
{
    if(!size)
    {
        size = @"m";
    }
    return [NSString stringWithFormat:@"http://farm%ld.staticflickr.com/%ld/%lld_%@_%@.jpg",(long)flickrPhoto.farm,(long)flickrPhoto.server,flickrPhoto.photoID,flickrPhoto.secret,size];
}

- (void)searchFlickrWithcompletionBlock:(FlickrSearchCompletionBlock) completionBlock
{
    NSString *searchURL = [Flickr flickrSearchURL];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Create NSUrlSession
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Create data download task
    [[session dataTaskWithURL:[NSURL URLWithString:searchURL]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                
                //NSLog(@"Response:%@", response);
                
                NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                
                if (httpResp.statusCode == 200) {
                    NSError *jsonError;
                    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                               options:NSJSONReadingAllowFragments
                                                                                 error:&jsonError];
                    
                    
                    completionBlock(dictionary[@"photos"][@"photo"], nil);
                    
                    
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                }
                else{
                    
                    NSLog(@"Fail not 200");
                    
                    dispatch_async(dispatch_get_main_queue(), ^{

                            //handle the situation if the network connection is failed.
                            UIAlertView *failure = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"network is not available right now, check it out later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            
                            [failure show];
                        
                    });
                }
                
            }] resume];
    
    
    
    
    
    
    
    
    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    
//    dispatch_async(queue, ^{
//        NSError *error = nil;
//        NSString *searchResultString = [NSString stringWithContentsOfURL:[NSURL URLWithString:searchURL]
//                                                           encoding:NSUTF8StringEncoding
//                                                              error:&error];
//        if (error != nil) {
//            completionBlock(nil,error);
//        }
//        else
//        {
//            // Parse the JSON Response
//            NSData *jsonData = [searchResultString dataUsingEncoding:NSUTF8StringEncoding];
//            NSDictionary *searchResultsDict = [NSJSONSerialization JSONObjectWithData:jsonData
//                                                                              options:kNilOptions
//                                                                                error:&error];
//            if(error != nil)
//            {
//                completionBlock(nil,error);
//            }
//            else
//            {
//                NSString * status = searchResultsDict[@"stat"];
//                if ([status isEqualToString:@"fail"]) {
//                    NSError * error = [[NSError alloc] initWithDomain:@"FlickrSearch" code:0 userInfo:@{NSLocalizedFailureReasonErrorKey: searchResultsDict[@"message"]}];
//                    completionBlock(nil, error);
//                } else {
//                
//                    NSArray *objPhotos = searchResultsDict[@"photos"][@"photo"];
//                    NSMutableArray *flickrPhotos = [@[] mutableCopy];
//                    for(NSMutableDictionary *objPhoto in objPhotos)
//                    {
//                        FlickrPhoto *photo = [[FlickrPhoto alloc] init];
//                        photo.farm = [objPhoto[@"farm"] intValue];
//                        photo.server = [objPhoto[@"server"] intValue];
//                        photo.secret = objPhoto[@"secret"];
//                        photo.photoID = [objPhoto[@"id"] longLongValue];
//                        
//                        NSString *searchURL = [Flickr flickrPhotoURLForFlickrPhoto:photo size:@"m"];
//                        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:searchURL]
//                                                                  options:0
//                                                                    error:&error];
//                        UIImage *image = [UIImage imageWithData:imageData];
//                        photo.thumbnail = image;
//                        
//                        [flickrPhotos addObject:photo];
//                    }
//                    
//                    completionBlock(flickrPhotos,nil);
//                }
//            }
//        }
//    });
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
