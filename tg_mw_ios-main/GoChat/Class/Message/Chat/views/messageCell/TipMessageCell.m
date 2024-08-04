//
//  TipMessageCell.m

#import "TipMessageCell.h"

@interface TipMessageCell()
@property (nonatomic, strong) IBOutlet UILabel *promptLabel;
@property (nonatomic, strong) IBOutlet UIView *bgView;
@property (nonatomic, strong) IBOutlet UILabel *dayLabel;
@end

@implementation TipMessageCell

-(void)awakeFromNib{
    [super awakeFromNib];
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       
    }
    return self;
}

- (void)refreshUI{

    self.bgView.layer.cornerRadius = 5;
    self.bgView.layer.masksToBounds = YES;
    self.bgView.backgroundColor = [UIColor colorForF5F9FA];
    self.promptLabel.font = fontRegular(14);
    self.promptLabel.textColor = [UIColor colorFor878D9A];
}

+ (CGFloat)contentHeightForTableViewWith:(MessageInfo *)chatRecordDTO showNickName:(BOOL)showNickName
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-120, 20)];
    if([@"messageBasicGroupChatCreate" isEqualToString:chatRecordDTO.content.type])
    {
        label.text = [chatRecordDTO description];
    }
    else if([@"messageSupergroupChatCreate" isEqualToString:chatRecordDTO.content.type])
    {
        label.text = [chatRecordDTO description];
    }
    else if([@"messageChatAddMembers" isEqualToString:chatRecordDTO.content.type])
    {
        label.text = [chatRecordDTO description];
    }
    else if([@"messageChatDeleteMember" isEqualToString:chatRecordDTO.content.type])
    {
        label.text = [chatRecordDTO description];
    }
    else if([@"messageChatChangeTitle" isEqualToString:chatRecordDTO.content.type])
    {
        label.text = [chatRecordDTO description];
    }
    else if([@"messageChatChangePhoto" isEqualToString:chatRecordDTO.content.type])
    {
        label.text = [chatRecordDTO description];
    }
    else if([@"messageChatJoinByLink" isEqualToString:chatRecordDTO.content.type])
    {
        label.text = [chatRecordDTO description];
    }
    else if(chatRecordDTO.messageType == MessageType_Text_Got_Rp)
    {
        label.text = [chatRecordDTO description];
    }
    else if(chatRecordDTO.messageType == MessageType_Text_Screenshot)
    {
        label.text = [chatRecordDTO description];
    }
    else if(chatRecordDTO.messageType == MessageType_Text_BeFriend)
    {
        label.text = [chatRecordDTO description];
    }
    else if(chatRecordDTO.messageType == MessageType_Contact_Registed ||
            chatRecordDTO.messageType == MessageType_Text_Kicked_SensitiveWords)
    {
        label.text = [chatRecordDTO description];
    }
    else if(chatRecordDTO.messageType == MessageType_Text_Blacklist)
    {
        label.text = @"您已被对方加入黑名单".lv_localized;
    }
    else if(chatRecordDTO.messageType == MessageType_Text_Stranger)
    {
        label.text = @"对方拒绝陌生人会话".lv_localized;
    }
    else
    {
        label.text = @"App暂时不支持该消息".lv_localized;
    }
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.font = fontRegular(14);
    label.numberOfLines = 0;
    CGSize size = [label sizeThatFits:CGSizeMake(label.frame.size.width, CGFLOAT_MAX)];
    
    //内容高度
    CGFloat height = MessageCellVertMargins + size.height;
    //背景区高度
    height += 4;
    //底部边距
    height += MessageCellVertMargins;
    
    if(chatRecordDTO.isShowDayText)
    {//日期
        //内容高度
        CGFloat time_height = MessageCellVertMargins + MessageCellTimestampRegionHeight;
        height += time_height;
    }
    
    return height;
}

- (void)reset
{
    [super reset];
}

- (void)initialize
{
    [super initialize];
    //日期
    self.dayLabel.hidden = YES;
}

