//
//  ZDViewController.m
//  Demo
//
//  Created by 符现超 on 2016/12/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDViewController.h"

@interface ZDViewController ()

@end

@implementation ZDViewController

- (void)viewDidLoad {
    NSMutableArray *vcsArr = @[].mutableCopy;
    
    self.headerView = [[NSBundle mainBundle] loadNibNamed:@"ZDView" owner:nil options:nil].lastObject;
//    for (int i = 0; i < 3; i++) {
//        UIViewController *VC = [self viewControllerFromStoryBoardWithId:@"TableViewController"];
//        VC.view.backgroundColor = ZD_RandomColor();
//        VC.automaticallyAdjustsScrollViewInsets = NO;
//        VC.edgesForExtendedLayout = UIRectEdgeNone;
//        vcsArr[i] = VC;
//    }
//    self.viewControllers = vcsArr;
    
    [super viewDidLoad];
    
//    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)viewControllerFromStoryBoardWithId:(NSString *)storyboardId {
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:storyboardId];
    return vc;
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
