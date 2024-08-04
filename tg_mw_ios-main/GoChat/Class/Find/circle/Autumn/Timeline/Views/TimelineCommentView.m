//
//  TimelineCommentView.m
//  GoChat
//
//  Created by Autumn on 2021/11/22.
//

#import "TimelineCommentView.h"
#import "CustomTextView.h"
#import "EmojiContainer.h"
#import "TimelineHelper.h"

@interface TimelineCommentView ()<UITextViewDelegate, EmojiContainerDelegate>

@property (nonatomic, strong) UITextView *inputTextView;
@property (nonatomic, strong) UIButton *emojiBtn;
@property (nonatomic, strong) EmojiContainer *emojiContainer;
//@property (nonatomic, strong) UIButton *sendBtn;
@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, assign, getter=isDisplayEmoji) BOOL displayEmoji;

@property (nonatomic, assign) NSInteger blogId;
@property (nonatomic, assign) NSInteger replyId;

/// 记录当前视图被添加时，距离父视图底部的距离。只记录一次。
@property (nonatomic, assign) CGFloat paddingToBottom;
@property (nonatomic, assign, getter=isLoadOnce) BOOL loadOnce;

@property (nonatomic, assign, getter=isSending) BOOL sending;

@end

@implementation TimelineCommentView

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)dy_initUI {
    [super dy_initUI];
    self.loadOnce = YES;
    
    self.backgroundColor = UIColor.xhq_section;
    self.inputTextView = [[UITextView alloc] init];
    self.inputTextView.delegate = self;
    self.inputTextView.font = [UIFont systemFontOfSize:15];
    self.inputTextView.textColor = UIColor.xhq_aTitle;
    self.inputTextView.backgroundColor = UIColor.whiteColor;
    self.inputTextView.returnKeyType = UIReturnKeySend;
    self.inputTextView.zw_placeHolder = @"评论";
    self.inputTextView.zw_placeHolderColor = HEX_COLOR(@"#CCCCCC");
    [self addSubview:self.inputTextView];
    
    self.emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.emojiBtn setImage:[UIImage imageNamed:@"chat_tool_emotion"] forState:UIControlStateNormal];
    [self.emojiBtn setImage:[UIImage imageNamed:@"icon_comment_keyboard"] forState:UIControlStateSelected];
    [self.emojiBtn addTarget:self action:@selector(emojiAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.emojiBtn];
    
    self.emojiContainer = [EmojiContainer loadFromNib];
    self.emojiContainer.delegate = self;
    
    self.maskView = UIView.new;
    @weakify(self);
    [self.maskView xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        @strongify(self);
        [self close];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.emojiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.centerY.equalTo(@0);
        make.width.height.equalTo(@30);
    }];
    [self.inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@40);
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self.emojiBtn.mas_left).offset(-15);
    }];
    if (self.isLoadOnce) {
        self.paddingToBottom = CGRectGetHeight(self.superview.frame) - CGRectGetMinY(self.frame);
        self.loadOnce = NO;
    }
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (!self.superview) {
        return;
    }
    [self.superview addSubview:self.emojiContainer];
    [self.emojiContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        make.top.equalTo(self.superview.mas_bottom);
        make.height.mas_equalTo(240 + kHomeIndicatorHeight());
    }];
}

#pragma mark - Notification
- (void)keyboardChangedNotification:(NSNotification *)noti {
    NSDictionary *userInfo = [noti userInfo];
    NSTimeInterval duration;
    UIViewAnimationCurve animationCurve;
    CGRect endFrame;
    duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    endFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if ([noti.name isEqualToString:UIKeyboardWillShowNotification]) {
        [self hideEmojiView];
        [self.window addSubview:self.maskView];
        self.maskView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetMinY(endFrame) - CGRectGetHeight(self.frame));
        [UIView animateWithDuration:duration animations:^{
            self.transform = CGAffineTransformMakeTranslation(0, -endFrame.size.height - self.frame.size.height + self.paddingToBottom);
        }];
    } else {
        [self.maskView removeFromSuperview];
        if (!self.isDisplayEmoji) {
            [UIView animateWithDuration:duration animations:^{
                self.transform = CGAffineTransformIdentity;
            }];
        }
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self send];
        return NO;
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.emojiBtn.selected = NO;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardChangedNotification:)
                                               name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardChangedNotification:)
                                               name:UIKeyboardWillHideNotification object:nil];
    return YES;
}

