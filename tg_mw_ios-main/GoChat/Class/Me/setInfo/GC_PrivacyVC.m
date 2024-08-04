//
//  GC_PrivacyVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/14.
//

#import "GC_PrivacyVC.h"
#import "GC_MySetCell.h"
#import "GC_MySetSwitchCell.h"
#import "TF_CommonSettingCell.h"
#import "TF_RequestManager.h"
#import "CustomUserPrivacyRules.h"
#import "TF_BlogNotSeeUsersVC.h"


@interface GC_PrivacyVC ()<UITableViewDelegate,UITableViewDataSource, BusinessListenerProtocol>

@property (nonatomic, strong) UITableView *tableView;
/// 数据源
@property (nonatomic,strong) NSMutableArray *dataSource;
/// 分组标题
@property (nonatomic,strong) NSArray *sectionTitles;
/// 最后上线时间
@property (nonatomic,strong) TF_settingModel *lastOnLine;
/// 语音通话
@property (nonatomic,strong) TF_settingModel *voiceCall;
/// 电话号码
@property (nonatomic,strong) TF_settingModel *phoneNumber;
/// 群组
@property (nonatomic,strong) TF_settingModel *groupModel;
/// 消息
@property (nonatomic,strong) TF_settingModel *messageModel;
/// 手机号搜索模型
@property (nonatomic,strong) TF_settingModel *phoneFind;
/// 用户名搜索模型
@property (nonatomic,strong) TF_settingModel *nameFind;

/// 不让其他人看
@property (nonatomic,strong) TF_settingModel *otherSee;
/// 不看其他人
@property (nonatomic,strong) TF_settingModel *notSeeOther;
/// 时间范围
@property (nonatomic,strong) TF_settingModel *timeRangeModel;
/// 陌生人查看范围
@property (nonatomic,strong) TF_settingModel *numberRangeModel;

/// 三规则数组
@property (nonatomic,strong) NSMutableArray *threeRules;
/// 两规则数组
@property (nonatomic,strong) NSMutableArray *twoRules;
/// 规则选项
@property (nonatomic,strong) NSMutableDictionary *ruleDic;
/// 详细规则
@property (nonatomic,strong) NSDictionary *ruleDetails;
@end

@implementation GC_PrivacyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:@"隐私与权限".lv_localized];
    
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    //同步用户隐私设置
    [[TelegramManager shareInstance] updateUserPrivacySettingsByAllowFindingByPhoneNumber];
    
    NSArray *rules = self.ruleDic.allKeys;
    for (NSString *name in rules) {
        [TF_RequestManager getUserPrivacySettingWithRuleType:name resultBlock:nil timeout:nil];
    }
    [TF_RequestManager getUserPrivacySettingWithRuleType:@"userPrivacySettingAllowFindingByUsername" resultBlock:nil timeout:nil];
    [self initData];
    
    [self requestCustPrivacySetting];
    
    [self initUI];
    
    
//    , @"朋友圈权限"
    self.sectionTitles = @[@"隐私".lv_localized, @"找到我".lv_localized, @"朋友圈权限".lv_localized];
    
}

- (void)requestCustPrivacySetting{
    MJWeakSelf
    [TF_RequestManager getAllCustomPrivacySettingResultBlock:^(NSDictionary *request, NSDictionary *response, NSArray *list) {
        NSArray *arr = [CustomUserPrivacy mj_objectArrayWithKeyValuesArray:list];
        if (arr != nil && arr.count > 0) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key = 1"];
            NSArray *filterArray = [arr filteredArrayUsingPredicate:predicate];
            CustomUserPrivacy *model = filterArray.firstObject;
            weakSelf.otherSee.model = model.rules.firstObject;
            
            predicate = [NSPredicate predicateWithFormat:@"key = 2"];
            filterArray = [arr filteredArrayUsingPredicate:predicate];
            model = filterArray.firstObject;
            weakSelf.notSeeOther.model = model.rules.firstObject;
            
            predicate = [NSPredicate predicateWithFormat:@"key = 3"];
            filterArray = [arr filteredArrayUsingPredicate:predicate];
            model = filterArray.firstObject;
            weakSelf.timeRangeModel.model = model.rules.firstObject;
            weakSelf.timeRangeModel.tipValue = model.rules.firstObject.timeTip;
            
            predicate = [NSPredicate predicateWithFormat:@"key = 4"];
            filterArray = [arr filteredArrayUsingPredicate:predicate];
            model = filterArray.firstObject;
            weakSelf.numberRangeModel.model = model.rules.firstObject;
            weakSelf.numberRangeModel.tipValue = model.rules.firstObject.rangeTip;
            
            [weakSelf.tableView reloadData];
        }
        
        
        
    } timeout:^(NSDictionary *request) {
        
    }];
}

