//
//  GotWpPasswordContentDialog.m

#import "GotWpPasswordContentDialog.h"

@interface GotWpPasswordContentDialog()
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet CRBoxInputView *pswInputView;

//@property (nonatomic, strong) WalllletInfo *wtInfo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topwithtitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topwithprice;

@end

@implementation GotWpPasswordContentDialog

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.pswInputView.inputType = CRInputType_Number;
    self.pswInputView.ifNeedSecurity = YES;
    [self.pswInputView resetCodeLength:6 beginEdit:NO];
    [self.pswInputView loadAndPrepareViewWithBeginEdit:YES];
    self.pswInputView.textDidChangeblock = ^(NSString *text, BOOL isFinished) {
        if(isFinished)
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(GotWpPasswordContentDialog_withPassword:)])
            {
                [self.delegate GotWpPasswordContentDialog_withPassword:text];
            }
        }
    };
}

- (void)initWt:(id)wt payPrice:(float)payPrice
{
    if (payPrice < 0.001) {
        self.paymentTypeLabel.hidden = YES;
        self.priceLabel.hidden = YES;
        self.topwithprice.priority = UILayoutPriorityDefaultLow;
        self.topwithtitle.priority = UILayoutPriorityDefaultHigh;
    }else{
//        self.wtInfo = wt;
        self.paymentTypeLabel.hidden = NO;
        self.priceLabel.hidden = NO;
        self.topwithprice.priority = UILayoutPriorityDefaultHigh;
        self.topwithtitle.priority = UILayoutPriorityDefaultLow;
        [self priceAttributedUnit:@"￥" price:[Common priceFormat:payPrice] priceLabel:self.priceLabel];
    }
}

- (void)priceAttributedUnit:(NSString *)unitStr price:(NSString *)priceStr priceLabel:(UILabel *)priceLabel
{
    NSString *str = [NSString stringWithFormat:@"%@%@", unitStr, priceStr];
    NSMutableAttributedString *strAttr=[[NSMutableAttributedString alloc] initWithString:str];
    
    NSRange range_s = [str rangeOfString:priceStr];
    [strAttr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:36], NSForegroundColorAttributeName:HEX_COLOR(@"#333333")} range:range_s];
    
    NSRange range_u = [str rangeOfString:unitStr];
    [strAttr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:HEX_COLOR(@"#333333")} range:range_u];
    
    [priceLabel setAttributedText:strAttr];
}

@end
