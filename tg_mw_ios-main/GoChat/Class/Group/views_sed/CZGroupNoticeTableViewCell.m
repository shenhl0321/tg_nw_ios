//
//  CZGroupNoticeTableViewCell.m
//  GoChat
//
//  Created by mac on 2021/7/24.
//

#import "CZGroupNoticeTableViewCell.h"

@interface CZGroupNoticeTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation CZGroupNoticeTableViewCell

-(void)setHiddeLine:(BOOL)hiddeLine{
    _hiddeLine = hiddeLine;
    self.lineView.hidden = hiddeLine;
}
-(void)refreshMainLabelWithText:(NSString *)text{
    self.nameLabel.text = text;
}
-(void)setGonggaoStr:(NSString *)gonggaoStr{
    self.mainLabel.text = gonggaoStr;
}
- (void)setGroupNoticeStr:(NSString *)groupNoticeStr{
    if (groupNoticeStr) {
        _groupNoticeStr = groupNoticeStr;
    }
    NSArray *textArr = [CZCommonTool rowsOfString:groupNoticeStr withFont:[UIFont systemFontOfSize:14] withWidth:SCREEN_WIDTH-30];
    if (textArr && textArr.count > 3) {//最少四行 多行
        if (_isShowAll) {//展开
            _mainLabel.text = groupNoticeStr;
        }else{//折叠  多行
            NSMutableString *contentText = [[NSMutableString alloc] init];
            NSUInteger cutLength = 15; // 截取的长度
            for (int i = 0; i<3; i++) {
                NSString *testLine = [textArr objectAtIndex:i];
                if (i != 2) {
                    [contentText appendString:testLine];
                }else{
                    NSString  *lastLineText = testLine.length > 16 ? [testLine substringToIndex:(testLine.length - cutLength)] : testLine;
                    [contentText appendString:[NSString stringWithFormat:@"%@...",lastLineText]];
                    NSMutableAttributedString *mutableAttribText = [[NSMutableAttributedString alloc] initWithString:[contentText stringByAppendingString:@" 查看更多".lv_localized]];
                    [mutableAttribText addAttributes:@{
                        NSFontAttributeName : [UIFont boldSystemFontOfSize:14.0f],
                        NSForegroundColorAttributeName : [UIColor colorWithRed:0/255.0 green:192/255.0 blue:145/255.0 alpha:1.0]
                    } range:NSMakeRange(contentText.length, 5)];
                    _mainLabel.attributedText = mutableAttribText;
                }
            }
        }
    }else{//完全展示
        _mainLabel.text = groupNoticeStr;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.nameLabel.font = fontRegular(16);
    self.nameLabel.textColor = [UIColor colorTextFor23272A];
    self.mainLabel.textColor = [UIColor colorTextFor878D9A];
    self.mainLabel.font = fontRegular(15);
    //    [self.mainLabel setReadMoreLabelContentMode];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
