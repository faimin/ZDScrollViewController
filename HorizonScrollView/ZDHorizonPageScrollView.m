//
//  ZDHorizonPageScrollView.m
//  Demo
//
//  Created by 符现超 on 2017/3/13.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "ZDHorizonPageScrollView.h"

static NSString * const CellReuseIdentifier = @"UICollectionViewCell";

@interface ZDHorizonPageScrollView ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation ZDHorizonPageScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    [self addSubview:self.collectionView];
    
    
}

- (void)setupHeaderView {
    if (self.headerView) {
        self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.headerView];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[headerView]|"
                                                                     options:NSLayoutFormatDirectionLeftToRight
                                                                     metrics:nil
                                                                       views:@{@"headerView":self.headerView}]];
        
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.headerView
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0
                                                                          constant:0.0];
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.headerView
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1.0
                                                                             constant:self.headerViewHeight];
        
        [self addConstraint:topConstraint];
        [self addConstraint:heightConstraint];
    }
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.minimumLineSpacing = 0.0;
            layout.minimumInteritemSpacing = 0.0;
            layout.scrollDirection = UICollectionViewScrollDirectionVertical;
            layout.itemSize = self.bounds.size;
            layout;
        });
        
        _collectionView = ({
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
            [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CellReuseIdentifier];
            collectionView.dataSource = self;
            collectionView.delegate = self;
            collectionView.pagingEnabled = YES;
            collectionView.showsHorizontalScrollIndicator = NO;
            collectionView.scrollsToTop = NO;
            collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            collectionView;
        });
    }
    
    return _collectionView;
}

#pragma mark - UICollectionViewDatasource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    UIScrollView *scrollView = self.contentViews[indexPath.row];
    scrollView.frame = cell.contentView.bounds;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:scrollView];
    
    
    return cell;
}

@end
