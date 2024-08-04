//
//  MessageViewBaseCell.m
//  GoChat
//
//  Created by wangyutao on 2020/11/12.
//

#import "MessageViewBaseCell.h"

@interface MessageViewBaseCell()

@property (nonatomic, strong, readwrite) MessageInfo *chatRecordDTO;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@property (nonatomic, strong) UIImageView *multiSelectImageView;
@property (nonatomic, strong) UIButton *interceptAllEventsButton;
@end

@implementation MessageViewBaseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initTapGesture];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self initTapGesture];
}

//是否多选模式-touch屏蔽使用
- (BOOL)IsMultiSelectingMode
{
    if ([self.delegate respondsToSelector:@selector(messageCellIsMultiSelectingMode)])
    {
        return [self.delegate messageCellIsMultiSelectingMode];
    }
    return NO;
}

//是否可以进入多选模式
- (BOOL)IsCanGotoMultiSelectingMode
{
    if ([self.delegate respondsToSelector:@selector(messageCellIsCanGotoMultiSelectingMode:)])
    {
        return [self.delegate messageCellIsCanGotoMultiSelectingMode:self];
    }
    return NO;
}

- (void)initTapGesture
{
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    self.singleTap.numberOfTapsRequired = 1;
    
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    self.doubleTap.numberOfTapsRequired = 2;
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
    
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.singleTap requireGestureRecognizerToFail:self.longPress];
}

- (void)setupTapGesture
{
    NSArray *lt = self.gestureRecognizers;
    if([self IsMultiSelectingMode])
    {
        if([lt containsObject:self.singleTap])
            [self removeGestureRecognizer:self.singleTap];
        if([lt containsObject:self.doubleTap])
            [self removeGestureRecognizer:self.doubleTap];
        if([lt containsObject:self.longPress])
            [self removeGestureRecognizer:self.longPress];
    }
    else
    {
        if(![lt containsObject:self.singleTap])
            [self addGestureRecognizer:self.singleTap];
        if(![lt containsObject:self.doubleTap])
            [self addGestureRecognizer:self.doubleTap];
        if(![lt containsObject:self.longPress])
            [self addGestureRecognizer:self.longPress];
    }
}

+ (CGFloat)contentHeightForTableViewWith:(MessageInfo *)chatRecordDTO showNickName:(BOOL)showNickName
{
    return 0;
}

- (void)loadChatRecord:(MessageInfo *)chatRecordDTO isGroup:(BOOL)isGroup{
    self.isGroup = isGroup;
    [self loadChatRecord:chatRecordDTO];
    
}

- (void)loadChatRecord:(MessageInfo *)chatRecordDTO
{
    self.chatRecordDTO = chatRecordDTO;
    
    [self initialize];
    
    [self config];
    
    [self adjustFrame];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self reset];
}

- (void)reset
{
    [self.contentBaseView removeFromSuperview];
    
    [self.multiSelectImageView removeFromSuperview];
    
    [self.interceptAllEventsButton removeFromSuperview];
}

- (void)initialize
{
    if (self.contentBaseView == nil || self.contentBaseView.tag != self.chatRecordDTO.messageType)
    {
        self.contentBaseView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
        CGRect frame = self.contentBaseView.frame;
        frame.size.width = SCREEN_WIDTH;
        self.contentBaseView.frame = frame;
    }
    self.contentBaseView.tag = self.chatRecordDTO.messageType;
}

- (void)config
{
    [self.contentView addSubview:self.contentBaseView];
    if([self IsMultiSelectingMode] && [self IsCanGotoMultiSelectingMode])
    {
        [self.contentView addSubview:self.multiSelectImageView];
        [self.contentView addSubview:self.interceptAllEventsButton];
        self.interceptAllEventsButton.frame = self.contentView.bounds;
        self.interceptAllEventsButton.autoresizingMask = 0xFF;
        
        if(self.chatRecordDTO.isSelected)
            [self.multiSelectImageView setImage:[UIImage imageNamed:@"icon_choose_sel"]];
        else
            [self.multiSelectImageView setImage:[UIImage imageNamed:@"icon_choose"]];
    }
}

- (void)adjustFrame
{
    CGRect frame = self.contentBaseView.frame;
    if([self IsMultiSelectingMode] && [self IsCanGotoMultiSelectingMode])
    {
        CGRect multiSelectImageFrame = self.multiSelectImageView.frame;
        if(self.chatRecordDTO.isShowDayText)
        {
            multiSelectImageFrame.origin.y = MessageCellTimestampRegionHeight+MessageCellVertMargins*2+(MessageCellAvatarHeight-20)/2;
        }
        else
        {
            multiSelectImageFrame.origin.y = MessageCellVertMargins+(MessageCellAvatarHeight-20)/2;
        }
        self.multiSelectImageView.frame = multiSelectImageFrame;
        
        [self.contentView bringSubviewToFront:self.interceptAllEventsButton];
        self.interceptAllEventsButton.frame = self.contentView.bounds;
        self.interceptAllEventsButton.autoresizingMask = 0xFF;
        
        if(!self.chatRecordDTO.is_outgoing)
        {
            frame.origin.x = 30;
        }
        else
        {
            frame.origin.x = 0;
        }
    }
    else
    {
        frame.origin.x = 0;
    }
    self.contentBaseView.frame = frame;
}

- (UIImageView *)multiSelectImageView
{
    if(!_multiSelectImageView)
    {
        _multiSelectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 20, 20)];
    }
    return _multiSelectImageView;
}

- (UIButton *)interceptAllEventsButton
{
    if(!_interceptAllEventsButton)
    {
        _interceptAllEventsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_interceptAllEventsButton setBackgroundColor:[UIColor clearColor]];
        [_interceptAllEventsButton setTitle:@"" forState:UIControlStateNormal];
        [_interceptAllEventsButton addTarget:self action:@selector(click_selectChanged) forControlEvents:UIControlEventTouchUpInside];
    }
    return _interceptAllEventsButton;
}

- (void)click_selectChanged
{
    if ([self.delegate respondsToSelector:@selector(messageCellSelectChanged:)])
    {
        [self.delegate messageCellSelectChanged:self];
    }
}

- (NSArray *)menuItems
{
    return nil;
}

- (void)singleTap:(UITapGestureRecognizer *)singleTapGesture
{
    
}
- (void)doubleTap:(UITapGestureRecognizer *)doubleTapGesture
{
    
}
- (void)longPress:(UILongPressGestureRecognizer *)longPressGesture
{
    
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)banSomeone:(id)sender
{
    
}

- (void)delOneHisSomeone:(id)sender
{
    
}

- (void)delAllHisSomeone:(id)sender
{
    
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    NSArray *menuItems = [self menuItems];
    for (UIMenuItem *item in menuItems)
    {
        if (action == item.action)
        {
            return YES;
        }
    }
    if (action == @selector(banSomeone:))
    {
        return YES;
    }
    if (action == @selector(delOneHisSomeone:))
    {
        return YES;
    }
    if (action == @selector(delAllHisSomeone:))
    {
        return YES;
    }
    return NO;
}

@end
