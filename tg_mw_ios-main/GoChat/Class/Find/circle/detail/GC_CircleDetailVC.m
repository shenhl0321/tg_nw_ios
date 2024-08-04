//
//  GC_CircleDetailVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/15.
//

#import "GC_CircleDetailVC.h"
#import "GC_CircleListCell.h"
#import "GC_CommentFooterView.h"
#import "GC_CircleCommentMenuCell.h"
#import "GC_CircleCommentSubCell.h"
#import "GC_CircleCommentCell.h"

@interface GC_CircleDetailVC ()

@property (nonatomic, strong)NSMutableArray *dataArr;

@end

@implementation GC_CircleDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view.
}
- (NSMutableArray *)dataArr{
    if(!_dataArr){
        _dataArr = @[@{@"subArr":@[@"",@"",@"",@""],@"isShow":@(0)}].mutableCopy;
    }
    return _dataArr;
}

- (void)initUI{
    [self.customNavBar setTitle:@"动态详情".lv_localized];
  
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[GC_CircleListCell class] forCellReuseIdentifier:@"GC_CircleListCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_CircleCommentMenuCell" bundle:nil] forCellReuseIdentifier:@"GC_CircleCommentMenuCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_CircleCommentSubCell" bundle:nil] forCellReuseIdentifier:@"GC_CircleCommentSubCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_CircleCommentCell" bundle:nil] forCellReuseIdentifier:@"GC_CircleCommentCell"];
    
   
    self.tableView.backgroundColor = [UIColor colorForF5F9FA];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(kNavBarAndStatusBarHeight);
        make.bottom.mas_equalTo(0);
    }];
    self.view.backgroundColor = self.tableView.backgroundColor;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2 + self.dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        return 0;
    }
    NSDictionary *dataDic = self.dataArr[section - 2];
    NSArray *subArr = [dataDic arrayValueForKey:@"subArr" defaultValue:@[]];
    BOOL isShow = [dataDic intValueForKey:@"isShow" defaultValue:0] == 1 ? YES : NO;
    
    if (isShow) {
        return 2 + subArr.count;
    }
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        GC_CircleListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_CircleListCell"];
        cell.desLab.numberOfLines = 0;
        cell.desLab.text = @"总以为生活欠我们一个满意，其实是我们欠生活一个努力你还年轻，别凑活过。没事早点睡，有空多挣钱, 别每天瞎想".lv_localized;
//        cell.deleteBtn.hidden = NO;
        cell.timeLab.hidden = YES;
        return cell;
    }
    NSDictionary *dataDic = self.dataArr[indexPath.section - 2];
    NSArray *subArr = [dataDic arrayValueForKey:@"subArr" defaultValue:@[]];
    BOOL isShow = [dataDic intValueForKey:@"isShow" defaultValue:0] == 1 ? YES : NO;;
    
    if (indexPath.row == 0) {
        GC_CircleCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_CircleCommentCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }{
        if (!isShow) {
            GC_CircleCommentMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_CircleCommentMenuCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.imageV.image = [UIImage imageNamed:@"icon_circle_down"];
            cell.desLab.text = [NSString stringWithFormat:@"- 展开%ld条回复 -".lv_localized,subArr.count];
            return cell;
            
        }else{
            if (indexPath.row == subArr.count + 1) {
                GC_CircleCommentMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_CircleCommentMenuCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.imageV.image = [UIImage imageNamed:@"icon_circle_up"];
                cell.desLab.text = @"- 收起回复 -".lv_localized;
                return cell;
            }
            GC_CircleCommentSubCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_CircleCommentSubCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 480;
    }
    if (indexPath.section == 1) {
        return 0;
    }
    
    
    NSDictionary *dataDic = self.dataArr[indexPath.section - 2];
    NSArray *subArr = [dataDic arrayValueForKey:@"subArr" defaultValue:@[]];
    BOOL isShow = [dataDic intValueForKey:@"isShow" defaultValue:0] == 1 ? YES : NO;;
    
    if ((!isShow && indexPath.row == 1) || (isShow && indexPath.row == subArr.count + 1)) {
        return 70;
    }
    
    return 80;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if (section == 1) {
//        return 60;
//    }
//    return 0;
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 0;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    GC_CommentFooterView *view = [[GC_CommentFooterView alloc] init];
//    view.backgroundColor = [UIColor whiteColor];
//    return view;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section >= 2) {
        NSDictionary *dataDic = self.dataArr[indexPath.section - 2];
        NSArray *subArr = [dataDic arrayValueForKey:@"subArr" defaultValue:@[]];
        NSInteger isShow = [dataDic intValueForKey:@"isShow" defaultValue:0];
        
        
        if (isShow == 1) {
            if (indexPath.row == subArr.count + 1) {
                isShow = 0;
                NSMutableDictionary *dic = dataDic.mutableCopy;
                [dic setValue:@(isShow) forKey:@"isShow"];
                [self.dataArr replaceObjectAtIndex:indexPath.section - 2 withObject:dic];
                
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:indexPath.section];
                [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }else{
            if (indexPath.row == 1) {
                isShow = 1;
                NSMutableDictionary *dic = dataDic.mutableCopy;
                [dic setValue:@(isShow) forKey:@"isShow"];
                [self.dataArr replaceObjectAtIndex:indexPath.section - 2 withObject:dic];
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:indexPath.section];
                [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
        
        
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
