//
//  ZDHeaderView.m
//  Demo
//
//  Created by 符现超 on 2016/12/26.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDHeaderView.h"

static NSString *const panGestureKeyPath = @"state";
static void *panGestureContextState = &panGestureContextState;

static CGFloat rubberBandRate(CGFloat offset) {
    const CGFloat constant = 0.15f;
    const CGFloat dimension = 10.0f;
    const CGFloat startRate = 0.85f;
    // 计算拖动视图translation的增量比率，起始值为startRate（此时offset为0）；随着frame超出的距离offset的增大，增量比率减小
    CGFloat result = dimension * startRate / (dimension + constant * fabs(offset));
    return result;
}

@interface ZDDynamicItem : NSObject <UIDynamicItem>
@property (nonatomic, readwrite) CGPoint center;
@property (nonatomic, readonly) CGRect bounds;
@property (nonatomic, readwrite) CGAffineTransform transform;
@end

@implementation ZDDynamicItem

- (instancetype)init {
    self = [super init];
    if (self) {
        // Sets non-zero `bounds`, because otherwise Dynamics throws an exception.
        _bounds = CGRectMake(0, 0, 1, 1);
    }
    return self;
}

@end


@interface ZDHeaderView () <UIDynamicAnimatorDelegate>
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIDynamicItemBehavior *decelerationBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *springBehavior;
@property (nonatomic, strong) ZDDynamicItem *dynamicItem;
@property (nonatomic, assign) BOOL isTracking;
@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) BOOL isDecelerating;
@property (nonatomic, assign) CGRect newFrame;
@end

@implementation ZDHeaderView

#pragma mark - Life Cycle

- (void)dealloc {
    [self.panGestureRecognizer removeObserver:self forKeyPath:panGestureKeyPath context:panGestureContextState];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    self.animator = ({
        UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
        animator.delegate = self;
        animator;
    });
    //MARK: TODO
    
}

#pragma mark - Public Method

- (void)endDecelerating {
    [self.animator removeAllBehaviors];
    [self setDecelerationBehavior:nil];
    [self setSpringBehavior:nil];
}

#pragma mark - Private Method

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self endDecelerating];
            _isTracking = YES;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            _isTracking = YES;
            _isDragging = YES;
            
            CGRect selfFrame = self.frame;
            CGPoint translation = [panGesture translationInView:self.superview];//手指移动的距离坐标
            CGFloat newFrameY = selfFrame.origin.y + translation.y;
            CGPoint minFrameOrigin = [self minFrameOrgin];
            CGPoint maxFrameOrigin = [self maxFrameOrgin];
            CGFloat constrainedY = fmax(minFrameOrigin.y, fmin(newFrameY, maxFrameOrigin.y));
            CGFloat rubberBandedRate = rubberBandRate(newFrameY - constrainedY);
            
            selfFrame.origin = (CGPoint){
                selfFrame.origin.x,
                CGRectGetMinY(selfFrame) + translation.y * rubberBandedRate
            };
            self.newFrame = selfFrame;
            
            [panGesture setTranslation:(CGPoint){translation.x, 0} inView:self.superview];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            _isTracking = NO;
            _isDragging = NO;
            CGPoint velocity = [panGesture velocityInView:self];
            // only support vertical
            velocity.x = 0;
            
            self.dynamicItem.center = self.frame.origin;
            self.decelerationBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.dynamicItem]];
            [_decelerationBehavior addLinearVelocity:velocity forItem:self.dynamicItem];
            _decelerationBehavior.resistance = 2;
            
            __weak typeof(self) weakSelf = self;
            _decelerationBehavior.action = ^{
                CGPoint center = weakSelf.dynamicItem.center;
                center.x       = weakSelf.frame.origin.x;
                CGRect frame   = weakSelf.frame;
                frame.origin   = center;
                weakSelf.newFrame = frame;
            };

        }
            break;
        default:
            break;
    }
}

- (CGPoint)minFrameOrgin {
    CGPoint orgin = CGPointMake(0, 0);
    if (_delegate && [_delegate respondsToSelector:@selector(minHeaderViewFrameOrgin)]) {
        orgin = [_delegate minHeaderViewFrameOrgin];
    }
    return orgin;
}

- (CGPoint)maxFrameOrgin {
    CGPoint orgin = CGPointMake(0, 0);
    if (_delegate && [_delegate respondsToSelector:@selector(maxHeaderViewFrameOrgin)]) {
        orgin = [_delegate maxHeaderViewFrameOrgin];
    }
    return orgin;
}

- (void)setNewFrame:(CGRect)frame {
    [self setFrame:frame];
    
    CGPoint minFrameOrgin = [self minFrameOrgin];
    CGPoint maxFrameOrgin = [self maxFrameOrgin];
    
    BOOL outsideFrameMinimum = frame.origin.y < minFrameOrgin.y;
    BOOL outsideFrameMaximum = frame.origin.y > maxFrameOrgin.y;
    
    if ((outsideFrameMinimum || outsideFrameMaximum) &&
        (_decelerationBehavior && !_springBehavior)) {
        
        CGPoint target = frame.origin;
        if (outsideFrameMinimum) {
            target.x = fmax(target.x, minFrameOrgin.x);
            target.y = fmax(target.y, minFrameOrgin.y);
        } else if (outsideFrameMaximum) {
            target.x = fmin(target.x, maxFrameOrgin.x);
            target.y = fmin(target.y, maxFrameOrgin.y);
        }
        
        self.springBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.dynamicItem attachedToAnchor:target];
        // Has to be equal to zero, because otherwise the frame wouldn't exactly match the target's position.
        _springBehavior.length = 0;
        // These two values were chosen by trial and error.
        _springBehavior.damping = 1;
        _springBehavior.frequency = 2;
        
        [self.animator addBehavior:_springBehavior];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(headerViewDidFrameChanged:)]) {
        [_delegate headerViewDidFrameChanged:self];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView * view = [super hitTest:point withEvent:event];
    
    // end header deceleraling when another began.
    [self endDecelerating];
    
    // tap inside of the header view
    if (CGRectContainsPoint(self.bounds, point)) {
        // return self to response this event,to avoid other view receiving this event when the header is decelerating.
        if (_isDecelerating) {
            return self;
        }
    }
    
    return view;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == panGestureContextState) {
        if (_delegate && [_delegate respondsToSelector:@selector(headerView:didPanGestureRecognizerStateChanged:)]) {
            [_delegate headerView:self didPanGestureRecognizerStateChanged:object];
        }
    }
}

#pragma mark - UIDynamicAnimatorDelegate

- (void)dynamicAnimatorWillResume:(UIDynamicAnimator *)animator {
    self.isDecelerating = YES;
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {
    self.isDecelerating = NO;
}

#pragma mark - Property 

- (UIPanGestureRecognizer *)panGestureRecognizer {
    if (!_panGestureRecognizer) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:_panGestureRecognizer];
        
        [_panGestureRecognizer addObserver:self forKeyPath:panGestureKeyPath options:NSKeyValueObservingOptionNew context:panGestureContextState];
    }
    return _panGestureRecognizer;
}



@end













