//
//  ZDScrollViewController.m
//  Demo
//
//  Created by 符现超 on 2016/12/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDScrollViewController.h"
#import <Masonry.h>
#import "ZDScrollCollectionViewCell.h"
#import "ZDCollectionHeaderView.h"

static CGSize ZD_ScreenSize() {
    return [UIScreen mainScreen].bounds.size;
}

UIColor *ZD_RandomColor() {
    CGFloat hue = (arc4random() % 256 / 256.0);
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

static NSString * const CellReuseIdentifier = @"ZDScrollCollectionViewCell";
static NSString * const HeaderReuseIdentifier = @"ZDCollectionHeaderView";

@interface ZDScrollViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;
//@property (nonatomic, strong) NSMutableArray<UIView *> *childViews;
@end

@implementation ZDScrollViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setup {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setupView];
}

- (void)setupView {
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.collectionView];
    
    //给headerView、collectionView添加约束
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.headerView.mas_bottom);
    }];
    
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewControllers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    __kindof UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    [self configCollectionViewCell:cell atIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        NSAssert(NO, @"未注册footer");
        NSLog(@"未注册footer");
    }
    UICollectionReusableView *header = [collectionView dequeueReusableCellWithReuseIdentifier:HeaderReuseIdentifier forIndexPath:indexPath];
    return header;
}

#pragma mark - Public Method

- (void)reloadData {
    [self.collectionView reloadData];
}

#pragma mark - Private Method

- (void)configCollectionViewCell:(ZDScrollCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundView.backgroundColor = ZD_RandomColor();
    
    UIViewController *childVC = self.viewControllers[indexPath.row];
    [self addChildViewController:childVC];
    childVC.view.backgroundColor = ZD_RandomColor();
    cell.subView = childVC.view;
//    if (childVC.view) {
//        [self.childViews addObject:childVC.view];
//    }
    [childVC didMoveToParentViewController:self];
}



#pragma mark - System Method

- (void)viewDidLayoutSubviews {
    self.flowLayout.itemSize = (CGSize) {
        ZD_ScreenSize().width,
        ZD_ScreenSize().height - CGRectGetHeight(self.collectionView.frame)
    };
    
    [super viewDidLayoutSubviews];
}

#pragma mark - Property
//Setter
- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers {
    if (_viewControllers && _viewControllers.count > 0) {
        for (UIViewController *controller in _viewControllers) {
            [controller willMoveToParentViewController:nil];
            [controller.view removeFromSuperview];
            [controller removeFromParentViewController];
        }
    }
    
    if (viewControllers && [viewControllers isKindOfClass:[NSArray class]]) {
        //初始化 childViews
//        if (self.childViews && self.childViews.count > 0) {
//            [self.childViews removeAllObjects];
//        } else {
//            self.childViews = [[NSMutableArray alloc] initWithCapacity:viewControllers.count];
//        }
        
        _viewControllers = viewControllers.copy;
    }
}

//Getter
- (UIView *)headerView {
    // 如果外界没设置headerView，则给个默认视图
    if (!_headerView) {
        _headerView = [UIView new];
    }
    return _headerView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumInteritemSpacing = 0.0;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.allowsSelection = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.bounces = YES;
        _collectionView.pagingEnabled = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.delaysContentTouches = NO;
        
        [_collectionView registerClass:[ZDScrollCollectionViewCell class] forCellWithReuseIdentifier:CellReuseIdentifier];
        [_collectionView registerClass:[ZDCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeaderReuseIdentifier];
    }
    return _collectionView;
}

@end
