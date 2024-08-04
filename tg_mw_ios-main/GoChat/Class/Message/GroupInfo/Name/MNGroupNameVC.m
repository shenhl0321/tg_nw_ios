//
//  MNGroupNameVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/25.
//

#import "MNGroupNameVC.h"

@interface MNGroupNameVC ()
@property (nonatomic, strong) UITextField *tf;
@property (nonatomic, copy) NSString *name;
@end

@implementation MNGroupNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:@"群名称".lv_localized];
    [self.customNavBar setRightBtnWithImageName:nil title:@"保存".lv_localized highlightedImageName:nil];
    [self.contentView addSubview:self.tf];
    [self.tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(56);
        make.top.mas_equalTo(19);
    }];
    self.name = self.chat.title;
    self.tf.text = [Util objToStr:self.name];
    
}

-(void)navigationBar:(MNNavigationBar *)navationBar didClickRightBtn:(UIButton *)btn{
    [self.view endEditing:YES];
    self.name = self.tf.text;
    if ([Util objToStr:self.name].length == 0) {
        [UserInfo showTips:nil des:@"请填写群组名称".lv_localized];
        return;
    }
    if ([self.name isEqualToString:self.chat.title]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self saveGroupName:self.name];
}

-(UITextField *)tf{
    if (!_tf) {
        _tf = [[UITextField alloc] init];
        [_tf mn_defalutStyle];
        _tf.placeholder = @"请输入群名称".lv_localized;
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor colorTextForE5EAF0];
        [_tf addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.height.mas_equalTo(0.5);
        }];
    }
    return _tf;
}


- (void)saveGroupName:(NSString *)name
{
    if(!IsStrEmpty(name))
    {
        [UserInfo show];
        [[TelegramManager shareInstance] setGroupName:self.chat._id groupName:name resultBlock:^(NSDictionary *request, NSDictionary *response) {
            [UserInfo dismiss];
            if([TelegramManager isResultError:response])
            {
                [UserInfo showTips:nil des:@"群组名称设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
            }
            else
            {
                [UserInfo showTips:nil des:@"群组名称设置成功".lv_localized];
                [self.navigationController popViewControllerAnimated:YES];
            }
        } timeout:^(NSDictionary *request) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"群组名称设置失败，请稍后重试".lv_localized];
        }];
    }
    else
    {
        [UserInfo showTips:nil des:@"请填写群组名称".lv_localized];
    }
}



@end
