//
//  ImageDownloader.m
//  SharkFeed
//
//  Created by Yifan Xiao on 11/21/15.
//  Copyright © 2015 Yifan Xiao. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader ()

//@property (nonatomic, strong) NSURLSessionDataTask *sessionTask;
@property (nonatomic, strong) NSOperationQueue* operationQueue;
@property (nonatomic, strong) NSMutableDictionary* operations;

@end


@implementation ImageDownloader

-(NSOperationQueue *)operationQueue{
    if (!_operationQueue) {
        _operationQueue = [NSOperationQueue new];
    }
    return _operationQueue;
}

-(NSMutableDictionary *)operations{
    if (!_operations) {
        _operations = [NSMutableDictionary new];
    }
    return _operations;
}

-(void) startDownload:(ImageSize)type{
    
    if (type>ThumbnailImage && type<=OriginalSizeImage) {
        [self startDownload:type-1];
    }
    
    NSString *urlString = nil;
    
    switch (type) {
        case OriginalSizeImage:
            urlString = self.record.originalURL;
            break;
        case LargeSizeImage:
            urlString = self.record.largeURL;
            break;
        case MediumSizeImage:
            urlString = self.record.mediumURL;
            break;
        case ThumbnailImage:
            urlString = self.record.thumbnailURL;
            break;
        default:
            break;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSBlockOperation* operation = [[NSBlockOperation alloc] init];
    
    UIImage* image = [self imageOfSize:type];
    if (image){
        dispatch_async(dispatch_get_main_queue(), ^{

            self.completionHandler();

        });
        return;
    }
    
    __weak typeof (operation) operation_ = operation;
    [operation addExecutionBlock:^{
         __strong typeof (operation) operationStrong = operation_;
        
        if (operationStrong.isCancelled) return;
        
        // create an session data task to obtain and download the app icon
         [[[NSURLSession sharedSession] dataTaskWithRequest:request
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
                                   
                                   
                                   switch (type) {
                                       case ThumbnailImage:
                                       {
                                           if (image.size.width != 100 || image.size.height != 100)
                                           {
                                               CGSize itemSize = CGSizeMake(100, 100);
                                               UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
                                               CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                                               [image drawInRect:imageRect];
                                               UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                                               [self.record.imageCache setObject:image forKey:self.record.thumbnailURL];
                                               UIGraphicsEndImageContext();
                                           }
                                           else
                                           {
                                               [self.record.imageCache setObject:image forKey:self.record.thumbnailURL];
                                           }
                                           
                                       }
                                           break;
                                        case MediumSizeImage:
                                           [self.record.imageCache setObject:image forKey:self.record.mediumURL];
                                           break;
                                        case LargeSizeImage:
                                           [self.record.imageCache setObject:image forKey:self.record.largeURL];
                                           break;
                                        case OriginalSizeImage:
                                           [self.record.imageCache setObject:image forKey:self.record.originalURL];
                                           break;
                                       default:
                                           break;
                                   }
                                   
                                   [self cancelOperationsOfSize:type];
                                   // call our completion handler to tell our client that our icon is ready for display
                                   if (self.completionHandler != nil)
                                   {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           if (!operationStrong.isCancelled)  {
                                               self.completionHandler();
                                           }
                                       });
                                   }
                                   
                               }];
                               
                           } ] resume];
    
  
    }];
    
        //add operation to operations dictionary (so that we can cancel)
        [self.operations setObject:operation forKey:@(type)];
    
        //add operation to operation queue for execution
        [self.operationQueue addOperation:operation];
        
}

- (void)cancelOperationsOfSize:(ImageSize)size {
    if (![self.operations objectForKey:@(size)]) return;
    for (int idx=0; idx<=size; idx++) {
        
        NSOperation* operation = [self.operations objectForKey:@(idx)];
        [operation cancel];
        
        [self.operations removeObjectForKey:@(idx)];
    }
}

- (UIImage*)imageOfSize:(ImageSize)size
{
    NSString *imageURL = nil;
    switch (size) {
        case ThumbnailImage:
            imageURL = self.record.thumbnailURL;
            break;
        case MediumSizeImage:
            imageURL = self.record.mediumURL;
            break;
        case LargeSizeImage:
            imageURL = self.record.largeURL;
            break;
        case OriginalSizeImage:
            imageURL = self.record.originalURL;
            break;
        default:
            break;
    }
    
    return [self.record.imageCache objectForKey:imageURL];
}

@end
