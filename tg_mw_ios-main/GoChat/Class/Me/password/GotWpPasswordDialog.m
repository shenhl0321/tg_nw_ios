//
//  GotWpPasswordDialog.m

#import "GotWpPasswordDialog.h"
#import "GotWpPasswordContentDialog.h"

@interface GotWpPasswordDialog()<GotWpPasswordContentDialogDelegate>
@end

@implementation GotWpPasswordDialog

- (instancetype)initDialog:(id)wt payPrice:(float)payPrice paymentType:(PAYMENT_TYPE)type
{
    self = [super init];
    if (self)
    {
        self.type = MMPopupTypeAlert;
        self.backgroundColor = [UIColor clearColor];
        [MMPopupWindow sharedWindow].touchWildToHide = NO;
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.height.mas_equalTo(425);
        }];
        
        GotWpPasswordContentDialog *contentView = [[[UINib nibWithNibName:@"GotWpPasswordContentDialog" bundle:nil] instantiateWithOwner:self options:nil] firstObject];
        [self addSubview:contentView];
        switch (type)
        {
            case PAYMENT_TYPE_RED_PACKET:
                contentView.paymentTypeLabel.text = @"现金红包".lv_localized;
                break;
            case PAYMENT_TYPE_TIXIAN:
                contentView.paymentTypeLabel.text = @"现金提取".lv_localized;
                break;
            case PAYMENT_TYPE_GROUP_RED_PACKET:
                 contentView.paymentTypeLabel.text = @"现金红包".lv_localized;
                 break;
            default:
                contentView.paymentTypeLabel.text = @"";
                break;
        }
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self);
        }];
        [contentView.closeBtn addTarget:self action:@selector(close_click) forControlEvents:UIControlEventTouchUpInside];
        [contentView initWt:wt payPrice:payPrice];
        contentView.delegate = self;
    }
    return self;
}

- (void)close_click
{
    [self hide];
}

- (void)GotWpPasswordContentDialog_withPassword:(NSString *)password
{
    __weak typeof(self) weakSelf = self;
    self.hideCompletionBlock = ^(MMPopupView *pop, BOOL finish){
        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(GotWpPasswordDialog_withPassword:)])
        {
            [weakSelf.delegate GotWpPasswordDialog_withPassword:password];
        }
    };
    [self hide];
}

@end
