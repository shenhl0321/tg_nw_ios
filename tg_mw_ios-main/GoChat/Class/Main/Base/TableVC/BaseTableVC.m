//
//  BaseTableVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/21.
//

#import "BaseTableVC.h"

@interface BaseTableVC ()

@end

@implementation BaseTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTableView];
    
    // Do any additional setup after loading the view.
}

- (void)addTableView{
    [self.contentView addSubview:self.tableView];
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT - APP_NAV_BAR_HEIGHT-APP_STATUS_BAR_HEIGHT - kBottom34()) style:self.style];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 32, 0);
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _tableView.canMove = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        if (@available(iOS 15.0, *)) {

            self.tableView.sectionHeaderTopPadding = 0;


         }
        _tableView.sectionIndexColor = [UIColor clearColor];
//        _tableView.sectionIndexColor = [UIColor colorTextForA9B0BF];
//        _tableView
        
    }
    return _tableView;
}

- (void)createHeaderRefresh{
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                refreshingAction:@selector(initDataWithCache:)];
}

- (void)initDataWithCache:(BOOL)cache{
    
}

- (void)initDataWithCache:(BOOL)cache errorTip:(BOOL)tip {
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

//-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 56;
//}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}


-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section

{
    return 0.01f;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView  new];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    CGFloat height = [self ms_tableView:tableView heightForRowAtIndexPath:indexPath];
//    NSInteger rows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
//    MGTableCellLocation location = [CornerShadowUtil cellLocationWithIndexPath:indexPath numberOfRowInSection:rows];
//    CGFloat otherHeight = [CornerShadowUtil otherHeightForCellWithLocation:(location)];
//    return height+otherHeight;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger rows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
//
//    if ([cell isKindOfClass:NSClassFromString(@"BaseTableCell")]) {
////        [(BaseTableCell *)cell refreshUIWithSectionCount:rows row:indexPath.row];
//        [(BaseTableCell *)cell setNeedLine:YES];
//    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"BaseTableCellId";
    BaseTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[BaseTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(UITableViewStyle)style{
    return UITableViewStyleGrouped;
}

@end
