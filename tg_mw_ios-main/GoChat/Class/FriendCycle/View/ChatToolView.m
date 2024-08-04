//
//  ChatToolView.m
//  GoChat
//
//  Created by 吴亮 on 2021/10/3.
//

#import "ChatToolView.h"
#import "CustomTextView.h"
#import "ChatEmojiView.h"

@interface ChatToolView ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *inputTextView;
@property (nonatomic, strong) UIButton * emojiBtn;
@property (nonatomic, strong) ChatEmojiView * emojiPannelView;
@property (nonatomic, strong) UIButton * sendBtn;
@end



@implementation ChatToolView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildUI];
    }
    return self;
}

-(void)buildUI {
    self.inputTextView = [[UITextView alloc] init];
    self.inputTextView.zw_placeHolder = @"评论".lv_localized;
    self.inputTextView.zw_placeHolderColor = HEX_COLOR(@"#CCCCCC");
    self.inputTextView.delegate = self;
    self.inputTextView.font = [UIFont systemFontOfSize:15];
    self.inputTextView.textColor = UIColor.xhq_aTitle;
    [self addSubview:self.inputTextView];
    
    self.emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.emojiBtn setImage:[UIImage imageNamed:@"chat_tool_emotion"] forState:UIControlStateNormal];
    [self addSubview:self.emojiBtn];
    
    self.sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendBtn setTitle:@"发送".lv_localized forState:UIControlStateNormal];
    [self.sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendBtn.backgroundColor = HEX_COLOR(@"#00C69B");
    self.sendBtn.layer.masksToBounds = YES;
    self.sendBtn.layer.cornerRadius = 5;
    self.sendBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.sendBtn addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sendBtn];
    
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.centerY.equalTo(self);
        make.height.equalTo(@32);
        make.width.equalTo(@60);
    }];
    
    [self.emojiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self.sendBtn.mas_left).offset(-15);
        make.width.height.equalTo(@30);
    }];
    
    
    [self.inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@40);
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self.emojiBtn.mas_left).offset(-15);
    }];
    
    
}

- (void)textViewDidChange:(UITextView *)textView {
    
}

- (void)send {
    self.inputTextView.text = @"";
    [self.inputTextView resignFirstResponder];
}


@end
