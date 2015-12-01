//
//  ViewController.h
//  ScrollBarTagView
//
//  Created by daisuke on 2015/12/1.
//  Copyright © 2015年 dse12345z. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrollBarTagView.h"
#import "TagView.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *listTableView;

@end

