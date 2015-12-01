//
//  TagView.m
//  Demo
//
//  Created by daisuke on 2015/11/30.
//  Copyright © 2015年 dse12345z. All rights reserved.
//

#import "TagView.h"

@implementation TagView

#pragma mark - life cycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        self = arrayOfViews[0];
    }
    return self;
}

@end
