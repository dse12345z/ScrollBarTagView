//
//  ScrollBarTagView.h
//  ScrollBarTagView
//
//  Created by daisuke on 2015/11/27.
//  Copyright © 2015年 dse12345z. All rights reserved.
//

#import <UIKit/UIKit.h>

#define tagViewGap 10

typedef UIView *(^TagViewBlock)();
typedef void (^ScrollBlock)(id scrollBarTagView, id tagView, CGFloat offset);

@interface ScrollBarTagView : NSObject

@property (nonatomic, assign) CGFloat stayOffset;

+ (void)initWithScrollView:(UIScrollView *)scrollView withTagView:(TagViewBlock)tagViewBlock didScroll:(ScrollBlock)scrollBlock;

- (void)showTagViewAnimation;
- (void)hiddenTagViewAnimation;

@end