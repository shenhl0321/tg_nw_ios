//
//  TimelineTopicVC.m
//  GoChat
//
//  Created by Autumn on 2022/3/4.
//

#import "TimelineTopicVC.h"
#import "TimelineListVC.h"

@interface TimelineTopicVC ()<JXCategoryViewDelegate, JXCategoryListContainerViewDelegate>

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *controllers;
@property (nonatomic, strong) JXCategoryTitleView *categoryView;
@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;

@property (nonatomic, copy) NSString *topic;

@end

@implementation TimelineTopicVC

- (instancetype)initWithTopic:(NSString *)topic {
    if (self = [super init]) {
        self.topic = topic;
    }
    return self;
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.categoryView.frame = CGRectMake(0, kNavigationStatusHeight(), APP_SCREEN_WIDTH, 60);
    CGFloat bottom = CGRectGetMaxY(self.categoryView.frame);
    self.listContainerView.frame = CGRectMake(0, bottom, self.view.bounds.size.width, self.view.bounds.size.height - bottom);
}


- (void)dy_initData {
    [super dy_initData];
    self.titles = @[@"推荐".lv_localized, @"最新".lv_localized, @"最热".lv_localized];
    TimelineListVC *hot = [[TimelineListVC alloc] init];
    hot.type = TimelineType_Topic_Recommend;
    hot.topic = self.topic;
    TimelineListVC *follow = [[TimelineListVC alloc] init];
    follow.type = TimelineType_Topic_Recently;
    follow.topic = self.topic;
    TimelineListVC *friend = [[TimelineListVC alloc] init];
    friend.type = TimelineType_Topic_Hot;
    friend.topic = self.topic;
    self.controllers = @[hot, follow, friend];
}

- (void)dy_initUI {
    [super dy_initUI];
    [self.customNavBar setTitle:self.topic];
    self.view.backgroundColor = UIColor.whiteColor;
    
    JXCategoryIndicatorLineView *indicator = [[JXCategoryIndicatorLineView alloc] init];
    indicator.indicatorColor = UIColor.colorMain;
    indicator.indicatorHeight = 3.5;
    indicator.verticalMargin = -2;
    self.categoryView.indicators = @[indicator];
    [self.view addSubview:self.categoryView];
    [self.view addSubview:self.listContainerView];
    
}


#pragma mark - JXCategoryListContainerViewDelegate

- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.titles.count;
}

- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    return self.controllers[index];
}


- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] init];
        _categoryView.delegate = self;
        _categoryView.listContainer = self.listContainerView;
        _categoryView.titles = self.titles;
        _categoryView.cellSpacing = 0;
        _categoryView.cellWidth = 180/3;
        _categoryView.titleColorGradientEnabled = YES;
        _categoryView.titleLabelZoomEnabled = YES;
        _categoryView.titleLabelStrokeWidthEnabled = YES;
        _categoryView.titleFont = [UIFont regularCustomFontOfSize:16];
        _categoryView.titleSelectedFont = [UIFont semiBoldCustomFontOfSize:24];
        //        _categoryView.titleLabelZoomScale = 1.5;
        _categoryView.titleColor = [UIColor colorTextFor23272A];
        _categoryView.titleSelectedColor = [UIColor colorTextFor23272A];
        _categoryView.titleLabelMaskEnabled = YES;
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

@end
