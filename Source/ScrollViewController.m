//
//  ScrollViewController.m
//  Demo
//
//  Created by 符现超 on 2016/12/26.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ScrollViewController.h"
#import <Masonry.h>
#import <VTMagic.h>
#import "TableViewController.h"

static UIColor *ZD_RandomColor() {
    CGFloat hue = (arc4random() % 256 / 256.0);
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

static CGFloat ZD_CalculateDynamicHeightWithMaxWidth(UIView *view, CGFloat maxWidth) {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat viewMaxWidth = maxWidth ? : CGRectGetWidth([UIScreen mainScreen].bounds);
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:viewMaxWidth];
    
    [view addConstraint:widthConstraint];
    CGSize fittingSize = [view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    [view removeConstraint:widthConstraint];
    
    return fittingSize.height;
}

static CGSize ZD_ScreenSize() {
    return [UIScreen mainScreen].bounds.size;
}

static CGFloat const TempHeight = 1000.0;
static NSString *const contentOffsetKeyPath = @"contentOffset";

@interface ScrollViewController ()<UIScrollViewDelegate, VTMagicViewDataSource, VTMagicViewDelegate>
@property (nonatomic, strong, readwrite) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) VTMagicController *magicController;
@property (nonatomic, weak) VTMagicView *magicView;
@property (nonatomic, assign) CGFloat headerViewHeight;
@end

@implementation ScrollViewController

#pragma mark - Life Cycle

- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:contentOffsetKeyPath];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CGFloat headerViewHeight = CGRectGetHeight(self.headerView.bounds);
    NSLog(@"头视图的高度 = %f", headerViewHeight);
    _headerViewHeight = headerViewHeight;
    [self.view setNeedsUpdateConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupController];
    [self setupView];
    [self addObserverForScrollView];
}

- (void)setupController {
    [self addChildViewController:self.magicController];
    [self.magicController didMoveToParentViewController:self];
}

- (void)setupView {
    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];
    
    [self.contentView addSubview:self.headerView];
    VTMagicView *magicView = self.magicController.magicView;
    self.magicView = self.magicController.magicView;
    [self.contentView addSubview:magicView];
    
    //添加约束
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
    }];
    [magicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.contentView);
        make.top.equalTo(self.headerView.mas_bottom);
        make.height.mas_equalTo(TempHeight).priorityLow();
    }];
    
    [magicView reloadData];
}

#pragma mark - KVO

- (void)addObserverForScrollView {
    [self.scrollView addObserver:self forKeyPath:contentOffsetKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:contentOffsetKeyPath]) {
        NSValue *value = change[NSKeyValueChangeNewKey];
        CGPoint point = value.CGPointValue;
        [self scrollViewContentOffsetY:point.y];
    }
}

- (void)scrollViewContentOffsetY:(CGFloat)contentOffsetY {
    UIScrollView *tableView = ((TableViewController *)self.magicController.currentViewController).tableView;
    NSLog(@"偏移量 => %f", contentOffsetY);
    
    if (contentOffsetY > _headerViewHeight) {//悬停在最上面
        [self.scrollView.panGestureRecognizer requireGestureRecognizerToFail:tableView.panGestureRecognizer];
        self.scrollView.canCancelContentTouches = NO;
        [self.scrollView setContentOffset:CGPointMake(0, _headerViewHeight) animated:NO];
    }
    else {
        [tableView.panGestureRecognizer requireGestureRecognizerToFail:self.scrollView.panGestureRecognizer];
        self.scrollView.canCancelContentTouches = YES;
    }
}

#pragma mark - VTMagicViewDataSource && Delegate

- (NSArray<__kindof NSString *> *)menuTitlesForMagicView:(VTMagicView *)magicView {
    return @[@"详情", @"目录", @"评论"];
}

- (UIButton *)magicView:(VTMagicView *)magicView menuItemAtIndex:(NSUInteger)itemIndex {
    UIButton *button = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = ZD_RandomColor();
        button;
    });
    return button;
}

- (UIViewController *)magicView:(VTMagicView *)magicView viewControllerAtPage:(NSUInteger)pageIndex {
    if (pageIndex == 0) {
        TableViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TableViewController class])];
        [vc.tableView.panGestureRecognizer requireGestureRecognizerToFail:self.scrollView.panGestureRecognizer];
        return vc;
    }
    else {
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = ZD_RandomColor();
        return vc;
    }
}

#pragma mark - UIScrollViewDelegate


#pragma mark - System Method

- (void)viewDidLayoutSubviews {
    CGFloat headerViewHeith = ZD_CalculateDynamicHeightWithMaxWidth(self.headerView, CGRectGetWidth(self.view.bounds));
    NSLog(@"====> %f", headerViewHeith);
    _headerViewHeight = headerViewHeith;
    [super viewDidLayoutSubviews];
    
}

- (void)updateViewConstraints {
    [self.magicView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.contentView);
        make.top.equalTo(self.headerView.mas_bottom);
        make.height.mas_equalTo(ZD_ScreenSize().height - 64).priorityLow();
    }];
    
    [super updateViewConstraints];
}

#pragma mark - Private Method



#pragma mark - Property
//Getter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        //_scrollView.delaysContentTouches = NO;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [UIView new];
    }
    return _headerView;
}

- (VTMagicController *)magicController {
    if (!_magicController) {
        _magicController = [[VTMagicController alloc] init];
        _magicController.magicView.navigationColor = [UIColor whiteColor];
        _magicController.magicView.sliderColor = [UIColor redColor];
        _magicController.magicView.layoutStyle = VTLayoutStyleDivide;
        _magicController.magicView.switchStyle = VTSwitchStyleDefault;
        _magicController.magicView.navigationHeight = 44.f;
        _magicController.magicView.dataSource = self;
        _magicController.magicView.delegate = self;
        //((UIScrollView *)[_magicController.magicView valueForKey:@"contentView"]).delaysContentTouches = NO;
    }
    return _magicController;
}

//Setter
//- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers {
//    if (_viewControllers && _viewControllers.count > 0) {
//        for (UIViewController *controller in _viewControllers) {
//            [controller willMoveToParentViewController:nil];
//            [controller.view removeFromSuperview];
//            [controller removeFromParentViewController];
//        }
//    }
//    
//    if (viewControllers && [viewControllers isKindOfClass:[NSArray class]]) {
//        _viewControllers = viewControllers.copy;
//    }
//}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return NO;
//}

@end