- (NSMutableDictionary *)ruleDic{
    if (!_ruleDic) {
        _ruleDic = [NSMutableDictionary dictionary];
        _ruleDic[@"userPrivacySettingShowStatus"] = self.threeRules;
        _ruleDic[@"userPrivacySettingAllowCalls"] = self.threeRules;
        _ruleDic[@"userPrivacySettingShowPhoneNumber"] = self.threeRules;
        _ruleDic[@"userPrivacySettingAllowChatInvites"] = self.threeRules;
        _ruleDic[@"userPrivacySettingAllowMessages"] = self.twoRules;
    }
    return _ruleDic;
}

- (NSMutableArray *)threeRules{
    if (!_threeRules) {
        _threeRules = [NSMutableArray array];
        [_threeRules addObject:@{@"title": @"所有人".lv_localized, @"ruleType":@"userPrivacySettingRuleAllowAll"}];
        [_threeRules addObject:@{@"title": @"联系人".lv_localized, @"ruleType":@"userPrivacySettingRuleAllowContacts"}];
        [_threeRules addObject:@{@"title": @"没有人".lv_localized, @"ruleType":@"userPrivacySettingRuleRestrictAll"}];
    }
    return _threeRules;
}

- (NSMutableArray *)twoRules{
    if (!_twoRules) {
        _twoRules = [NSMutableArray array];
        [_twoRules addObject:@{@"title": @"所有人".lv_localized, @"ruleType":@"userPrivacySettingRuleAllowAll"}];
        [_twoRules addObject:@{@"title": @"联系人".lv_localized, @"ruleType":@"userPrivacySettingRuleAllowContacts"}];
    }
    return _twoRules;
}

- (NSDictionary *)ruleDetails{
    if (!_ruleDetails) {
        _ruleDetails= @{@"userPrivacySettingRuleAllowAll" : @"所有人".lv_localized,
                        @"userPrivacySettingRuleAllowContacts" : @"联系人".lv_localized,
                        @"userPrivacySettingRuleRestrictAll" : @"没有人".lv_localized
        };
    }
    return _ruleDetails;
}

-(UITableView *)tableView{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT - kNavBarAndStatusBarHeight) style:UITableViewStyleGrouped];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        [_tableView registerClass:[TF_CommonSettingCell class] forCellReuseIdentifier:@"TF_CommonSettingCell"];
        [_tableView registerClass:[TF_SettingSectionHeaderV class] forHeaderFooterViewReuseIdentifier:@"TF_SettingSectionHeaderV"];
        
//        _tableView.canMove = NO;
        _tableView.rowHeight = 60;
        _tableView.backgroundColor = [UIColor colorForF5F9FA];
        
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
        
    }
    return _tableView;
}
    
- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:5];
    }
    return _dataSource;
}
    
