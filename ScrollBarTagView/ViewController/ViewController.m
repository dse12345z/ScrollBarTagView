//
//  ViewController.m
//  ScrollBarTagView
//
//  Created by daisuke on 2015/12/1.
//  Copyright © 2015年 dse12345z. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) ScrollBarTagView *scrollBarTagView;

@end

@implementation ViewController

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%td", indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

#pragma mark - private method

- (void)setupScrollBarTagView {
    __weak typeof(self) weakSelf = self;
    self.scrollBarTagView = [ScrollBarTagView initWithScrollView:self.listTableView withTagView: ^UIView *{
        TagView *tagView = [TagView new];
        tagView.hidden = YES;
        return tagView;
    } didScroll: ^(TagView *tagView, NSNumber *offset) {
        tagView.hidden = NO;
        NSArray *cells = [weakSelf.listTableView visibleCells];
        NSString *addressLabel = @"0";
        for (UITableViewCell *cell in cells) {
            if (CGRectContainsPoint(cell.frame, tagView.center)) {
                addressLabel = [NSString stringWithFormat:@"%td", [weakSelf.listTableView indexPathForCell:cell].row];
                break;
            }
        }
        tagView.addressLabel.text = addressLabel;
    }];
}

#pragma mark - life cycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupScrollBarTagView];
}

@end
