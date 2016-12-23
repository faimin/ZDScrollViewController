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
    
    self.headerView = [[NSBundle mainBundle] loadNibNamed:@"ZDView" owner:nil options:nil].lastObject;
    UIViewController *VC = [self viewControllerFromStoryBoardWithId:@"TableViewController"];
    VC.view.backgroundColor = ZD_RandomColor();
    self.viewControllers = @[VC, VC, VC];
    
    [super viewDidLoad];
    
    [self reloadData];
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
