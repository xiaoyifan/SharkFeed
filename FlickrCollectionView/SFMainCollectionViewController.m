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
#import "FlickrCollectionViewCell.h"
#import "ImageDownloader.h"

@interface SFMainCollectionViewController ()

@property(nonatomic, strong) NSMutableArray *searchResults;
@property(nonatomic, strong) Flickr *flickr;

@property(nonatomic, strong) UIRefreshControl *refreshControll;
@property(nonatomic) BOOL refreshAnimating;
//Flag to test if the refresh controll is on.

@property(nonatomic, assign) NSInteger page;

@property(nonatomic, strong) NSMutableDictionary *downloadingTask;

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
    
    self.downloadingTask = [NSMutableDictionary new];
    
    self.page = 1;
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    if (self.searchResults != nil && self.searchResults.count != 0) {
        [self.collectionView reloadData];
    } else {
        self.page = 1;
        [self searchFlickrInPage:(int)self.page];
    }
    //if the results array contains data, load them in the collectionView
    //if the array is empty, fetch the first page
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)refreshFeeds{
    
    self.page = 1;
    [self searchFlickrInPage:(int)self.page];
    self.refreshAnimating = YES;
    
}

//Json data fetching method.
-(void)searchFlickrInPage:(int)page{
    
    __weak SFMainCollectionViewController *weakSelf = self;
    
    [self.flickr searchFlickrInPage:(int)page WithcompletionBlock:^(NSArray *results, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            if (self.page != 1) {
                [weakSelf.searchResults addObjectsFromArray:results];
            }
            else{
                if (weakSelf.searchResults != nil) {
                    weakSelf.searchResults = nil;
                }
                weakSelf.searchResults = [NSMutableArray arrayWithArray:results];
                
                if (weakSelf.refreshAnimating){
                    [weakSelf.refreshControll endRefreshing];
                }
            }
            [self.collectionView reloadData];
        });
        
    }];
}


-(void)startImageDownload:(FlickrPhoto *)record forIndexPath:(NSIndexPath *)indexPath{
    
    ImageDownloader *iconDownloader = (self.downloadingTask)[indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[ImageDownloader alloc] init];
        iconDownloader.record = record;
        [iconDownloader setCompletionHandler:^{
            
            FlickrCollectionViewCell *cell = (FlickrCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            UIImageView *imageView = cell.itemImageView;
            
            imageView.image = record.thumbnail;
            [self.downloadingTask removeObjectForKey:indexPath];
            
        }];
        (self.downloadingTask)[indexPath] = iconDownloader;
        [iconDownloader startDownload:0];
    }
    
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return [self.searchResults count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FlickrCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:mainCollectionViewCellReuseIdentifier forIndexPath:indexPath];
    UIImageView *cellImageView = cell.itemImageView;
    
    FlickrPhoto *photoItem = self.searchResults[indexPath.row];
    if (!photoItem.thumbnail) {
        
        if (self.collectionView.dragging == NO && self.collectionView.decelerating == NO)
        {
            [self startImageDownload:photoItem forIndexPath:indexPath];
        }
        // if a download is deferred or in progress, return a placeholder image
        cellImageView.image = [UIImage imageNamed:@"placeholder"];
        
    }
    else
    {
        cellImageView.image = photoItem.thumbnail;
    }

    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.item == self.searchResults.count - 1) {
        self.page = self.page + 1;
        if (self.page > self.flickr.pageNum) {
            return;
        }
        [self searchFlickrInPage:(int)self.page];
    }
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

#pragma mark -- Refresh controller setup.
- (void)loadCustomRefreshControlContents{
    
    NSArray *customViews = [[NSBundle mainBundle] loadNibNamed:@"SharkFeedRefreshControl" owner:self options:nil];
    UIView *customNibView = [customViews objectAtIndex:0];
    
    CGRect frame = CGRectMake(self.refreshControll.bounds.origin.x, self.refreshControll.bounds.origin.y, self.refreshControll.bounds.size.width, 100);
    
    customNibView.frame = frame;
    //customNibView.clipsToBounds = YES;
    
    [self.refreshControll addSubview:customNibView];
}

@end
