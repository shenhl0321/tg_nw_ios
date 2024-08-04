//
//  MNPageController.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/4.
//

#import "MNPageController.h"

@interface MNPageController ()

@end

@implementation MNPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.menuView.backgroundColor = [UIColor whiteColor];
//    self.menuViewLayoutMode = WMMenuViewLayoutModeCenter;
    self.titleSizeSelected = 17.f;
    self.titleSizeNormal = 16.f;
    self.titleColorNormal = [UIColor colorTextForA9B0BF];
    self.titleColorSelected = [UIColor colorTextFor23272A];
    self.titleFontName = @"PingFangSC-Regular";
    self.titleFontNameSelected = @"PingFangSC-Semibold";
    self.progressColor = [UIColor colorMain];
//    self.titleFontName = @"Alibaba-PuHuiTi-R";
//    self.titleFontNameSelected = @"AlibabaPuHuiTi-Bold";
    self.menuViewStyle = WMMenuViewStyleLine;
//    self.menuView.style = WMMenuViewStyleLine;
//    self.menuView.lineColor = [UIColor colorForTextOrange];
    self.progressHeight = 2;
//    self.automaticallyCalculatesItemWidths = YES;
    self.itemMargin = 15;
//    self.scrollEnable = FALSE;
    self.view.backgroundColor = [UIColor clearColor];
    [self reloadData];
}



@end
