//
//  GotRpContentDialog.m

#import "GotRpContentDialog.h"

@interface GotRpContentDialog()
@property (nonatomic, weak) IBOutlet UILabel *desLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *detailBtn;
@property (nonatomic, weak) IBOutlet UIButton *gotBtn;

@property (nonatomic, strong) RedPacketInfo *rpInfo;
@end

@implementation GotRpContentDialog

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.detailBtn setButtonImageTitleStyle:ButtonImageTitleStyleRight padding:0];
}

- (void)initRp:(RedPacketInfo *)rp
{
    self.rpInfo = rp;
    
    self.desLabel.text = [NSString stringWithFormat:@"%@发出的红包".lv_localized, [UserInfo userDisplayName:rp.from]];
    switch ([rp getRpState]) {
        case RpState_Expire:
            //已过期
            self.gotBtn.hidden = YES;
            self.titleLabel.text = @"已过期\n红包已超过24小时".lv_localized;
            self.detailBtn.hidden = !(rp.users != nil && rp.users.count>0);
            break;
        case RpState_To_Get:
            //未领取，待抢
            self.gotBtn.hidden = NO;
            self.titleLabel.text = rp.title;
            if(self.rpInfo.from == [UserInfo shareInstance]._id)
            {//自己发的
                self.detailBtn.hidden = NO;
            }
            else
            {//他人发的
                self.detailBtn.hidden = YES;
            }
            break;
        case RpState_Got:
            //已领取
            self.gotBtn.hidden = YES;
            self.titleLabel.text = [NSString stringWithFormat:@"￥%@", [Common priceFormat:[rp curUserRp].price]];
            self.detailBtn.hidden = NO;
            break;
        case RpState_GotADone:
            //已领取并且被抢光
            self.gotBtn.hidden = YES;
            self.titleLabel.text = [NSString stringWithFormat:@"￥%@", [Common priceFormat:[rp curUserRp].price]];
            self.detailBtn.hidden = NO;
            break;
        case RpState_Done:
            //已被抢光
            self.gotBtn.hidden = YES;
            self.titleLabel.text = @"红包已领完\n很抱歉，你来晚了".lv_localized;
            self.detailBtn.hidden = NO;
            break;
        default:
            break;
    }
}

- (IBAction)click_detail:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(GotRpContentDialog_viewDetail:)])
    {
        [self.delegate GotRpContentDialog_viewDetail:self.rpInfo];
    }
}

- (IBAction)click_got:(id)sender
{
    [self half1Animations];
    [[TelegramManager shareInstance] gotRp:self.rpInfo.redPacketId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:[NSDictionary class]])
        {
            //400 不能领取自己的红包
            //401 没有权限领取该红包
            //402 红包被抢光了
            int code = [[obj objectForKey:@"code"] intValue];
            NSArray *list = [obj objectForKey:@"users"];
            if(code == 200)
            {
                self.rpInfo.users = list;
                if(self.delegate && [self.delegate respondsToSelector:@selector(GotRpContentDialog_viewDetail:)])
                {
                    [self.delegate GotRpContentDialog_viewDetail:self.rpInfo];
                }
            }
            else if(code == 402)
            {//红包被抢光了
                self.rpInfo.users = list;
                [self initRp:self.rpInfo];
            }
            else if(code == 400)
            {
                [self dismiss];
                [UserInfo showTips:nil des:@"不能领取自己的红包".lv_localized];
            }
            else if(code == 401)
            {
                [self dismiss];
                [UserInfo showTips:nil des:@"没有权限领取该红包".lv_localized];
            }
            else
            {
                [self dismiss];
                [UserInfo showTips:nil des:@"领取红包失败，请稍后重试".lv_localized];
            }
        }
        else
        {
            [self dismiss];
            [UserInfo showTips:nil des:@"领取红包失败，请稍后重试".lv_localized];
        }
    } timeout:^(NSDictionary *request) {
        [self dismiss];
        [UserInfo showTips:nil des:@"领取红包失败，请稍后重试".lv_localized];
    }];
}

- (void)dismiss
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(GotRpContentDialog_close)])
    {
        [self.delegate GotRpContentDialog_close];
    }
}

- (void)half1Animations
{
    if(!self.gotBtn.hidden)
    {
        [UIView animateWithDuration:0.5f animations:^{
            self.gotBtn.layer.transform = CATransform3DMakeRotation(M_PI, 0.0, 1.0, 0.0);
        } completion:^(BOOL finished) {
            [self half2Animations];
        }];
    }
}

- (void)half2Animations
{
    if(!self.gotBtn.hidden)
    {
        [UIView animateWithDuration:0.5f animations:^{
            self.gotBtn.layer.transform = CATransform3DMakeRotation(M_PI*2, 0.0, 1.0, 0.0);
        } completion:^(BOOL finished) {
            [self half1Animations];
        }];
    }
}

@end
