//
//  MNSensitiveWordsVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/27.
//

#import "MNSensitiveWordsVC.h"
#import "MNGroupInfoTvCell.h"

@interface MNSensitiveWordsVC ()

@property (nonatomic, strong) NSMutableArray *rows;
@property (nonatomic, copy) NSString *prevValueString;
@property (nonatomic,strong) NSArray *keysWords;
@property (nonatomic, strong) UITextView *inputText;

@end

@implementation MNSensitiveWordsVC

- (void)dealloc
{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:@"设置屏蔽敏感词".lv_localized];
    [self.customNavBar setRightBtnWithImageName:nil title:@"保存".lv_localized highlightedImageName:nil];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self initTableData];
    [self.tableView reloadData];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    [self queryGroupShieldWordsWithchtid];
}

-(void)navigationBar:(MNNavigationBar *)navationBar didClickRightBtn:(UIButton *)btn{
    [self.view endEditing:YES];
    [self click_ok];
}
- (void)setKeysWords:(NSArray *)keysWords{
    if (keysWords) {
        _keysWords = keysWords;
        //UI
        self.inputText.text = [keysWords componentsJoinedByString:@","];
    }
}

- (void)click_ok
{
    NSString *keyword = self.inputText.text;
    keyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    keyword = [keyword stringByReplacingOccurrencesOfString:@"，" withString:@","];
    keyword = [keyword stringByReplacingOccurrencesOfString:@"。" withString:@","];
    keyword = [keyword stringByReplacingOccurrencesOfString:@"、" withString:@","];
    [self settingGroupShieldWords:keyword];
}

//查询
- (void)queryGroupShieldWordsWithchtid{
    [UserInfo show];
    [[TelegramManager shareInstance] queryGroupShieldWordsWithchtid:[ChatInfo toServerPeerId:self.chat._id] resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response]){
            //获取数据失败
        }else{
            NSArray *keys = [response objectForKey:@"data"];
            self.keysWords = keys;
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
    }];
}

//设置
- (void)settingGroupShieldWords:(NSString *)keywords{
    NSMutableArray *keys = [[keywords componentsSeparatedByString:@","] mutableCopy];
    for (NSString *itemstr in [keys copy]) {
        if (itemstr.length < 1) {
            [keys removeObject:itemstr];
        }
    }
    //发起请求
    [UserInfo show];
    [[TelegramManager shareInstance] settingGroupShieldWords:keys withchtid:[ChatInfo toServerPeerId:self.chat._id] resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response]){
            [UserInfo showTips:nil des:@"敏感词设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }else{
            [UserInfo showTips:nil des:@"敏感词设置成功".lv_localized];
            [self.navigationController popViewControllerAnimated:YES];
        //成功  等待状态更新
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"敏感词设置失败，请稍后重试".lv_localized];
    }];
}

#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        
        case MakeID(EUserManager, EUser_Keys_Change):
        {
            NSArray *keys = inParam;
            if (keys) {
                self.keysWords = keys;
                [self.tableView reloadData];
            }
        }
            break;
        default:
            break;
    }
}
- (void)initTableData{
    _rows = [[NSMutableArray alloc] init];
    [_rows addObject:@"content"];
}

- (void)publishAction{
    //发布的命令
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
            self.inputText = cell.tv;
        }
        [cell fillDataWithText:@"" placeholder:@"填写需要屏蔽的敏感词,多个词用逗号分开".lv_localized];
        
        return cell;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
}


@end
