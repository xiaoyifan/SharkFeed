//
//  SFImageDetailViewController.m
//  SharkFeed
//
//  Created by Yifan Xiao on 11/21/15.
//  Copyright © 2015 Yifan Xiao. All rights reserved.
//

#import "SFImageDetailViewController.h"
#import "ImageDownloader.h"

@interface SFImageDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *detailImageView;
@property (strong, nonatomic) ImageDownloader *downloader;

@end

@implementation SFImageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.downloader =  [[ImageDownloader alloc] init];
    self.downloader.record = self.record;
    __weak FlickrPhoto *weakRecord = self.record;
    __weak SFImageDetailViewController *weakSelf = self;
    self.downloader.completionHandler = ^{
        if (weakRecord.originalImage) {
            weakSelf.detailImageView.image = weakRecord.originalImage;
        }
        else if (weakRecord.largeImage) {
            weakSelf.detailImageView.image = weakRecord.largeImage;
        }
        else if(weakRecord.mediumImage){
            weakSelf.detailImageView.image = weakRecord.mediumImage;
        }
        else if(weakRecord.thumbnail){
            weakSelf.detailImageView.image = weakRecord.thumbnail;
        }
        
    };
    [self.downloader startDownload:LargeImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissDetailViewController:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)downloadImageToAlbum:(id)sender {
    
    if (self.detailImageView.image!= nil) {
        UIImageWriteToSavedPhotosAlbum(self.detailImageView.image,
                                       self, // send the message to 'self' when calling the callback
                                       @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), // the selector to tell the method to call on completion
                                       NULL);
    }
}

//reference: http://stackoverflow.com/questions/7628048/ios-uiimagewritetosavedphotosalbum
- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    if (error) {
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Something wrong"
                                      message:@""
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"Gotcha"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        
    } else {
        
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Image Saved!"
                                      message:@""
                                      preferredStyle:
                                      UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

- (IBAction)openInFlickrApp:(id)sender {
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
