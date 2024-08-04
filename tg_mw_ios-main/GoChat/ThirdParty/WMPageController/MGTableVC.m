//
//  MGTableVC.m
//  MoorgenSmartHome
//
//  Created by CoderWoo on 2020/12/18.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//

#import "MGTableVC.h"

@implementation MGTableVC
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.customNavBar removeFromSuperview];
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
  
}

@end
