//
//  CZNOPreviewTableViewCell.m
//  GoChat
//
//  Created by mac on 2021/7/31.
//

#import "CZNOPreviewTableViewCell.h"
#import "TextUnit.h"

@interface CZNOPreviewTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *linkImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;

@property (weak, nonatomic) IBOutlet UILabel *subTitle;

@end

@implementation CZNOPreviewTableViewCell

- (void)resettingUI{
    _titleLabel.text = @"";
    _urlLabel.text = @"";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellInfo:(MessageInfo *)cellInfo{
    [self resettingUI];
    if (cellInfo) {
        _cellInfo = cellInfo;
        
        if (cellInfo.headerInfo.count > 0) {
            self.urlLabel.text = cellInfo.textTypeContent;
            NSString *title = cellInfo.headerInfo[@"title"];
            if (IsStrEmpty(title)) {
                self.titleLabel.text = @"链接地址".lv_localized;
            } else {
                self.titleLabel.text = title;
            }
            self.subTitle.text = cellInfo.headerInfo[@"description"];
            [self.linkImageView sd_setImageWithURL:[NSURL URLWithString:cellInfo.headerInfo[@"icon"]] placeholderImage:[UIImage imageNamed:@"detail_link"]];
            self.subTitle.hidden = NO;
        } else if (cellInfo.linkUrls.count > 0) {
            self.titleLabel.text = cellInfo.textTypeContent;
            self.urlLabel.text = cellInfo.linkUrls.firstObject.transferredContent;
            self.subTitle.hidden = YES;
            self.linkImageView.image = [UIImage imageNamed:@"detail_link"];
        } else {
            self.urlLabel.text = cellInfo.textTypeContent;
            self.titleLabel.text = @"链接地址".lv_localized;
            self.subTitle.hidden = YES;
            self.linkImageView.image = [UIImage imageNamed:@"detail_link"];
//            [self.linkImageView sd_setImageWithURL:[NSURL URLWithString:cellInfo.headerInfo[@"icon"]] placeholderImage:[UIImage imageNamed:@"detail_link"]];
        }
        
        
        
        
    }
}

@end
