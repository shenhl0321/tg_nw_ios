//
//  CZLinkMsgTableViewCell.m
//  GoChat
//
//  Created by mac on 2021/7/31.
//

#import "CZLinkMsgTableViewCell.h"

@interface CZLinkMsgTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *linkImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *describeLabel;
@property (weak, nonatomic) IBOutlet UILabel *LickLabel;//link

@end

@implementation CZLinkMsgTableViewCell
-(void)awakeFromNib{
    [super awakeFromNib];
    self.titleLabel.font = fontRegular(16);
    self.titleLabel.textColor = [UIColor colorTextFor23272A];
    self.describeLabel.font = fontRegular(14);
    self.describeLabel.textColor = [UIColor colorTextForA9B0BF];
}
- (void)resettingUI{
    _titleLabel.text = @"";
    _describeLabel.text = @"";
    _LickLabel.text = @"";
}

- (void)setCellInfo:(MessageInfo *)cellInfo{
    [self resettingUI];
    if (cellInfo) {
        _cellInfo = cellInfo;
        WebpageModel *webmodel = cellInfo.content.web_page;
        if (webmodel) {
            _titleLabel.text = webmodel.title;
            _describeLabel.text = webmodel.descriptionmsg;
            _LickLabel.text = webmodel.url;
        }else{
            
        }
        
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
