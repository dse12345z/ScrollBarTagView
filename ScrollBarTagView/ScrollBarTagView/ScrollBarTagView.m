//
//  ScrollBarTagView.m
//  ScrollBarTagView
//
//  Created by daisuke on 2015/11/27.
//  Copyright © 2015年 dse12345z. All rights reserved.
//

#import "ScrollBarTagView.h"

@interface ScrollBarTagView ()

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIImageView *scrollViewBarImgView;
@property (nonatomic, assign) BOOL isHidden;
@property (nonatomic, strong) UIView *tagView;
@property (nonatomic, copy) ScrollBlock scrollBlock;

@end

@implementation ScrollBarTagView

#pragma mark - class method

+ (ScrollBarTagView *)initWithScrollView:(UIScrollView *)scrollView withTagView:(TagViewBlock)tagViewBlock didScroll:(ScrollBlock)scrollBlock {
    // setup ScrollBarTagView
    ScrollBarTagView *scrollBarTagView = [ScrollBarTagView new];
    scrollBarTagView.scrollView = scrollView;
    scrollBarTagView.scrollViewBarImgView = scrollView.subviews.lastObject;
    scrollBarTagView.scrollBlock = scrollBlock;
    scrollBarTagView.tagView = tagViewBlock();
    
    // addObserver
    [scrollBarTagView.scrollViewBarImgView addObserver:scrollBarTagView forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    [scrollBarTagView.scrollViewBarImgView addObserver:scrollBarTagView forKeyPath:@"alpha" options:NSKeyValueObservingOptionNew context:nil];
    [scrollView addSubview:scrollBarTagView.tagView];
    return scrollBarTagView;
}

#pragma mark - private instance method

#pragma mark * misc

- (void)adjustPositionForScrollView {
    // 計算 scrollViewBarImgView 位置給 tagView
    CGFloat bothCenterY = (CGRectGetHeight(self.scrollViewBarImgView.frame) - CGRectGetHeight(self.tagView.frame)) / 2;
    CGFloat tagViewX = (CGRectGetWidth(self.scrollView.frame) - (CGRectGetWidth(self.tagView.frame) + tagViewGap));
    CGFloat tagViewY = CGRectGetMinY(self.scrollViewBarImgView.frame) + bothCenterY;
    CGRect newFrame = self.tagView.frame;
    newFrame.origin.x = tagViewX;
    
    // check tagViewY < maxScrollTop
    newFrame.origin.y = tagViewY < self.maxScrollTop ? self.maxScrollTop : tagViewY;
    self.tagView.frame = newFrame;
    
    // return tagView, tagViewY
    self.scrollBlock(self.tagView, @(newFrame.origin.y));
}

#pragma mark * tagView hidden

- (void)removeHiddenTagViewAnimation {
    self.isHidden = NO;
    [self.tagView.layer removeAllAnimations];
}

- (void)hiddenTagViewAnimation {
    self.isHidden = YES;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations: ^{
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
        [self removeHiddenTagViewAnimation];
        [self adjustPositionForScrollView];
    }
    else if ([keyPath isEqualToString:@"alpha"]) {
        // observe scrollViewBarImgView alpha
        UIImageView *scrollViewBarImgView = (UIImageView *)object;
        if (!scrollViewBarImgView.alpha) {
            [self hiddenTagViewAnimation];
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