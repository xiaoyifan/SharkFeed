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

@end

@implementation SFMainCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchResults = [@[] mutableCopy];
    self.flickr = [[Flickr alloc] init];

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:mainCollectionViewCellReuseIdentifier];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

//// 1
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//
//    FlickrPhoto *photo =
//    self.searchResults[indexPath.row];
//    // 2
//    CGSize retval = photo.thumbnail.size.width > 0 ? photo.thumbnail.size : CGSizeMake(100, 100);
//    retval.height += 35; retval.width += 35; return retval;
//}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 20, 50, 20);
}

@end