- (void)config
{
    [super config];
    if([@"messageBasicGroupChatCreate" isEqualToString:self.chatRecordDTO.content.type])
    {
        self.promptLabel.text = [self.chatRecordDTO description];
    }
    else if([@"messageSupergroupChatCreate" isEqualToString:self.chatRecordDTO.content.type])
    {
        self.promptLabel.text = [self.chatRecordDTO description];
    }
    else if([@"messageChatAddMembers" isEqualToString:self.chatRecordDTO.content.type])
    {
        self.promptLabel.text = [self.chatRecordDTO description];
    }
    else if([@"messageChatDeleteMember" isEqualToString:self.chatRecordDTO.content.type])
    {
        self.promptLabel.text = [self.chatRecordDTO description];
    }
    else if([@"messageChatJoinByLink" isEqualToString:self.chatRecordDTO.content.type])
    {
        self.promptLabel.text = [self.chatRecordDTO description];
    }
    else if([@"messageChatChangeTitle" isEqualToString:self.chatRecordDTO.content.type])
    {
        self.promptLabel.text = [self.chatRecordDTO description];
    }
    else if([@"messageChatChangePhoto" isEqualToString:self.chatRecordDTO.content.type])
    {
        self.promptLabel.text = [self.chatRecordDTO description];
    }
    else if(self.chatRecordDTO.messageType == MessageType_Text_Got_Rp)
    {
        self.promptLabel.text = [self.chatRecordDTO description];
    }
    else if(self.chatRecordDTO.messageType == MessageType_Text_Screenshot)
    {
        self.promptLabel.text = [self.chatRecordDTO description];
    }
    else if(self.chatRecordDTO.messageType == MessageType_Text_BeFriend)
    {
        self.promptLabel.text = [self.chatRecordDTO description];
    }
    else if(self.chatRecordDTO.messageType == MessageType_Contact_Registed ||
            self.chatRecordDTO.messageType == MessageType_Text_Kicked_SensitiveWords)
    {
        self.promptLabel.text = [self.chatRecordDTO description];
    }
    else if(self.chatRecordDTO.messageType == MessageType_Text_Blacklist)
    {
        self.promptLabel.text = @"您已被对方加入黑名单".lv_localized;
    }
    else if(self.chatRecordDTO.messageType == MessageType_Text_Stranger)
    {
        self.promptLabel.text = @"对方拒绝陌生人会话".lv_localized;
    }
    else
    {
        self.promptLabel.text = @"App暂时不支持该消息".lv_localized;
        NSLog(@"UnkownMessageCell: %@", self.chatRecordDTO.content.type);
    }
    if(self.chatRecordDTO.isShowDayText)
    {//显示日期文本
        self.dayLabel.hidden = NO;
        self.dayLabel.text = [Common getMessageDay:self.chatRecordDTO.date];
    }
}

- (void)adjustFrame
{
    [self refreshUI];
    CGFloat yOffset = 0;
    if(self.chatRecordDTO.isShowDayText)
    {
        CGRect frame = self.dayLabel.frame;
        frame.size.width = SCREEN_WIDTH;
        frame.size.height = MessageCellTimestampRegionHeight;
        frame.origin.y = MessageCellVertMargins;
        frame.origin.x = 0;
        self.dayLabel.frame = frame;
        yOffset = MessageCellVertMargins+MessageCellTimestampRegionHeight;
    }
    
    //提示信息
    CGRect frame = self.promptLabel.frame;
    frame.size.width = SCREEN_WIDTH-120;
    CGSize size = [self.promptLabel sizeThatFits:CGSizeMake(frame.size.width, CGFLOAT_MAX)];
    frame.size.height = size.height;
    frame.origin.y = yOffset+MessageCellVertMargins+2;
    frame.origin.x = (SCREEN_WIDTH - size.width) / 2;
    self.promptLabel.frame = frame;
    
    //内容区背景
    frame = self.bgView.frame;
    frame.size.width = size.width + 24;
    frame.size.height = self.promptLabel.frame.size.height + 4;
    frame.origin.y = yOffset+MessageCellVertMargins;
    frame.origin.x = (SCREEN_WIDTH - frame.size.width) / 2;
    self.bgView.frame = frame;
    self.bgView.layer.cornerRadius = 4;
    
    //内容区高度调整
    frame = self.contentBaseView.frame;
    frame.size.height = self.bgView.frame.size.height;
    self.contentBaseView.frame = frame;
   
    [super adjustFrame];
}

@end
