//
//  ScrollViewController.m
//  Demo
//
//  Created by 符现超 on 2016/12/26.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//
//  PS: 控制器添加scrollView，scrollView上再添加滑动控制器

#import "ScrollViewController.h"
#import <Masonry.h>
#import <VTMagic.h>

static CGFloat const TempHeight = 1000.0;
static NSString *const contentOffsetKeyPath = @"contentOffset";

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


@interface ZDScrollView : UIScrollView <UIGestureRecognizerDelegate>

@end

@implementation ZDScrollView

- (instancetype)init {
    if (self = [super init]) {
        [self config];
    }
    return self;
}

- (void)config {
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end

@interface ScrollViewController ()<VTMagicViewDataSource, VTMagicViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong, readwrite) ZDScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) VTMagicController *magicController;
@property (nonatomic, weak  ) VTMagicView *magicView;
@property (nonatomic, assign) CGFloat headerViewHeight;
@property (nonatomic, assign) BOOL isCanScroll; //能够滑动
@property (nonatomic, assign) CGFloat lastContentOffsetY;
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
        if ([object isKindOfClass:[self.scrollView class]]) {
            [self scrollViewContentOffsetY:point.y];
        }
    }
}

- (void)scrollViewContentOffsetY:(CGFloat)contentOffsetY {
    UIScrollView *currentScrollView = nil;
    CGFloat currentScrollViewContentOffsetY = 0;
    if ([self.magicController.currentViewController respondsToSelector:@selector(scrollView)]) {
        currentScrollView = [self.magicController.currentViewController scrollView];
        currentScrollViewContentOffsetY = currentScrollView.contentOffset.y;
    }
    else {
        return;
    }
    //NSLog(@"偏移量 => %f", contentOffsetY);
    
    if (contentOffsetY > _headerViewHeight) { //悬停在最上面
        [self.scrollView setContentOffset:CGPointMake(0, _headerViewHeight) animated:NO];
        self.isCanScroll = YES;
    }
    else if (contentOffsetY < _headerViewHeight) {
        //[currentScrollView setContentOffset:CGPointMake(0, currentScrollViewContentOffsetY) animated:NO];
    }
    
    if (self.lastContentOffsetY > contentOffsetY) {
        NSLog(@"↑");
    }
    else if (self.lastContentOffsetY < contentOffsetY) {
        NSLog(@"⬇️");
        //TODO:
        if (contentOffsetY >= _headerViewHeight && currentScrollView.contentOffset.y > 0) {
            [self.scrollView setContentOffset:CGPointMake(0, _headerViewHeight) animated:NO];
            self.isCanScroll = YES;
        }
        else {
            
        }
    }
    
    self.lastContentOffsetY = contentOffsetY;
}

- (void)postScrollNotification:(BOOL)isCanScroll {
    [[NSNotificationCenter defaultCenter] postNotificationName:kIsCanScrollNotificationName
                                                        object:self
                                                      userInfo:@{isCanScrollKeyPath : @(isCanScroll)}];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"拖拽");
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
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TableViewController"];
        //[vc.tableView.panGestureRecognizer requireGestureRecognizerToFail:self.scrollView.panGestureRecognizer];
        return vc;
    }
    else {
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = ZD_RandomColor();
        return vc;
    }
}

#pragma mark - UIGestureRecognizerDelegate



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
//Setter
- (void)setIsCanScroll:(BOOL)isCanScroll {
    [self postScrollNotification:isCanScroll];
    _isCanScroll = isCanScroll;
}

//Getter
- (ZDScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[ZDScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
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



@end
