//
//  ZDScrollCollectionViewCell.m
//  Demo
//
//  Created by 符现超 on 2016/12/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDScrollCollectionViewCell.h"
#import <Masonry.h>

@interface ZDScrollCollectionViewCell ()

@end

@implementation ZDScrollCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //
    }
    return self;
}

- (void)setSubView:(UIView *)subView {
    if (_subView != subView) {
        [_subView removeFromSuperview];
        [self.contentView addSubview:subView];
        [subView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        _subView = subView;
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

@end
