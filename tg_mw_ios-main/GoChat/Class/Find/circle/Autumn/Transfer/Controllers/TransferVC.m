//
//  TransferVC.m
//  GoChat
//
//  Created by Autumn on 2022/1/18.
//

#import "TransferVC.h"

#import "TransferNoteCell.h"
#import "TransferUserCell.h"
#import "TransferMoneyCell.h"

#import "GotWpPasswordDialog.h"
#import "IQKeyboardManager.h"
#import "TransferHelper.h"

@interface TransferVC ()<GotWpPasswordDialogDelegate>


@property (nonatomic, strong) TransferObject *obj;

@property (nonatomic, strong) UIButton *transferButton;

@end

@implementation TransferVC

- (instancetype)initWithChatId:(NSInteger)chatId userid:(NSInteger)userid type:(TransferChatType)type {
    self = [super init];
    if (self) {
        self.obj = TransferObject.new;
        self.obj.chatId = chatId;
        self.obj.userid = userid;
        self.obj.chatType = type;
    }
    return self;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.transferButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-20);
        make.bottom.mas_equalTo(-kHomeIndicatorHeight() - 40);
        make.size.mas_equalTo(CGSizeMake(85, 60));
    }];
}


- (void)dy_initData {
    [super dy_initData];
    
    TransferUserCellItem *uItem = TransferUserCellItem.item;
    uItem.cellModel = self.obj;
    [self.sectionArray0 addObject:uItem];
    
    TransferMoneyCellItem *mItem = TransferMoneyCellItem.item;
    mItem.cellModel = self.obj;
    [self.sectionArray0 addObject:mItem];
    [self.dataArray addObject:self.sectionArray0];
    
    TransferNoteCellItem *nItem = TransferNoteCellItem.item;
    nItem.cellModel = self.obj;
    [self.sectionArray1 addObject:nItem];
    [self.dataArray addObject:self.sectionArray1];
    
    IQKeyboardManager.sharedManager.shouldResignOnTouchOutside = YES;
}

- (void)dy_initUI {
    [super dy_initUI];
    
    [self.tableView xhq_registerCell:TransferUserCell.class];
    [self.tableView xhq_registerCell:TransferNoteCell.class];
    [self.tableView xhq_registerCell:TransferMoneyCell.class];
    [self.view addSubview:self.transferButton];
}

- (void)transferAction {
    if (self.obj.amount <= 0) {
        [UserInfo showTips:nil des:@"请输入转账金额".lv_localized];
        return;
    }
    [self.view endEditing:YES];
    GotWpPasswordDialog *pwd = [[GotWpPasswordDialog alloc] initDialog:nil
                                                              payPrice:self.obj.amount
                                                           paymentType:PAYMENT_TYPE_OTHER];
    pwd.delegate = self;
    [pwd show];
}

- (void)transfer {
    [UserInfo show];
    @weakify(self);
    [TransferHelper transfer:self.obj.jsonObject completion:^(BOOL isSuccess, NSString * _Nullable error, NSInteger errorCode) {
        @strongify(self);
        [UserInfo dismiss];
        if (error) {
            [UserInfo showTips:nil des:error];
            return;
        }
        if (isSuccess) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        if (errorCode > 0) {
            [self errorOperationWithCode:errorCode];
        }
    }];
}

- (void)errorOperationWithCode:(NSInteger)code {
    if(400 == code)
    {
        [UserInfo showTips:nil des:@"钱包余额不足，请前往余额中心充值".lv_localized];
    }
    else if(401 == code)
    {
        [UserInfo showTips:nil des:@"转账金额少于0.01元".lv_localized];
    }
    else if(402 == code)
    {
        [UserInfo showTips:nil des:@"转账金额超出限制".lv_localized];
    }
    else if(403 == code)
    {
//        [UserInfo showTips:nil des:@""];
    }
    else if(404 == code)
    {
        [self tipPaymentInvalidDialog];
    }
    else if(501 == code)
    {
        [UserInfo showTips:nil des:@"对方把你加入了黑名单，不能进行转账".lv_localized];
    }
    else
    {
        [UserInfo showTips:nil des:@"转账创建失败，请稍后再试".lv_localized];
    }
}

- (void)tipPaymentInvalidDialog {
    MMPopupItemHandler block = ^(NSInteger index) {
        if (index == 0) {
            [self transferAction];
        }
    };
    NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block),
                       MMItemMake(@"取消".lv_localized, MMItemTypeNormal, block)];
    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示" detail:@"支付密码错误，重新输入？".lv_localized items:items];
    [view show];
}

#pragma mark - GotWpPasswordDialogDelegate
- (void)GotWpPasswordDialog_withPassword:(NSString *)password {
    self.obj.password = [Common md5:password];
    [self transfer];
}

- (void)dy_cellResponse:(__kindof DYTableViewCellItem *)item indexPath:(NSIndexPath *)indexPath {
    if ([item isKindOfClass:TransferMoneyCellItem.class]) {
        [self transferAction];
    }
}

#pragma mark - getter
- (UIButton *)transferButton {
    if (!_transferButton) {
        _transferButton = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:@"转账".lv_localized forState:UIControlStateNormal];
            [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            btn.backgroundColor = UIColor.colorMain;
            btn.titleLabel.font = [UIFont semiBoldCustomFontOfSize:20];
            [btn xhq_addTarget:self action:@selector(transferAction)];
            [btn xhq_cornerRadius:5];
            btn;
        });
    }
    return _transferButton;
}

@end
