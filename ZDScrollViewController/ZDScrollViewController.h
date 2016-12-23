//
//  ZDScrollViewController.h
//  Demo
//
//  Created by 符现超 on 2016/12/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT UIColor *ZD_RandomColor();

@interface ZDScrollViewController : UIViewController

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, copy) IBOutletCollection(UIViewController) NSArray<UIViewController *> *viewControllers;

- (void)reloadData;

@end
