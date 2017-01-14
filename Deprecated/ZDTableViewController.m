//
//  ZDTableViewController.m
//  Demo
//
//  Created by 符现超 on 2017/1/11.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//
//  PS: 控制器上添加tableView，然后滑动控制器添加到tableViewCell上
//  此种方案貌似行不通

#import "ZDTableViewController.h"
#import <Masonry.h>
#import <VTMagic/VTMagic.h>
#import "ZDTableViewCell.h"

#pragma mark - #############  Define

static NSString * const ReuseIdentifier = @"ZDTableViewCell";

static CGSize ScreenSize() {
    return [UIScreen mainScreen].bounds.size;
}

static UIColor *ZD_RandomColor() {
    CGFloat hue = (arc4random() % 256 / 256.0);
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

#pragma mark - ############# UIScrollView Category

@interface UIScrollView (Simultaneously) <UIGestureRecognizerDelegate>

@end

@implementation UIScrollView (Simultaneously)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end

#pragma mark - #############  ZDTableViewController

@interface ZDTableViewController () <UITableViewDataSource, UITableViewDelegate, VTMagicViewDataSource, VTMagicViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) VTMagicController *magicController;
@property (nonatomic, weak) VTMagicView *magicView;
@end

@implementation ZDTableViewController

#pragma mark - Life Cycle

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup {
    [self setupUI];
    [self setupData];
}

- (void)setupUI {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.tableView.tableHeaderView = self.headerView;
    [self.tableView reloadData];
}

- (void)setupData {
    //TODO:
}

#pragma mark - UITableViewDatasource && UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    cell.superController = self;
    //添加子滑动视图
    [self addVTMagicViewWithCell:cell];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    NSLog(@"%f", contentOffsetY);
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
        return vc;
    }
    else {
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = ZD_RandomColor();
        return vc;
    }
}

#pragma mark - Private Method

- (void)addVTMagicViewWithCell:(ZDTableViewCell *)cell {
    [self addChildViewController:self.magicController];
    [cell.contentView addSubview:self.magicController.magicView];
    [self.magicController.magicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(cell.contentView);
    }];
    [self.magicController didMoveToParentViewController:self];
    
    [self.magicView reloadData];
}

#pragma mark - Property

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = ScreenSize().height;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[ZDTableViewCell class] forCellReuseIdentifier:ReuseIdentifier];
        [self.view addSubview:_tableView];
    }
    return _tableView;
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
        self.magicView = _magicController.magicView;
    }
    return _magicController;
}


@end
