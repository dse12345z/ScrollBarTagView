//
//  ScrollBarTagView.h
//  ScrollBarTagView
//
//  Created by daisuke on 2015/11/27.
//  Copyright © 2015年 dse12345z. All rights reserved.
//

#import <UIKit/UIKit.h>

#define tagViewGap 15

typedef UIView *(^TagViewBlock)();
typedef void (^ScrollBlock)(id tagView, id offset);

@interface ScrollBarTagView : NSObject

+ (void)initWithScrollView:(UIScrollView *)scrollView withTagView:(TagViewBlock)tagViewBlock didScroll:(ScrollBlock)scrollBlock;

@end

