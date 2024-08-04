//
//  ChatUserControlCell.m
//  GoChat
//
//  Created by apple on 2021/12/22.
//

#import "ChatUserControlCell.h"

@interface ChatUserControlCell ()

/// 加为好友
@property (nonatomic,strong) UIButton *addContact;
/// 加入黑名单按钮
@property (nonatomic,strong) UIButton *addBlack;

@end

@implementation ChatUserControlCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    UIButton *addContact = [[UIButton alloc] init];
    self.addContact = addContact;
    [self.contentView addSubview:addContact];
    [addContact addTarget:self action:@selector(addContactClick:) forControlEvents:UIControlEventTouchUpInside];
    [addContact setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addContact setTitle:@"加为好友" forState:UIControlStateNormal];
    addContact.titleLabel.font = XHQFont(17);
    addContact.layer.cornerRadius = 17;
    addContact.clipsToBounds = YES;
    addContact.backgroundColor = XHQHexColor(0x0DBFC0);
    
    
    UIButton *addBlack = [[UIButton alloc] init];
    self.addBlack = addBlack;
    [self.contentView addSubview:addBlack];
    [addBlack addTarget:self action:@selector(addBlackClick:) forControlEvents:UIControlEventTouchUpInside];
    [addBlack setTitleColor:XHQHexColor(0xA9B0BF) forState:UIControlStateNormal];
    [addBlack setTitle:@"屏蔽此人" forState:UIControlStateNormal];
    addBlack.titleLabel.font = XHQFont(17);
    addBlack.layer.cornerRadius = 17;
    addBlack.clipsToBounds = YES;
    addBlack.layer.borderWidth = 1;
    addBlack.backgroundColor = [UIColor whiteColor];
    addBlack.layer.borderColor = XHQHexColor(0xA9B0BF).CGColor;
    
    UIView *bottomV = [[UIView alloc] init];
    [self.contentView addSubview:bottomV];
    bottomV.backgroundColor = XHQHexColor(0xdadada);
    [bottomV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(10);
    }];
    
    [addContact mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(25);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(50);
    }];
    
    [addBlack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.addContact.mas_bottom).offset(15);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(50);
        make.bottom.mas_equalTo(bottomV).offset(-25);
    }];
}

- (void)addContactClick:(UIButton *)btn{
    [self addFriendClick];
}

- (void)addBlackClick:(UIButton *)btn{
    [self addBlackListClick];
}



- (void)setChatInfo:(ChatInfo *)chatInfo{
    _chatInfo = chatInfo;
    if (chatInfo.is_blocked) {
        [self.addBlack setTitle:@"取消屏蔽" forState:UIControlStateNormal];
    } else {
        [self.addBlack setTitle:@"屏蔽此人" forState:UIControlStateNormal];
    }
}


//1V1 添加好友
- (void)addFriendClick{
    
    [self doAddContactRequestWithid:self.userInfo];
}

- (void)doAddContactRequestWithid:(UserInfo *)user
{
    [UserInfo show];
    MJWeakSelf
    [[TelegramManager shareInstance] addContact:user resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"添加好友失败，请稍后重试" errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            weakSelf.userInfo.is_contact = YES;
            if (weakSelf.callBack) {
                weakSelf.callBack(1);
            }
            [UserInfo showTips:nil des:[NSString stringWithFormat:@"[%@]已被添加到您的好友列表中", user.displayName]];
            [[TelegramManager shareInstance] sendBeFriendMessage:user._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
                
            } timeout:^(NSDictionary *request) {
            }];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"添加好友失败，请稍后重试"];
    }];
}

//加黑名
- (void)addBlackListClick{
    __block NSInteger tag = -1;
    MMPopupItemHandler block = ^(NSInteger index) {
        tag = index;
    };
    NSArray *items = @[MMItemMake(@"确定", MMItemTypeHighlight, block)];
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:self.chatInfo.is_blocked?@"确定从黑名单中移除吗？":@"确定加入黑名单吗？"
                                                          items:items];
    sheetView.hideCompletionBlock = ^(MMPopupView *pop, BOOL finish){
        if(tag == 0)
        {
            [self blockUser];
        }
        else
        {
            
        }
    };
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
}

- (void)blockUser
{
    [UserInfo show];
    MJWeakSelf
    [[TelegramManager shareInstance] blockUser:self.userInfo._id isBlock:!self.chatInfo.is_blocked resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"加入黑名单失败，请稍后重试" errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            //成功
//            weakSelf.chatInfo.is_blocked = !weakSelf.chatInfo.is_blocked;
            weakSelf.chatInfo = weakSelf.chatInfo;
            
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"加入黑名单失败，请稍后重试"];
    }];
}

@end
