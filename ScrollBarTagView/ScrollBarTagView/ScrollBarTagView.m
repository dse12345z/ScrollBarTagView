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
@property (nonatomic, assign) BOOL isHidden;
@property (nonatomic, strong) UIView *tagView;
@property (nonatomic, copy) ScrollBlock scrollBlock;

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
    
    // addObserver
    [scrollBarTagView.scrollViewBarImgView addObserver:scrollBarTagView forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    [scrollBarTagView.scrollViewBarImgView addObserver:scrollBarTagView forKeyPath:@"alpha" options:NSKeyValueObservingOptionNew context:nil];
    [scrollView.superview addSubview:scrollBarTagView.tagView];
    
    objc_setAssociatedObject(self, _cmd, scrollBarTagView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - private instance method

#pragma mark * misc

- (void)adjustPositionForScrollView {
    CGPoint barImgViewPoint = [self.scrollView convertPoint:self.scrollViewBarImgView.frame.origin toView:self.scrollView.superview];
    
    // 計算 scrollViewBarImgView 位置給 tagView
    CGFloat bothCenterY = (CGRectGetHeight(self.scrollViewBarImgView.frame) - CGRectGetHeight(self.tagView.frame)) / 2;
    CGFloat tagViewX = (CGRectGetWidth(self.scrollView.frame) - (CGRectGetWidth(self.tagView.frame) + tagViewGap));
    CGFloat tagViewY = barImgViewPoint.y + bothCenterY;
    CGRect newFrame = self.tagView.frame;
    newFrame.origin.x = tagViewX;
    newFrame.origin.y = tagViewY;
    
    // check limit
    CGFloat bottomLimit = self.scrollView.contentOffset.y + CGRectGetHeight(self.scrollView.frame);
    CGFloat topLimit = self.scrollView.contentOffset.y;
    BOOL isDownScroll = bottomLimit < self.scrollView.contentSize.height ? YES : NO;
    BOOL isTopScroll = topLimit >= 0 ? YES : NO;
    if (isTopScroll && isDownScroll) {
        self.tagView.frame = newFrame;
    }

    CGFloat tagViewOnScrollY = CGRectGetMinY(self.scrollViewBarImgView.frame) + bothCenterY;
    self.scrollBlock(self.tagView, @(tagViewOnScrollY));
}

- (void)hiddenTagViewAnimation {
    self.isHidden = YES;
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations: ^{
        weakSelf.tagView.alpha = 0.0f;
    } completion: ^(BOOL finished) {
        weakSelf.tagView.alpha = 1.0f;
        weakSelf.tagView.hidden = weakSelf.isHidden;
    }];
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        // observe scrollViewBarImgView frame, 代表在滾動 scrollView
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenTagViewAnimation) object:nil];
        [self adjustPositionForScrollView];
    }
    else if ([keyPath isEqualToString:@"alpha"]) {
        // observe scrollViewBarImgView alpha
        UIImageView *scrollViewBarImgView = (UIImageView *)object;
        if (!scrollViewBarImgView.alpha) {
            [self performSelector:@selector(hiddenTagViewAnimation) withObject:nil afterDelay:0.5];
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