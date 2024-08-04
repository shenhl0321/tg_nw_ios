//
//  CZGroupInvitationViewController.m
//  GoChat      群邀请链接
//
//  Created by mac on 2021/7/9.
//

#import "CZGroupInvitationViewController.h"
#import "CZGroupInvitationTableViewCell.h"

@interface CZGroupInvitationViewController ()
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic,strong) NSMutableArray *souryArray;
@end

@implementation CZGroupInvitationViewController

- (NSMutableArray *)souryArray{
    if (!_souryArray) {
        _souryArray = [NSMutableArray array];
        NSString *invitationStr = self.super_groupFullInfo.invite_link;
        if (invitationStr && invitationStr.length > 5) {
            [_souryArray addObject:[CZGroupInvitatioModel getModelWithTips:invitationStr withFontSze:14]];
        }else{
            [_souryArray addObject:[CZGroupInvitatioModel getModelWithTips:@"请设置邀请链接".lv_localized withFontSze:14]];
        }
        [_souryArray addObject:[CZGroupInvitatioModel getModelWithTips:@"复制链接".lv_localized withFontSze:17]];
        if ([CZCommonTool isGroupManager:self.super_groupInfo]) {
            [_souryArray addObject:[CZGroupInvitatioModel getModelWithTips:@"重置链接".lv_localized withFontSze:17]];
        }
        [_souryArray addObject:[CZGroupInvitatioModel getModelWithTips:@"分享链接".lv_localized withFontSze:17]];
        if ([CZCommonTool isGroupManager:self.super_groupInfo]) {
            [_souryArray addObject:[CZGroupInvitatioModel getModelWithTips:@"关闭链接".lv_localized withFontSze:17]];
        }
    }
    return _souryArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"群邀请链接".lv_localized;
    // Do any additional setup after loading the view from its nib.
}


//设置TablerView显示几组数据，默认分一组；
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
//设置UITabView每组显示几行数据
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else{
        return self.souryArray.count - 1;
    }
}
//设置每一行的每一组显示单元格的什么内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger numberLin = indexPath.row+indexPath.section;
    CZGroupInvitatioModel *cellModel = [self.souryArray objectAtIndex:numberLin];
    static NSString *cellID = @"CZGroupInvitationTableViewCell";
     CZGroupInvitationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
     if (cell == nil) {
         cell = [[[NSBundle mainBundle] loadNibNamed:@"CZGroupInvitationTableViewCell" owner:nil options:nil] firstObject];
     }
    cell.cellModel = cellModel;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        headerView.backgroundColor = [UIColor colorWithRed:239/255.0 green:241/255.0 blue:240/255.0 alpha:1.0];
        UILabel *tipsLabel = [[UILabel alloc]init];
        NSString *tipsStr = [NSString stringWithFormat:@"用户在%@中打开此链接均可加入本群。你可以随时重置此链接".lv_localized,localAppName.lv_localized];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:tipsStr attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 11],NSForegroundColorAttributeName: [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]}];
        tipsLabel.attributedText = string;
        [tipsLabel sizeToFit];
        [headerView addSubview:tipsLabel];
        [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(headerView);
        }];
        return headerView;
    }else{
        return [UIView new];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 40;
    }else{
        return 0.01;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return FLT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if ([CZCommonTool isGroupManager:self.super_groupInfo]) {//有重置链接
            switch (indexPath.row) {
                case 0:
                {
                    //复制
                    NSString *invitationStr = self.super_groupFullInfo.invite_link;
                    if (invitationStr && invitationStr.length > 5) {
                        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                        pasteboard.string = invitationStr;
                        [UserInfo showTips:self.view des:@"复制链接成功".lv_localized];
                    }else{
                        [UserInfo showTips:self.view des:@"本群暂未设置邀请链接,请先设置链接".lv_localized];
                    }
                }
                    break;
                case 1:
                {
                    //重置
                    [self generateChatInviteLink];
                }
                    break;
                case 2:
                {
                    //邀请
                    [self inviteUrlToShare];
                }
                    break;
                case 3:
                {
                    //关闭
                    [self stopChatInviteLink];
                }
                    break;
                default:
                    break;
            }
        }else{//有重置链接
            switch (indexPath.row) {
                case 0:
                {
                    //复制
                    NSString *invitationStr = self.super_groupFullInfo.invite_link;
                    if (invitationStr && invitationStr.length > 5) {
                        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                        NSString *shareText = [NSString stringWithFormat:@"点击加入群聊【%@】%@".lv_localized,self.chatInfo.title,invitationStr];
                        pasteboard.string = shareText;
                        [UserInfo showTips:self.view des:@"复制链接成功".lv_localized];
                    }else{
                        [UserInfo showTips:self.view des:@"本群暂未设置邀请链接,请先设置链接".lv_localized];
                    }
                }
                    break;
                case 1:
                {
                    //邀请
                    [self inviteUrlToShare];
                }
                    break;
                default:
                    break;
            }
        }
    }
}


//重置邀请链接
- (void)generateChatInviteLink
{
    [UserInfo show];
    [[TelegramManager shareInstance] generateChatInviteLink:self.chatInfo._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"重置链接失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }else{//重置成功
            [UserInfo showTips:self.view des:@"重置链接成功".lv_localized];
            self.super_groupFullInfo.invite_link = [response objectForKey:@"invite_link"];
            self.souryArray = nil;
            [self.mainTableView reloadData];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"重置链接失败，请稍后重试".lv_localized];
    }];
}

//邀请
- (void)inviteUrlToShare
{
    NSString *invitationStr = self.super_groupFullInfo.invite_link;
    if (invitationStr && invitationStr.length > 5) {
        NSString *shareText = [NSString stringWithFormat:@"点击加入群聊【%@】".lv_localized,self.chatInfo.title];
        NSURL *shareUrl = [NSURL URLWithString:invitationStr];
        UIImage *shareImage = [UIImage imageNamed:@"Logo1"];
        NSArray *activityItemsArray = @[shareText, shareImage, shareUrl];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItemsArray applicationActivities:nil];
        [self presentViewController:activityViewController animated:YES completion:nil];
    }else{
        [UserInfo showTips:self.view des:@"本群暂未设置邀请链接,请先设置链接".lv_localized];
    }
}

//停用邀请链接
- (void)stopChatInviteLink
{
    [UserInfo show];
    [[TelegramManager shareInstance] stopGroupInviteLink:[ChatInfo toServerPeerId:self.chatInfo._id] resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"停用链接失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }else{//重置成功
            [UserInfo showTips:self.view des:@"停用链接成功".lv_localized];
            self.super_groupFullInfo.invite_link = @"";
            self.souryArray = nil;
            [self.mainTableView reloadData];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"停用链接失败，请稍后重试".lv_localized];
    }];
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