#pragma mark - EmojiContainerDelegate
- (void)emojiContainer_Choose:(EmojiContainer *)view emoji:(NSString *)emoji {
    [self.inputTextView insertText:emoji];
}

- (void)emojiContainer_Delete:(EmojiContainer *)view {
    [self.inputTextView deleteBackward];
}

- (void)emojiContainer_Send:(EmojiContainer *)view {
    [self send];
}

#pragma mark - Event
- (void)emojiAction:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [self showEmojiView];
    } else {
        [self.inputTextView becomeFirstResponder];
    }
}

- (void)showEmojiView {
    if (self.isDisplayEmoji) {
        return;
    }
    self.displayEmoji = YES;
    if (self.inputTextView.isFirstResponder) {
        [self.inputTextView resignFirstResponder];
    }
    CGFloat translationY = (CGRectGetHeight(self.emojiContainer.bounds));
    CGFloat viewHeight = CGRectGetHeight(self.frame);
    [UIView animateWithDuration:0.25 animations:^{
        self.emojiContainer.transform = CGAffineTransformMakeTranslation(0, -translationY);
        self.transform = CGAffineTransformMakeTranslation(0, -translationY - viewHeight + self.paddingToBottom);
    }];
    [self.window addSubview:self.maskView];
    CGRect frame = [self.window convertRect:self.superview.frame fromView:self.superview];
    self.maskView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetMinY(self.emojiContainer.frame) - viewHeight + CGRectGetMinY(frame));
}

- (void)hideEmojiView {
    
    if (!self.isDisplayEmoji) {
        return;
    }
    self.displayEmoji = NO;
    [self.maskView removeFromSuperview];
    NSTimeInterval duration = self.inputTextView.isFirstResponder ? 0 : 0.25;
    [UIView animateWithDuration:duration animations:^{
        self.transform = CGAffineTransformIdentity;
        self.emojiContainer.transform = CGAffineTransformIdentity;
    }];
}

- (void)send {
    if (self.isSending) {
        return;
    }
    self.sending = YES;
    NSString *text = [self.inputTextView.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (text.length == 0) {
        return;
    }
    if (self.blogId > 0) {
        [TimelineHelper commentBlog:self.blogId text:text completion:^(BOOL success) {
            [self close];
        }];
    } else if (self.replyId > 0) {
        [TimelineHelper commentReply:self.replyId text:text completion:^(BOOL success) {
            [self close];
        }];
    }
}

- (void)close {
    if (self.inputTextView.isFirstResponder) {
        [self.inputTextView resignFirstResponder];
    }
    if (self.isDisplayEmoji) {
        [self hideEmojiView];
    }
    self.inputTextView.text = @"";
    self.sending = NO;
    self.emojiBtn.selected = NO;
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - Public
- (void)commentBlog:(NSInteger)blogId {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardChangedNotification:)
                                               name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardChangedNotification:)
                                               name:UIKeyboardWillHideNotification object:nil];
    self.inputTextView.zw_placeHolder = @"评论".lv_localized;
    self.replyId = 0;
    self.blogId = blogId;
    [self.inputTextView becomeFirstResponder];
}

- (void)commentReply:(NSInteger)replyId name:(NSString *)name {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardChangedNotification:)
                                               name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardChangedNotification:)
                                               name:UIKeyboardWillHideNotification object:nil];
    self.inputTextView.zw_placeHolder = [NSString stringWithFormat:@"回复%@".lv_localized, name];
    self.replyId = replyId;
    self.blogId = 0;
    [self.inputTextView becomeFirstResponder];
}

- (void)setCommentReplyId:(NSInteger)rId {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardChangedNotification:)
                                               name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardChangedNotification:)
                                               name:UIKeyboardWillHideNotification object:nil];
    self.replyId = rId;
    self.blogId = 0;
}

- (void)setCommentReplyName:(NSString *)name {
    self.inputTextView.zw_placeHolder = [NSString stringWithFormat:@"回复%@".lv_localized, name];
}

@end
