//
//  MNContactSearchTestCell.m
//  GoChat
//
//  Created by Autumn on 2022/3/14.
//

#import "MNContactSearchTestCell.h"
#import "UserinfoHelper.h"
#import "TimeFormatting.h"

@implementation MNContactSearchTestCellItem

- (CGFloat)cellHeight {
    return 60;
}

@end

@interface MNContactSearchTestCell ()

@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UILabel *content;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UIImageView *icon;


@end

@implementation MNContactSearchTestCell

- (void)setItem:(DYTableViewCellItem *)item {
    [super setItem:item];
    MNContactSearchTestCellItem *m = (MNContactSearchTestCellItem *)item;
    MessageInfo *msg = m.msg;
    [UserinfoHelper setUsername:msg.sender.user_id inLabel:_username];
    [UserinfoHelper setUserAvatar:msg.sender.user_id inImageView:_icon];
    _time.text = [TimeFormatting formatTimeWithTimeInterval:msg.date];
    _content.attributedText = nil;
    _content.text = msg.description;
    NSRange range = [_content.text rangeOfString:m.keyword];
    [_content xhq_AttributeTextAttributes:@{NSForegroundColorAttributeName: UIColor.colorMain} range: range];
}

- (void)dy_initUI {
    [super dy_initUI];
    [_icon xhq_cornerRadius:5];
    [self dy_noneSelectionStyle];
}

@end
