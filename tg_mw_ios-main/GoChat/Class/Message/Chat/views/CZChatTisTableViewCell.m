//
//  CZChatTisTableViewCell.m
//  GoChat
//
//  Created by mac on 2021/7/7.
//

#import "CZChatTisTableViewCell.h"

#define Header_Tip_Def [NSString stringWithFormat:@"当前对话已被%@端对端加密保护".lv_localized, APP_NAME]

@interface CZChatTisTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgHC;


@end

@implementation CZChatTisTableViewCell

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"CZChatTisTableViewCell" owner:self options:nil]lastObject];
    if (self) {

        self.contentLabel.text = Header_Tip_Def;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//#F5F9FA
    self.contentView.backgroundColor = [UIColor clearColor];
    self.bgView.layer.cornerRadius = 5;
    self.bgView.backgroundColor = [UIColor colorForF5F9FA];
    self.contentLabel.font = fontRegular(14);
    self.contentLabel.textColor = [UIColor colorFor878D9A];
    
    NSArray *langArr1 = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
    NSString *currentLanguage = langArr1.firstObject;
    if ([currentLanguage isEqualToString:@"en"]) {
        self.bgHC.constant = 50;
    } else {
        self.bgHC.constant = 30;
    }
    ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
