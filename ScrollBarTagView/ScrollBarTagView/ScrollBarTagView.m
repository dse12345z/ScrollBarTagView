//
//  ScrollBarTagView.m
//  ScrollBarTagView
//
//  Created by daisuke on 2015/11/27.
//  Copyright © 2015年 dse12345z. All rights reserved.
//

#import "ScrollBarTagView.h"
#import <objc/runtime.h>

@interface ScrollBarTagView ()

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *tagView;
@property (nonatomic, strong) UIImageView *scrollViewBarImgView;
@property (nonatomic, copy) ScrollBlock scrollBlock;
@property (nonatomic, assign) BOOL isStopHiddenAnimation;
@property (nonatomic, assign) BOOL isAnimation;

@end

@implementation ScrollBarTagView
@synthesize stayOffset = _stayOffset;

#pragma mark - class method

+ (void)initWithScrollView:(UIScrollView *)scrollView withTagView:(UIView *)tagView didScroll:(ScrollBlock)scrollBlock {
    // lock repeat add ScrollBarTagView
    if (!objc_getAssociatedObject(scrollView, _cmd)) {
        // setup ScrollBarTagView
        ScrollBarTagView *scrollBarTagView = [ScrollBarTagView new];
        scrollBarTagView.scrollView = scrollView;
        scrollBarTagView.scrollViewBarImgView = scrollView.subviews.lastObject;
        scrollBarTagView.scrollBlock = scrollBlock;
        scrollBarTagView.tagView = tagView;
        scrollBarTagView.tagView.hidden = YES;
        
        // setup tagView origin x
        CGRect newFrame = scrollBarTagView.tagView.frame;
        CGFloat tagViewX = CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetWidth(scrollBarTagView.tagView.frame);
        newFrame.origin.x = tagViewX;
        scrollBarTagView.tagView.frame = newFrame;
        
        // addObserver
        [scrollBarTagView.scrollViewBarImgView addObserver:scrollBarTagView forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        [scrollBarTagView.scrollViewBarImgView addObserver:scrollBarTagView forKeyPath:@"alpha" options:NSKeyValueObservingOptionNew context:nil];
        [scrollView.superview addSubview:scrollBarTagView.tagView];
        
        // objc runtime
        objc_setAssociatedObject(scrollView, _cmd, scrollBarTagView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

#pragma mark - private instance method

#pragma mark * misc

- (void)adjustPositionForScrollView {
    // convert scrollViewBarImgView point on scrollView superview
    CGPoint barImgViewConvertPoint = [self.scrollView convertPoint:self.scrollViewBarImgView.frame.origin toView:self.scrollView.superview];
    
    // calculate tagView from scrollViewBarImgView
    CGFloat bothCenterY = (CGRectGetHeight(self.scrollViewBarImgView.frame) - CGRectGetHeight(self.tagView.frame)) / 2.0f;
    CGFloat tagViewY = barImgViewConvertPoint.y + bothCenterY;
    CGRect newFrame = self.tagView.frame;
    newFrame.origin.y = tagViewY;
    self.tagView.frame = newFrame;
    
    self.scrollBlock(self, self.tagView, CGRectGetMidY(self.scrollViewBarImgView.frame));
}

- (CGRect)tagViewFrameToShow:(BOOL)isShow {
    CGRect newFrame = self.tagView.frame;
    CGFloat fixedSpace = CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetWidth(self.tagView.frame);
    if (isShow) {
        newFrame.origin.x = fixedSpace - tagViewGap;
    }
    else {
        newFrame.origin.x = fixedSpace + tagViewGap;
    }
    return newFrame;
}

#pragma mark * animation

- (void)showTagViewAnimation {
    if (self.tagView.hidden && !self.isAnimation && self.scrollViewBarImgView.alpha) {
        self.tagView.hidden = NO;
        self.isAnimation = YES;
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations: ^{
            weakSelf.tagView.frame = [weakSelf tagViewFrameToShow:YES];
            weakSelf.tagView.alpha = 1.0f;
        } completion: ^(BOOL finished) {
            weakSelf.isAnimation = NO;
        }];
    }
}

- (void)hiddenTagViewAnimation {
    if (!self.tagView.hidden && !self.isAnimation) {
        self.isStopHiddenAnimation = NO;
        self.isAnimation = YES;
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations: ^{
            weakSelf.tagView.frame = [weakSelf tagViewFrameToShow:NO];
            weakSelf.tagView.alpha = 0.0f;
        } completion: ^(BOOL finished) {
            if (weakSelf.isStopHiddenAnimation) {
                // stop hidden animation
                weakSelf.tagView.frame = [weakSelf tagViewFrameToShow:YES];
                weakSelf.tagView.hidden = NO;
            }
            else {
                // completion hidden animation
                weakSelf.tagView.hidden = YES;
            }
            weakSelf.isAnimation = NO;
            weakSelf.tagView.alpha = 1.0f;
        }];
    }
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        // observe scrollViewBarImgView frame (scrolling)
        [self adjustPositionForScrollView];
    }
    else if ([keyPath isEqualToString:@"alpha"]) {
        // observe scrollViewBarImgView alpha
        UIImageView *scrollViewBarImgView = (UIImageView *)object;
        if (scrollViewBarImgView.alpha && !self.tagView.alpha) {
            self.isAnimation = NO;
            self.isStopHiddenAnimation = YES;
            [self.tagView.layer removeAllAnimations];
        }
        else if (!scrollViewBarImgView.alpha) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenTagViewAnimation) object:nil];
            [self performSelector:@selector(hiddenTagViewAnimation) withObject:nil afterDelay:0.5f];
        }
    }
}

#pragma mark - getter / setter

- (void)setStayOffset:(CGFloat)stayOffset {
    _stayOffset = stayOffset;
    CGPoint centerPoint = CGPointMake(0.0f, stayOffset);
    CGPoint convertPoint = [self.scrollView convertPoint:centerPoint toView:self.scrollView.superview];
    CGRect newFrame = self.tagView.frame;
    newFrame.origin.y = convertPoint.y;
    self.tagView.frame = newFrame;
}

- (CGFloat)stayOffset {
    return _stayOffset;
}

#pragma mark - life cycle

- (void)dealloc {
    // removeObserver
    [self.scrollViewBarImgView removeObserver:self forKeyPath:@"frame"];
    [self.scrollViewBarImgView removeObserver:self forKeyPath:@"alpha"];
}

@end