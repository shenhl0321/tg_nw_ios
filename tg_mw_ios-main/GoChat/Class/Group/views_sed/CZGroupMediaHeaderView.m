//
//  CZGroupMediaHeaderView.m
//  GoChat
//
//  Created by mac on 2021/7/24.
//

#import "CZGroupMediaHeaderView.h"

@interface CZGroupMediaHeaderView ()
@property (weak, nonatomic) IBOutlet UIButton *firstBtn;
@property (weak, nonatomic) IBOutlet UIButton *secondBtn;
@property (weak, nonatomic) IBOutlet UIButton *thirdBtn;
@property (weak, nonatomic) IBOutlet UIButton *fourBtn;
@property (weak, nonatomic) IBOutlet UIButton *fiveBtn;
@property (weak, nonatomic) IBOutlet UIButton *sixBtn;

@property (weak, nonatomic) IBOutlet UIView *bottomLine;
@end

@implementation CZGroupMediaHeaderView

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"CZGroupMediaHeaderView" owner:self options:nil]lastObject];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(52);
            make.height.mas_equalTo(2);
            make.bottom.equalTo(self.mas_bottom);
            make.centerX.equalTo([self getBtnWithTag:100]);
        }];
    }
    if(!ShowLocal_VoiceRecord){
        self.secondBtn.hidden = YES;
        self.thirdBtn.hidden = YES;
        self.fourBtn.hidden = YES;
        self.fiveBtn.hidden = YES;
        self.sixBtn.hidden = YES;
    }
    return self;
}

- (UIButton *)getBtnWithTag:(NSInteger)tag{
    for (UIView *itemView in self.subviews) {
        if (itemView.tag == tag) {
            return (UIButton *)itemView;
        }
    }
    return nil;
}

- (IBAction)funcationBtnClick:(UIButton *)sender {
    for (int i = 100; i<106; i++) {
        UIButton *btn = [self getBtnWithTag:i];
        btn.selected = NO;
    }
    sender.selected = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(52);
            make.height.mas_equalTo(2);
            make.bottom.equalTo(self.mas_bottom);
            make.centerX.equalTo(sender);
        }];
    }];
    
    if (_delegate && [_delegate respondsToSelector:@selector(sectionHeaderViewClickWithTag:)]) {
        [_delegate sectionHeaderViewClickWithTag:sender.tag];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib{
    [super awakeFromNib];
    NSArray *arr = @[@"成员".lv_localized,@"媒体".lv_localized,@"文件".lv_localized,@"语音".lv_localized,@"链接".lv_localized,@"GIF".lv_localized];
    NSArray *btnArr = @[self.firstBtn,self.secondBtn,self.thirdBtn,self.fourBtn,self.fiveBtn,self.sixBtn];
    for (int i = 0; i < arr.count; i++) {
        NSString *title = arr[i];
        UIButton *btn = btnArr[i];
        NSRange range = NSMakeRange(0, title.length);
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:title];
        [attStr addAttribute:NSFontAttributeName value:fontRegular(15) range:range];
        [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorTextForA9B0BF] range:range];
        NSMutableAttributedString *attStrSel = [[NSMutableAttributedString alloc] initWithString:title];
        [attStrSel addAttribute:NSFontAttributeName value:fontSemiBold(16) range:range];
        [attStrSel addAttribute:NSForegroundColorAttributeName value:[UIColor colorMain] range:range];
        [btn setAttributedTitle:attStr forState:UIControlStateNormal];
        [btn setAttributedTitle:attStrSel forState:UIControlStateSelected];
        
    }
    self.bottomLine.backgroundColor = [UIColor colorMain];
   
   
}

@end
