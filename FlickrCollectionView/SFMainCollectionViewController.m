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
#import "SFImageDetailViewController.h"

#define CollectionViewTopEdges 10.0
#define CollectionViewLeftEdges 5.0
#define CollectionViewRightEdges 5.0
#define CollectionViewCellSpace 2.0

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
    [self.collectionView setContentInset:UIEdgeInsetsMake(CollectionViewTopEdges, CollectionViewLeftEdges, 0, CollectionViewRightEdges)];
    
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
        dispatch_async(dispatch_get_main_queue(), ^{
            
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
            
            imageView.image = [record.imageCache objectForKey:record.thumbnailURL];
            [self.downloadingTask removeObjectForKey:indexPath];
            
        }];
        (self.downloadingTask)[indexPath] = iconDownloader;
        [iconDownloader startDownload:ThumbnailImage];
    }
    
}

- (void)loadImagesForOnscreenRows
{
    if (self.searchResults.count > 0)
    {
        NSArray *visibleItems = [self.collectionView indexPathsForVisibleItems];
        
        for (NSIndexPath *indexPath in visibleItems)
        {
            FlickrPhoto * pItem = (self.searchResults)[indexPath.item];
            
            if (![pItem.imageCache objectForKey:pItem.thumbnailURL])
                // Avoid the app icon download if the app already has an icon
            {
                [self startImageDownload:pItem forIndexPath:indexPath];
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


#pragma mark -- UICollectionView DataSource

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
    if (![photoItem.imageCache objectForKey:photoItem.thumbnailURL]) {
        
        if (self.collectionView.dragging == NO && self.collectionView.decelerating == NO)
        {
            [self startImageDownload:photoItem forIndexPath:indexPath];
        }
        // if a download is deferred or in progress, return a placeholder image
        cellImageView.image = [UIImage imageNamed:@"placeholder"];
        
    }
    else
    {
        cellImageView.image = [photoItem.imageCache objectForKey:photoItem.thumbnailURL];
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (self.collectionView.frame.size.width - CollectionViewLeftEdges - CollectionViewRightEdges - 2*CollectionViewCellSpace)/3.0;
    return CGSizeMake(width, width);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return CollectionViewCellSpace;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return CollectionViewCellSpace;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark -- Refresh controller setup.
- (void)loadCustomRefreshControlContents{
    
    NSArray *customViews = [[NSBundle mainBundle] loadNibNamed:@"SharkFeedRefreshControl" owner:self options:nil];
    UIView *customNibView = [customViews objectAtIndex:0];
    
    CGRect frame = CGRectMake(self.refreshControll.bounds.origin.x, self.refreshControll.bounds.origin.y, self.refreshControll.bounds.size.width, 100);
    
    customNibView.frame = frame;
    
    [self.refreshControll addSubview:customNibView];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"detailSegue"]) {
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        SFImageDetailViewController *destViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        destViewController.record = (self.searchResults)[indexPath.row];
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
    
}



@end
