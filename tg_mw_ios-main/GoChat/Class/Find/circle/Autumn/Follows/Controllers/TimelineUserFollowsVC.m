//
//  TimelineUserFollowsVC.m
//  GoChat
//
//  Created by Autumn on 2021/12/16.
//

#import "TimelineUserFollowsVC.h"
#import "TimelineUserFollowListVC.h"

@interface TimelineUserFollowsVC ()<JXCategoryViewDelegate, JXCategoryListContainerViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *controllers;
@property (nonatomic, strong) JXCategoryTitleView *categoryView;
@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;
@property (nonatomic, strong) UITextField *searchTextField;

@end

@implementation TimelineUserFollowsVC

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.searchTextField.frame = CGRectMake(15, kNavigationStatusHeight() + 5, kScreenWidth() - 30, 42);
    self.categoryView.frame = CGRectMake(0, CGRectGetMaxY(self.searchTextField.frame), kScreenWidth(), 50);
    self.listContainerView.frame = CGRectMake(0, CGRectGetMaxY(self.categoryView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.categoryView.frame));
}


- (void)dy_initData {
    [super dy_initData];
    self.titles = @[@"关注".lv_localized, @"粉丝".lv_localized];
    TimelineUserFollowListVC *followers = [[TimelineUserFollowListVC alloc] init];
    followers.type = TimelineUserFollowType_Follows;
    followers.userid = self.userid;
    TimelineUserFollowListVC *fans = [[TimelineUserFollowListVC alloc] init];
    fans.type = TimelineUserFollowType_Fans;
    fans.userid = self.userid;
    self.controllers = @[followers, fans];
}

- (void)dy_initUI {
    [super dy_initUI];
    
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.searchTextField];
    JXCategoryIndicatorLineView *indicator = [[JXCategoryIndicatorLineView alloc] init];
    indicator.indicatorColor = [UIColor colorMain];
    indicator.indicatorWidthIncrement = -20;
    self.categoryView.indicators = @[indicator];
    [self.view addSubview:self.categoryView];
    [self.view addSubview:self.listContainerView];
    [self setNavigationItemTitleWithIndex:self.selectIndex];
}

- (void)setNavigationItemTitleWithIndex:(NSInteger)index {
    if (index == 1) {
        [self.customNavBar setTitle:UserInfo.shareInstance._id == self.userid ? @"我的粉丝".lv_localized : @"他的粉丝".lv_localized];
    } else {
        [self.customNavBar setTitle: UserInfo.shareInstance._id == self.userid ? @"我的关注".lv_localized : @"他的关注".lv_localized];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textContentChanged:(UITextField *)textField {
    for (TimelineUserFollowListVC *list in self.controllers) {
        list.keyword = textField.text;
    }
}

#pragma mark - JXCategoryListContainerViewDelegate

- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.titles.count;
}

- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    return self.controllers[index];
}

#pragma mark - JXCategoryViewDelegate
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    [self setNavigationItemTitleWithIndex:index];
}

#pragma mark - getter
- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] init];
        _categoryView.delegate = self;
        _categoryView.listContainer = self.listContainerView;
        _categoryView.titles = self.titles;
        _categoryView.cellSpacing = 0;
        _categoryView.backgroundColor = UIColor.whiteColor;
        _categoryView.cellWidth = kScreenWidth() / 2;
        _categoryView.titleFont = [UIFont systemFontOfSize:16];
        _categoryView.titleColor = XHQHexColor(0xA9B0BF);
        _categoryView.titleSelectedFont = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        _categoryView.titleSelectedColor = XHQHexColor(0x23272A);
        _categoryView.defaultSelectedIndex = self.selectIndex;
    }
    return _categoryView;
}

// 列表容器视图
- (JXCategoryListContainerView *)listContainerView {
    if (!_listContainerView) {
        _listContainerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_ScrollView delegate:self];
    }
    return _listContainerView;
}

- (UITextField *)searchTextField {
    if (!_searchTextField) {
        _searchTextField = ({
            UITextField *view = UITextField.new;
            view.placeholder = @"搜索用户".lv_localized;
            view.backgroundColor = [UIColor colorForF5F9FA];
            view.delegate = self;
            [view addTarget:self action:@selector(textContentChanged:) forControlEvents:UIControlEventEditingChanged];
            view.layer.masksToBounds = YES;
            view.layer.cornerRadius = 13;
            UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 42)];
            UIImageView * imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_search"]];
            imageV.frame = CGRectMake(15, 13.5, 15, 15);
            [leftView addSubview:imageV];
            view.leftView = leftView;
            view.leftViewMode = UITextFieldViewModeAlways;
            view.clearButtonMode = UITextFieldViewModeAlways;
            view;
        });
    }
    return _searchTextField;
}

@end
