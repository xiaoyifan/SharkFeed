//
//  SFMainCollectionViewController.m
//  SharkFeed
//
//  Created by Yifan Xiao on 11/20/15.
//  Copyright © 2015 Yifan Xiao. All rights reserved.
//

#import "SFMainCollectionViewController.h"
#import "Flickr.h"
#import "FlickrPhoto.h"

@interface SFMainCollectionViewController ()

@property(nonatomic, strong) NSMutableArray *searchResults;
@property(nonatomic, strong) Flickr *flickr;
@property(nonatomic, strong) UIRefreshControl *refreshControll;

@end

@implementation SFMainCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *headerImage = [UIImage imageNamed:@"SharkFeedSmall"];
    UIImageView *headerImageView = [[UIImageView alloc] initWithImage: headerImage];
    self.navigationItem.titleView = headerImageView;
    
    self.refreshControll = [[UIRefreshControl alloc] init];
    self.refreshControll.tintColor = [UIColor clearColor];
    self.refreshControll.backgroundColor = [UIColor clearColor];
    [self.collectionView addSubview:self.refreshControll];
    [self loadCustomRefreshControlContents];
    [self.refreshControll addTarget:self action:@selector(refreshFeeds) forControlEvents:UIControlEventValueChanged];
    
    self.searchResults = [@[] mutableCopy];
    self.flickr = [[Flickr alloc] init];

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:mainCollectionViewCellReuseIdentifier];
    
}

- (void)refreshFeeds{
    
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        // When done requesting/reloading/processing invoke endRefreshing, to close the control
        [self.refreshControll endRefreshing];
    });
    
}


- (void)loadCustomRefreshControlContents{
    
    NSArray *customViews = [[NSBundle mainBundle] loadNibNamed:@"SharkFeedRefreshControl" owner:self options:nil];
    UIView *customNibView = [customViews objectAtIndex:0];
    
    CGRect frame = CGRectMake(self.refreshControll.bounds.origin.x, self.refreshControll.bounds.origin.y, self.refreshControll.bounds.size.width, 100);
    
    customNibView.frame = frame;
    //customNibView.clipsToBounds = YES;
    
    [self.refreshControll addSubview:customNibView];
}

- (void)viewWillAppear:(BOOL)animated{

[self.flickr searchFlickrWithcompletionBlock:^(NSArray *results, NSError *error) {
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            [self.searchResults addObjectsFromArray:results];
            [self.collectionView reloadData];
        });
}];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return [self.searchResults count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:mainCollectionViewCellReuseIdentifier forIndexPath:indexPath];

    cell.backgroundColor = [UIColor blackColor];

    return cell;
}

#pragma mark – UICollectionViewDelegateFlowLayout

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    FlickrPhoto *photo =
    self.searchResults[indexPath.row];
    // 2
    CGSize retval = photo.thumbnail.size.width > 0 ? photo.thumbnail.size : CGSizeMake(50, 50);
    retval.height += 25; retval.width += 25; return retval;
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

@end
