//
//  ZDHeaderView.h
//  Demo
//
//  Created by 符现超 on 2016/12/26.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZDHeaderView;

@protocol ZDHeaderViewDelegate <NSObject>

- (CGPoint)minHeaderViewFrameOrgin;
- (CGPoint)maxHeaderViewFrameOrgin;

@optional
- (void)headerViewDidFrameChanged:(ZDHeaderView *)headerView;
- (void)headerView:(ZDHeaderView *)headerView didPan:(UIPanGestureRecognizer *)pan;
- (void)headerView:(ZDHeaderView *)headerView didPanGestureRecognizerStateChanged:(UIPanGestureRecognizer *)pan;

@end

@interface ZDHeaderView : UIView

@property (nonatomic, weak) id<ZDHeaderViewDelegate> delegate;

@end
