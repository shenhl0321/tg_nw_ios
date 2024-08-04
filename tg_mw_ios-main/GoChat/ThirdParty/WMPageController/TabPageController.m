//
//  TabPageController.m
//  LoganSmart
//
//  Created by 吴涛 on 2021/11/15.
//

#import "TabPageController.h"

@interface TabPageController ()<MNNavigationBarDelegate>

@end

@implementation TabPageController

-(instancetype)init{
    self = [super init];
    if (self) {
        [self style];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self style];
    [self reloadData];
}

-(void)style{
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
}

@end
