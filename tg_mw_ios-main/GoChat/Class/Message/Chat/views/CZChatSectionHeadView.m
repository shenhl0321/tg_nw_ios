//
//  CZChatSectionHeadView.m
//  GoChat
//
//  Created by mac on 2021/7/7.
//

#import "CZChatSectionHeadView.h"

@interface CZChatSectionHeadView ()

@property (nonatomic,copy)  dispatch_block_t blackBlock;
@property (nonatomic,copy)  dispatch_block_t addBlock;
@property (weak, nonatomic) IBOutlet UILabel *shieldLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UILabel *addFriendLabel;

@end

@implementation CZChatSectionHeadView

- (void)setIs_black:(BOOL)is_black{
    _is_black = is_black;
    //UI
    self.shieldLabel.text =  is_black ? @"解除屏蔽".lv_localized : @"屏蔽此人".lv_localized;
}

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"CZChatSectionHeadView" owner:self options:nil]lastObject];
    if (self) {
//        self.backgroundColor = [UIColor colorWithRed:241/255.0 green:243/255.0 blue:242/255.0 alpha:1.0];
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
//        UITapGestureRecognizer * sj0909tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(method0909createTapGesture:)];
//        sj0909tap.numberOfTouchesRequired = 1;
//        [self addGestureRecognizer:sj0909tap];
    }
    return self;
}

- (void)bindClickEventWithfirBtn:(dispatch_block_t)blackBlock withAddFriendBtn:(dispatch_block_t)addBlock{
    self.addBlock = addBlock;
    self.blackBlock = blackBlock;
}

//屏蔽
- (IBAction)addBlackList:(UIButton *)sender {
    if (self.blackBlock) {
        self.blackBlock();
    }
}

//加好友
- (IBAction)addFriendClick:(UIButton *)sender {
    if (self.addBlock) {
        self.addBlock();
    }
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor colorForF5F9FA];
    self.lineView.backgroundColor = [UIColor colorTextForA9B0BF];
    self.shieldLabel.font = fontRegular(16);
    self.shieldLabel.textColor = [UIColor colorTextForFD4E57];
    self.addFriendLabel.font = fontRegular(16);
    self.addFriendLabel.textColor = [UIColor colorMain];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
