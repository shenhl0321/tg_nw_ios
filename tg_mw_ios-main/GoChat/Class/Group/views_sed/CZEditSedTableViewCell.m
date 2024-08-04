//
//  CZEditSedTableViewCell.m
//  GoChat
//
//  Created by mac on 2021/8/5.
//

#import "CZEditSedTableViewCell.h"

@interface CZEditSedTableViewCell ()
@property (weak, nonatomic) IBOutlet UITextView *inputView;
@end

@implementation CZEditSedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellModel:(MessageInfo *)cellModel{
    if (cellModel) {
        _cellModel = cellModel;
    }
    self.inputView.text = [self groupIntroduction];
}

- (NSString *)groupIntroduction{
    if(self.cellModel != nil)
    {
        NSString *text = self.cellModel.description;
        if([text hasPrefix:GROUP_NOTICE_PREFIX])
        {
            text = [text substringFromIndex:GROUP_NOTICE_PREFIX.length];
        }
        return text;
    }
    return @"";
}

- (NSString *)groupIntroStr{
    if ([self.inputView.text isEqualToString:[self groupIntroduction]]) {
        return nil;
    }else{
        return self.inputView.text;
    }
}

@end
