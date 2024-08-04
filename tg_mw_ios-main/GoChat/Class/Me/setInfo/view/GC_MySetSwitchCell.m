//
//  GC_MySetSwitchCell.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/14.
//

#import "GC_MySetSwitchCell.h"

@implementation GC_MySetSwitchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.openSwitch.onTintColor = UIColor.colorMain;
    [self.openSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)switchValueChanged:(UISwitch *)sender {
    !self.switchBlock ? : self.switchBlock(sender.isOn);
}

@end