- (void)initData{
    
    NSArray *datas = @[
                        @[@{@"title" : @"黑名单".lv_localized, @"target" : @"TF_BlockedUsersVC"},
                          @{@"title" : @"最后上线时间".lv_localized,
                            @"identityName" : @"userPrivacySettingShowStatus",
                            @"value" : [self getTipValue:@"userPrivacySettingShowStatus"],
                            @"vcModel": @"lastOnLine"},
                          @{@"title" : @"语音通话".lv_localized,
                            @"identityName" : @"userPrivacySettingAllowCalls",
                            @"value" : [self getTipValue:@"userPrivacySettingAllowCalls"],
                            @"vcModel": @"voiceCall"},
                          @{@"title" : @"电话号码".lv_localized,
                            @"identityName" : @"userPrivacySettingShowPhoneNumber",
                            @"value" : [self getTipValue:@"userPrivacySettingShowPhoneNumber"],
                            @"vcModel": @"phoneNumber"},
                          @{@"title" : @"群组".lv_localized,
                            @"identityName" : @"userPrivacySettingAllowChatInvites",
                            @"value" : [self getTipValue:@"userPrivacySettingAllowChatInvites"],
                            @"vcModel": @"groupModel"},
                          @{@"title" : @"消息".lv_localized,
                            @"identityName" : @"userPrivacySettingAllowMessages",
                            @"value" : [self getTipValue:@"userPrivacySettingAllowMessages"],
                            @"vcModel": @"messageModel"},
                        ],
                        @[
                          @{@"title" : @"用户名".lv_localized, @"type" : @"2", @"switchOn" : @([UserInfo shareInstance].isFindByUserName), @"vcModel": @"nameFind"},
                          @{@"title" : @"手机号".lv_localized, @"type" : @"2", @"switchOn" : @([UserInfo shareInstance].isFindByPhoneNumber), @"vcModel": @"phoneFind"}
                        ],
                        @[@{@"title" : @"不让谁看".lv_localized,
                            @"target" : @"TF_BlogNotSeeUsersVC",
                            @"identityName" : @"otherSee",
                            @"value" : @"",
                            @"vcModel": @"otherSee",
                            },
                          @{@"title" : @"不看谁".lv_localized,
                            @"target" : @"TF_BlogNotSeeUsersVC",
                            @"identityName" : @"notSeeOther",
                            @"value" : @"",
                            @"vcModel": @"notSeeOther",
                          },
                          @{@"title" : @"允许朋友查看范围".lv_localized,
                            @"target" : @"changeTimeRange",
                            @"value" : @"",
                            @"vcModel": @"timeRangeModel",
                          },
                          @{@"title" : @"陌生人允许查看范围".lv_localized,
                            @"target" : @"changeNumberRange",
                            @"value" : @"",
                            @"vcModel": @"numberRangeModel",
                          }]
                        ];
    
    [datas enumerateObjectsUsingBlock:^(NSArray *arr, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *mut = [NSMutableArray array];
        [arr enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
            TF_settingModel *model = [[TF_settingModel alloc] init];
            model.title = dic[@"title"];
            model.targetVC = dic[@"target"];
            model.tipValue = dic[@"value"];
            model.switchOn = [dic[@"switchOn"] boolValue];
            model.identityName = dic[@"identityName"];
            NSString *type = dic[@"type"];
            NSString *vcModelN = dic[@"vcModel"];
            if (type.intValue == 2) {
                model.tipType = TF_settingTipTypeSwith;
            } else {
                model.tipType = TF_settingTipTypeArrow;
            }
            if (!IsStrEmpty(vcModelN)) {
                [self setValue:model forKey:vcModelN];
            }
            [mut addObject:model];
        }];
        [self.dataSource addObject:mut];
    }];
}

