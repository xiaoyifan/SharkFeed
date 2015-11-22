//
//  SFWebViewController.m
//  SharkFeed
//
//  Created by Yifan Xiao on 11/22/15.
//  Copyright © 2015 Yifan Xiao. All rights reserved.
//

#import "SFWebViewController.h"

@interface SFWebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *flickrWebView;

@end

@implementation SFWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *headerImage = [UIImage imageNamed:@"SharkFeedSmall"];
    UIImageView *headerImageView = [[UIImageView alloc] initWithImage: headerImage];
    self.navigationItem.titleView = headerImageView;
    
    if (self.record != nil) {
        NSString *request = [NSString stringWithFormat:@"https://flickr.com/photo.gne?id=%lld", self.record.photoID];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:request]];
        [self.flickrWebView loadRequest:requestObj];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
