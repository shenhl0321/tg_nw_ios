//
//  MNNavPageController.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/1.
//

#import "MNNavPageController.h"

@interface MNNavPageController ()

@end

@implementation MNNavPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.menuView.backgroundColor = [UIColor colorTextForFFFFFF];
    self.scrollView.backgroundColor = [UIColor colorTextForFFFFFF];
    self.menuViewLayoutMode = WMMenuViewLayoutModeLeft;
    self.menuViewStyle = WMMenuViewStyleLine;
    self.titleSizeSelected = 24.f;
    self.titleSizeNormal = 16.f;
    self.titleColorNormal = [UIColor colorTextFor23272A];
    self.titleColorSelected = [UIColor colorTextFor23272A];
    self.titleFontName = @"PingFangSC-Regular";
    self.titleFontNameSelected = @"PingFangSC-Semibold";
    self.automaticallyCalculatesItemWidths = YES;
    self.itemMargin = 20;
    self.scrollEnable = YES;
//    self.menuItemWidth = 20;
    self.progressHeight = 3.5;
    self.progressWidth = 20;
//    self.view.backgroundColor = HexRGB(0xF7F6FB);
//    self.customNavBar.backgroundColor = HexRGB(0xF7F6FB);
    [self reloadData];
}

@end