- (void)initUI{

    [self.contentView addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];
    [self.tableView reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arr = self.dataSource[section];
    return arr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TF_CommonSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TF_CommonSettingCell" forIndexPath:indexPath];
    NSArray *arr = self.dataSource[indexPath.section];
    cell.model = arr[indexPath.row];
    MJWeakSelf
    cell.controlCall = ^(TF_settingModel * _Nonnull model) {
        if ([model.title isEqualToString:@"手机号".lv_localized]) {
            [weakSelf changePhoneFind:model];
        } else if ([model.title isEqualToString:@"用户名".lv_localized]){
            [weakSelf changeNameFind:model];
        }
    };
    return cell;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 55;
//}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    TF_SettingSectionHeaderV *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TF_SettingSectionHeaderV"];
    view.title = self.sectionTitles[section];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = self.dataSource[indexPath.section];
    TF_settingModel *model = arr[indexPath.row];
    NSString *targetName = model.targetVC;
    NSString *identityName = model.identityName;
    
    if ([targetName isEqualToString:@"TF_BlockedUsersVC"]) {
        Class cls = NSClassFromString(targetName);
        UIViewController *targetVC = [[cls alloc] init];
        [self.navigationController pushViewController:targetVC animated:YES];
        return;
    }
    if ([targetName isEqualToString:@"changeTimeRange"]) {
        [self showChangeRangePrivacy:1];
        return;
    }
    
    if ([targetName isEqualToString:@"changeNumberRange"]) {
        [self showChangeRangePrivacy:2];
        return;
    }
    if ([targetName isEqualToString:@"TF_BlogNotSeeUsersVC"]) {
        TF_BlogNotSeeUsersVC *targetVC = [[TF_BlogNotSeeUsersVC alloc] init];
        CustomUserPrivacyRules *model;
        
        if ([identityName isEqualToString:@"otherSee"]) {
            targetVC.type = 1;
            model = self.otherSee.model;
        } else {
            targetVC.type = 2;
            model = self.notSeeOther.model;
        }
        MJWeakSelf
        targetVC.userIds = model.users;
        targetVC.changeCall = ^{
            [weakSelf requestCustPrivacySetting];
        };
        
        [self.navigationController pushViewController:targetVC animated:YES];
        return;
    }
    
    if (!IsStrEmpty(identityName)) {
        
        [self showChangePrivacy:identityName];
        return;
    }
    if (IsStrEmpty(targetName)) {
        return;
    }
    Class cls = NSClassFromString(targetName);
    UIViewController *targetVC = [[cls alloc] init];
    [self.navigationController pushViewController:targetVC animated:YES];
    
}


- (void)dealloc
{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}

- (void)showChangeRangePrivacy:(NSInteger)type{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消".lv_localized
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];
    
    NSArray *arr, *nums;
    if (type == 1) {
        arr = @[@"最近3天".lv_localized, @"最近一个月".lv_localized, @"最近半年".lv_localized, @"最近一年".lv_localized];
        nums = @[@(3), @(30), @(180), @(365)];
    } else {
        arr = @[@"3条".lv_localized, @"10条".lv_localized, @"所有".lv_localized];
        nums = @[@(3), @(10), @(0)];
    }
    for (int i = 0; i < arr.count; i++) {
        NSString *title = arr[i];
        NSInteger index = [nums[i] integerValue];
        MJWeakSelf
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [UserInfo show];
            if (type == 1) {
                [TF_RequestManager setCustomPrivacyOfTimeRange:index resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                    [UserInfo dismiss];
                    if([TelegramManager isResultError:response])
                    {
                        [UserInfo showTips:nil des:@"设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
                    } else {
                        CustomUserPrivacyRules *rule = (CustomUserPrivacyRules *)weakSelf.timeRangeModel.model;
                        rule.days = index;
                        weakSelf.timeRangeModel.tipValue = rule.timeTip;
                    }
                    [weakSelf.tableView reloadData];
                } timeout:^(NSDictionary *request) {
                    [UserInfo dismiss];
                    [UserInfo showTips:nil des:@"设置失败，请稍后重试".lv_localized];
                    [weakSelf.tableView reloadData];
                }];
            } else {
                [TF_RequestManager setCustomPrivacyOfNumberRange:index resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                    [UserInfo dismiss];
                    if([TelegramManager isResultError:response])
                    {
                        [UserInfo showTips:nil des:@"设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
                    } else {
                        CustomUserPrivacyRules *rule = (CustomUserPrivacyRules *)weakSelf.numberRangeModel.model;
                        rule.counts = index;
                        weakSelf.numberRangeModel.tipValue = rule.rangeTip;
                    }
                    [weakSelf.tableView reloadData];
                } timeout:^(NSDictionary *request) {
                    [UserInfo dismiss];
                    [UserInfo showTips:nil des:@"设置失败，请稍后重试".lv_localized];
                    [weakSelf.tableView reloadData];
                }];
            }
        }];
        [alertController addAction:action];
    }
   
    
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)showChangePrivacy:(NSString *)type{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消".lv_localized
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];
    
    
    NSArray *arr = self.ruleDic[type];
    
    for (NSDictionary *dic in arr) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:dic[@"title"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self changeUserPrivacyRule:type setting:dic[@"ruleType"]];
        }];
        [alertController addAction:action];
    }
    
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)changeUserPrivacyRule:(NSString *)rule setting:(NSString *)setting{
    
    MJWeakSelf
    [UserInfo show];
    [TF_RequestManager changeUserPrivacySettingsRule:rule settingRule:setting resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        [UserInfo dismiss];
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"设置失败，请稍后重试".lv_localized];
        
        [weakSelf.tableView reloadData];
    }];
    
}

