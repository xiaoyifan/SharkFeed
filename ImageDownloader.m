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
    
    if (type>ThumbnailImage && type<=OriginalSize) {
        [self startDownload:type-1];
    }
    
    NSURLRequest *request = nil;
    if (type == OriginalSize) {
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.record.originalURL]];
    }
    if (type == ThumbnailImage) {
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.record.thumbnailURL]];
    }
    else if(type == MediumImage){
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.record.mediumURL]];
    }
    else if(type == LargeImage){
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.record.largeURL]];
    }
    else if(type == OriginalSize){
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.record.originalURL]];
    }
    
    
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
                                                                   
                                                                   if(type == ThumbnailImage)
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
                                                                   else if(type == MediumImage){
                                                                       self.record.mediumImage = image;
                                                                   }
                                                                   else if(type == LargeImage){
                                                                       self.record.largeImage = image;
                                                                   }
                                                                   else if(type == OriginalSize){
                                                                       self.record.originalImage = image;
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
    switch (size) {
        case ThumbnailImage:
            return self.record.thumbnail;
            break;
        case MediumImage:
            return self.record.mediumImage;
            break;
        case LargeImage:
            return self.record.largeImage;
            break;
        case OriginalSize:
            return self.record.originalImage;
            break;
        default:
            break;
    }
}

@end
