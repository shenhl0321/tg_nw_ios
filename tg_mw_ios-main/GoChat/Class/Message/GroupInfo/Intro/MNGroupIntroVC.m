//
//  MNGroupIntroVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/25.
//

#import "MNGroupIntroVC.h"
#import "MNGroupInfoTvCell.h"

@interface MNGroupIntroVC ()
@property (nonatomic, strong) NSMutableArray *rows;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UIButton *publishBtn;
@property (nonatomic, strong) UITextView *tv;

@end

@implementation MNGroupIntroVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:@"群简介".lv_localized];
    if (self.canEdit) {
        self.deleteBtn = [self.customNavBar setRightBtnWithImageName:nil title:@"删除".lv_localized highlightedImageName:nil];
        [self.deleteBtn setTitleColor:[UIColor colorTextForFD4E57] forState:UIControlStateNormal];
        [self.contentView addSubview:self.publishBtn];
        [self.publishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(55);
            make.left.mas_equalTo(30);
            make.bottom.mas_equalTo(-50);
            make.centerX.mas_equalTo(0);
        }];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, -105, 0));
        }];
    }else{
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    }
   
    [self initTableData];
    [self.tableView reloadData];
}
-(void)navigationBar:(MNNavigationBar *)navationBar didClickRightBtn:(UIButton *)btn{
    [self.view endEditing:YES];
    [self handleWithStr:@"" delete:YES];
}

- (void)initTableData{
    _rows = [[NSMutableArray alloc] init];
    [_rows addObject:@"content"];
}

- (void)publishAction{
    //发布的命令
    [self.view endEditing:YES];
    if (self.tv.text.length == 0) {
        [UserInfo showTips:nil des:@"请填写群介绍".lv_localized];
        return;
    }
    [self handleWithStr:self.tv.text delete:NO];
    
}

- (void)handleWithStr:(NSString *)str delete:(BOOL)delete{
    
    NSString *handleStr = @"设置".lv_localized;
    if (delete) {
        handleStr = @"删除".lv_localized;
    }
    WS(weakSelf)
    [[TelegramManager shareInstance] setChatDescription:self.chat._id description:str resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if([TelegramManager isResultError:response])
        {
            
            [UserInfo dismiss];
            [UserInfo showTips:nil des:[NSString stringWithFormat:@"群简介%@失败，请稍后重试".lv_localized,handleStr]];
        }else{
            [UserInfo dismiss];
            [UserInfo showTips:nil des:[NSString stringWithFormat:@"群简介%@成功".lv_localized,handleStr]];
            if (delete) {
                weakSelf.tv.text = @"";
            }
        }
        
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:[NSString stringWithFormat:@"群简介%@失败，请稍后重试".lv_localized,handleStr]];
    }];
}

-(UIButton *)publishBtn{
    if (!_publishBtn) {
        _publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_publishBtn setTitle:@"发布群简介".lv_localized forState:UIControlStateNormal];
        [_publishBtn mn_loginStyle];
        [_publishBtn addTarget:self action:@selector(publishAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _publishBtn;
}

#pragma mark - tableview代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.rows.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSString *rowName = self.rows[indexPath.row];
    return 200;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 17.5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *rowName = self.rows[indexPath.row];
    
    if ([rowName isEqualToString:@"content"]) {
        static NSString *cellId = @"MNGroupInfoTvCell";
        MNGroupInfoTvCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[MNGroupInfoTvCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            _tv = cell.tv;
        }
        if (self.canEdit) {
            [cell fillDataWithText:@"" placeholder:@"请编辑群简介".lv_localized];
        }else{
            [cell fillDataWithText:@"" placeholder:@"未设置".lv_localized];
        }
        
        cell.tv.text = self.originValue;
        return cell;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
}




@end
