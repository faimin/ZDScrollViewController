//
//  ZDHorizonPageScrollView.h
//  Demo
//
//  Created by 符现超 on 2017/3/13.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZDHorizonPageScrollView : UIView

@property (nonatomic, strong) __kindof UIView *headerView;
@property (nonatomic, assign) CGFloat headerViewHeight;
@property (nonatomic, strong) NSArray<UIScrollView *> *contentViews;

@end
