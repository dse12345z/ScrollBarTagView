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
@property (nonatomic, weak) UIImageView *scrollViewBarImgView;
@property (nonatomic, weak) UIView *tagView;
@property (nonatomic, copy) ScrollBlock scrollBlock;
@property (nonatomic, assign) BOOL isStopHiddenAnimation;
@property (nonatomic, assign) BOOL isAnimation;

@end

@implementation ScrollBarTagView

#pragma mark - class method

+ (void)initWithScrollView:(UIScrollView *)scrollView withTagView:(TagViewBlock)tagViewBlock didScroll:(ScrollBlock)scrollBlock {
    // setup ScrollBarTagView
    ScrollBarTagView *scrollBarTagView = [ScrollBarTagView new];
    scrollBarTagView.scrollView = scrollView;
    scrollBarTagView.scrollViewBarImgView = scrollView.subviews.lastObject;
    scrollBarTagView.scrollBlock = scrollBlock;
    scrollBarTagView.tagView = tagViewBlock();
    scrollBarTagView.tagView.hidden = YES;
    
    // addObserver
    [scrollBarTagView.scrollViewBarImgView addObserver:scrollBarTagView forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    [scrollBarTagView.scrollViewBarImgView addObserver:scrollBarTagView forKeyPath:@"alpha" options:NSKeyValueObservingOptionNew context:nil];
    [scrollView.superview addSubview:scrollBarTagView.tagView];
    
    objc_setAssociatedObject(self, _cmd, scrollBarTagView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - private instance method

#pragma mark * misc

- (void)adjustPositionForScrollView {
    // convert scrollViewBarImgView point on scrollView superview
    CGPoint barImgViewConvertPoint = [self.scrollView convertPoint:self.scrollViewBarImgView.frame.origin toView:self.scrollView.superview];
    
    // 計算 scrollViewBarImgView 位置給 tagView
    CGFloat bothCenterY = (CGRectGetHeight(self.scrollViewBarImgView.frame) - CGRectGetHeight(self.tagView.frame)) / 2.0f;
    CGFloat tagViewY = barImgViewConvertPoint.y + bothCenterY;
    CGRect newFrame = self.tagView.frame;
    newFrame.origin.y = tagViewY;
    
    if (!self.isAnimation && self.tagView.hidden) {
        // 隱藏狀態下保持 origin.x 初始化 (沒有動畫)
        CGFloat tagViewX = CGRectGetWidth(self.scrollView.frame) - CGRectGetWidth(self.tagView.frame);
        newFrame.origin.x = tagViewX;
    }
    
    // check screen limit
    CGFloat topLimit = self.scrollView.contentOffset.y;
    CGFloat bottomLimit = self.scrollView.contentOffset.y + CGRectGetHeight(self.scrollView.frame);
    BOOL isTopScreen = topLimit >= 0 ? YES : NO;
    BOOL isDownScreen = bottomLimit < self.scrollView.contentSize.height ? YES : NO;
    if (isTopScreen && isDownScreen) {
        self.tagView.frame = newFrame;
    }
    
    [self showTagViewAnimation];
    
    CGFloat tagViewOnScrollY = CGRectGetMinY(self.scrollViewBarImgView.frame) + bothCenterY;
    self.scrollBlock(self.tagView, tagViewOnScrollY);
}

- (CGRect)tagViewFrameToShow:(BOOL)isShow {
    CGRect newFrame = self.tagView.frame;
    if (isShow) {
        newFrame.origin.x -= tagViewGap;
    }
    else {
        newFrame.origin.x += tagViewGap;
    }
    return newFrame;
}

#pragma mark * animation

- (void)showTagViewAnimation {
    if (self.tagView.hidden && !self.isAnimation) {
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
                // 中斷隱藏動畫
                weakSelf.tagView.frame = [weakSelf tagViewFrameToShow:YES];
                weakSelf.tagView.hidden = NO;
            }
            else {
                // 完成隱藏動畫
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
        // observe scrollViewBarImgView frame, 代表在滾動 scrollView
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

#pragma mark - life cycle

- (void)dealloc {
    // removeObserver
    [self.scrollViewBarImgView removeObserver:self forKeyPath:@"frame"];
    [self.scrollViewBarImgView removeObserver:self forKeyPath:@"alpha"];
}

@end