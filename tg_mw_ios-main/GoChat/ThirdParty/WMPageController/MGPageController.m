//
//  MGPageController.m
//  MoorgenSmartHome
//
//  Created by CoderWoo on 2020/12/18.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//

#import "MGPageController.h"

@interface MGPageController()<MNNavigationBarDelegate>

@end

@implementation MGPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.menuView.backgroundColor = HexRGB(0xF7F6FB);
    self.scrollView.backgroundColor = HexRGB(0xF7F6FB);
    self.menuViewLayoutMode = WMMenuViewLayoutModeLeft;
    self.menuViewStyle = WMMenuViewStyleLine;
    self.titleSizeSelected = 16.f;
    self.titleSizeNormal = 16.f;
    self.titleColorNormal = HexRGB(0x8C8C8C);
    self.titleColorSelected = HexRGB(0xEB8933);
    self.titleFontName = @"PingFangSC-Regular";
    self.titleFontNameSelected = @"PingFangSC-Semibold";
    self.automaticallyCalculatesItemWidths = YES;
    self.itemMargin = 20;
    self.scrollEnable = FALSE;
    self.view.backgroundColor = HexRGB(0xF7F6FB);
    self.customNavBar.backgroundColor = HexRGB(0xF7F6FB);
    [self reloadData];
}
@end
