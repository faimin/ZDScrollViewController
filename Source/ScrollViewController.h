//
//  ScrollViewController.h
//  Demo
//
//  Created by 符现超 on 2016/12/26.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollViewController : UIViewController

@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *headerView;
//@property (nonatomic, copy) IBOutletCollection(UIViewController) NSArray<UIViewController *> *viewControllers;

@end