- (void)changeNameFind:(TF_settingModel *)model{
//    @"userPrivacySettingAllowFindingByUsername"  @"userPrivacySettingRuleAllowAll"   @"userPrivacySettingRuleAllowContacts"
    
    MJWeakSelf
    [UserInfo show];
    NSString *setting = @"";
    if ([UserInfo shareInstance].isFindByUserName) {
        setting = @"userPrivacySettingRuleAllowContacts";
    } else {
        setting = @"userPrivacySettingRuleAllowAll";
    }
    [TF_RequestManager changeUserPrivacySettingsRule:@"userPrivacySettingAllowFindingByUsername" settingRule:setting resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
            weakSelf.nameFind.switchOn = [UserInfo shareInstance].isFindByUserName;
        }
        
        [weakSelf.tableView reloadData];
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"设置失败，请稍后重试".lv_localized];
        weakSelf.nameFind.switchOn = [UserInfo shareInstance].isFindByUserName;
        [weakSelf.tableView reloadData];
    }];
}

- (void)changePhoneFind:(TF_settingModel *)model
{
    MJWeakSelf
    [UserInfo show];
    [[TelegramManager shareInstance] setUserPrivacySettingsByAllowFindingByPhoneNumber:![UserInfo shareInstance].isFindByPhoneNumber resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
            weakSelf.phoneFind.switchOn = [UserInfo shareInstance].isFindByPhoneNumber;
        }
        
        [weakSelf.tableView reloadData];
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"设置失败，请稍后重试".lv_localized];
        weakSelf.phoneFind.switchOn = [UserInfo shareInstance].isFindByPhoneNumber;
        [weakSelf.tableView reloadData];
    }];
}

- (NSString *)getTipValue:(NSString *)rule{
    NSString *tip = self.ruleDetails[[UserInfo shareInstance].privacyRules[rule]];
    if (!tip) {
        tip = @"所有人".lv_localized;
    }
    return tip;
}

#pragma mark BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_UpdateUserPrivacySettings):
            
            self.phoneFind.switchOn = [UserInfo shareInstance].isFindByPhoneNumber;
            self.nameFind.switchOn = [UserInfo shareInstance].isFindByUserName;
            self.lastOnLine.tipValue = [self getTipValue:@"userPrivacySettingShowStatus"];
            self.voiceCall.tipValue = [self getTipValue:@"userPrivacySettingAllowCalls"];
            self.phoneNumber.tipValue = [self getTipValue:@"userPrivacySettingShowPhoneNumber"];
            self.groupModel.tipValue = [self getTipValue:@"userPrivacySettingAllowChatInvites"];
            self.messageModel.tipValue = [self getTipValue:@"userPrivacySettingAllowMessages"];
            [self.tableView reloadData];
            break;
        default:
            break;
    }
}

@end
