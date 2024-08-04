//
//  TimelineInfoReplyCell.m
//  GoChat
//
//  Created by Autumn on 2021/11/19.
//

#import "TimelineInfoReplyCell.h"
#import "BlogReply.h"
#import "UserTimelineVC.h"
#import "UserinfoHelper.h"
#import "TimelineHelper.h"
#import "TimeFormatting.h"

@interface TimelineInfoReplyCellItem ()

@property (nonatomic, copy) NSString *username;

@property (nonatomic, assign) NSInteger showNumber;

@end

@implementation TimelineInfoReplyCellItem

- (void)setDisplayMode:(RepayListDisplayMode)displayMode {
    _displayMode = displayMode;
    NSInteger number = self.showNumber;
    switch (displayMode) {
        case RepayListDisplayMode_All:
        case RepayListDisplayMode_None:
            number = 1;
            break;
        case RepayListDisplayMode_More:
            if (number == 1) {
                number += 5;
            } else {
                number += 3;
            }
            break;
        case RepayListDisplayMode_Close:
            number = self.subRepayNumber + 1;
            break;
    }
    
    self.showNumber = MIN(number, self.subRepayNumber + 1);
}

@end

@interface TimelineInfoReplyCell ()

@property (nonatomic, strong) UIImageView *headImageV;
@property (nonatomic, strong) UILabel *nameL;
@property (nonatomic, strong) UILabel *timeL;
@property (nonatomic, strong) UIButton *replayBtn;
@property (nonatomic, strong) UILabel *contentL;
@property (nonatomic, strong) UIButton *likeBtn;
@property (nonatomic, strong) UILabel *subReplyL;
@property (nonatomic, strong) UILabel *subReplyNameL;

@end

@implementation TimelineInfoReplyCell

- (void)setItem:(DYTableViewCellItem *)item {
    [super setItem:item];
    TimelineInfoReplyCellItem *m = (TimelineInfoReplyCellItem *)item;
    BlogReply *reply = (BlogReply *)item.cellModel;
    self.timeL.text = [TimeFormatting formatTimeWithTimeInterval:reply.date];
    self.contentL.text = reply.text;
    self.likeBtn.selected = reply.liked;
    [self.likeBtn setTitle:[NSString stringWithFormat:@"%ld", reply.like_count] forState:UIControlStateNormal];
    [UserinfoHelper setUsername:reply.user_id inLabel:self.nameL];
    [UserinfoHelper setUserAvatar:reply.user_id inImageView:self.headImageV];
    if (m.isSubRepay) {
        [UserinfoHelper setUsername:reply.reply_user_id inLabel:self.subReplyNameL];
        if (m.isReplyInfo) {
            self.subReplyL.hidden = self.subReplyNameL.hidden = YES;
            self.nameL.textColor = [UIColor colorTextFor23272A];
            self.nameL.font = [UIFont semiBoldCustomFontOfSize:14];
            self.contentL.text = [NSString stringWithFormat:@"回复 %@ %@".lv_localized, self.subReplyNameL.text, self.contentL.text];
            [self.contentL xhq_AttributeTextAttributes:
             @{NSFontAttributeName: [UIFont semiBoldCustomFontOfSize:14],
               NSForegroundColorAttributeName: [UIColor colorTextFor23272A]}
                                                 range:NSMakeRange(3, self.subReplyNameL.text.length)];
        } else {
            self.subReplyL.hidden = self.subReplyNameL.hidden = NO;
            self.nameL.textColor = [UIColor colorTextFor23272A];
            self.nameL.font = [UIFont semiBoldCustomFontOfSize:14];
        }
        self.replayBtn.hidden = YES;
    } else {
        self.subReplyL.hidden = self.subReplyNameL.hidden = YES;
        self.nameL.textColor = [UIColor colorMain];
        self.nameL.font = [UIFont semiBoldCustomFontOfSize:14];
        self.replayBtn.hidden = NO;
    }
    [self layoutIfNeeded];
}

- (void)dy_initUI {
    [super dy_initUI];
    
    self.hideSeparatorLabel = YES;
    
    self.headImageV = [[UIImageView alloc] init];
    [self.headImageV xhq_cornerRadius:3];
    [self.contentView addSubview:self.headImageV];
    
    self.nameL = [[UILabel alloc] init];
    self.nameL.textColor = [UIColor colorMain];
    self.nameL.font = [UIFont semiBoldCustomFontOfSize:14];
    self.nameL.text = @"NAME";
    [self.contentView addSubview:self.nameL];
    
    self.subReplyL = [[UILabel alloc] init];
    self.subReplyL.textColor = [UIColor colorFor878D9A];
    self.subReplyL.font = [UIFont semiBoldCustomFontOfSize:14];
    self.subReplyL.text = @"回复".lv_localized;
    [self.contentView addSubview:self.subReplyL];
    
    self.subReplyNameL = [[UILabel alloc] init];
    self.subReplyNameL.textColor = [UIColor colorTextFor23272A];
    self.subReplyNameL.font = [UIFont semiBoldCustomFontOfSize:14];
    [self.contentView addSubview:self.subReplyNameL];
    
    self.timeL = [[UILabel alloc] init];
    self.timeL.font = [UIFont regularCustomFontOfSize:14];
    self.timeL.textColor = [UIColor colorTextForA9B0BF];
    self.timeL.text = @"2020-02-02 20:20:20";
    [self.contentView addSubview:self.timeL];
    
    self.replayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.replayBtn setTitle:@"回复".lv_localized forState:UIControlStateNormal];
    [self.replayBtn setTitleColor:[UIColor colorFor878D9A] forState:UIControlStateNormal];
    self.replayBtn.titleLabel.font = [UIFont semiBoldCustomFontOfSize:14];
    [self.replayBtn addTarget:self action:@selector(subReplyAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.replayBtn];
    
    self.likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.likeBtn setImage:[UIImage imageNamed:@"icon_circle_praise"] forState:UIControlStateNormal];
    [self.likeBtn setImage:[UIImage imageNamed:@"icon_circle_praise_select"] forState:UIControlStateSelected];
    [self.likeBtn setTitle:@"0" forState:UIControlStateNormal];
    [self.likeBtn setTitleColor:[UIColor colorTextFor000000] forState:UIControlStateNormal];
    [self.likeBtn addTarget:self action:@selector(likeReply:) forControlEvents:UIControlEventTouchUpInside];
    self.likeBtn.titleLabel.font = UIFont.xhq_font14;
    [self.contentView addSubview:self.likeBtn];
    
    self.contentL = [[UILabel alloc] init];
    self.contentL.font = [UIFont regularCustomFontOfSize:14];
    self.contentL.textColor = [UIColor colorTextFor000000];
    self.contentL.numberOfLines = 0;
    @weakify(self);
    [self.contentL xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        @strongify(self);
        [self subReplyAction];
    }];
    [self.contentView addSubview:self.contentL];
    
    self.hyb_lastViewInCell = self.contentL;
    self.hyb_bottomOffsetToCell = 10;
    
    [self.headImageV xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        @strongify(self);
        [self seeUserTimeline];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    TimelineInfoReplyCellItem *item = (TimelineInfoReplyCellItem *)self.item;
    [self.headImageV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@15);
        if (item.isSubRepay && !item.isReplyInfo) {
            make.left.equalTo(@60);
        } else {
            make.left.equalTo(@15);
        }
        make.width.height.equalTo(@34);
    }];
    [self.nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headImageV.mas_top);
        make.left.equalTo(self.headImageV.mas_right).offset(10);
        make.height.equalTo(@15);
    }];
    [self.subReplyL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameL.mas_right).offset(5);
        make.centerY.equalTo(self.nameL);
    }];
    [self.subReplyNameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.subReplyL.mas_right).offset(5);
        make.centerY.equalTo(self.nameL);
        make.right.lessThanOrEqualTo(self.likeBtn.mas_left).offset(-5);
    }];
    [self.timeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameL.mas_left);
        make.top.equalTo(self.nameL.mas_bottom).offset(10);
    }];
    [self.replayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.timeL.mas_centerY);
        make.left.equalTo(self.timeL.mas_right).offset(10);
        make.width.equalTo(@50);
        make.height.equalTo(@20);
    }];
    [self.likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.headImageV.mas_centerY);
        make.right.equalTo(self.contentView).offset(-15);
        make.width.equalTo(@30);
        make.height.equalTo(@60);
    }];
    if (self.likeBtn.titleLabel.text.integerValue > 0) {
        [self.likeBtn xhq_setImagePosition:XHQImagePositionTop spacing:2];
    } else {
        [self.likeBtn setTitle:@"" forState:UIControlStateNormal];
    }
    [self.contentL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameL.mas_left);
        make.right.lessThanOrEqualTo(self.contentView).offset(-15);
        make.top.equalTo(self.timeL.mas_bottom).offset(10);
    }];
    if (item.isSubRepay && !item.isReplyInfo) {
        self.contentL.preferredMaxLayoutWidth = kScreenWidth() - 105;
    } else {
        self.contentL.preferredMaxLayoutWidth = kScreenWidth() - 60;
    }
}

- (void)likeReply:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
    BlogReply *reply = (BlogReply *)self.item.cellModel;
    sender.selected = !sender.isSelected;
    reply.liked = sender.selected;
    reply.like_count = sender.isSelected ? reply.like_count + 1 : reply.like_count - 1;
    if (reply.like_count > 0) {
        [self.likeBtn setTitle:[NSString stringWithFormat:@"%ld", reply.like_count] forState:UIControlStateNormal];
        [self.likeBtn xhq_setImagePosition:XHQImagePositionTop spacing:2];
    } else {
        [self.likeBtn setTitle:@"" forState:UIControlStateNormal];
        self.likeBtn.titleEdgeInsets = UIEdgeInsetsZero;
        self.likeBtn.imageEdgeInsets = UIEdgeInsetsZero;
    }
    [TimelineHelper likeReply:reply.ids isLike:sender.isSelected completion:^(BOOL success) {
        if (!success) {
            sender.selected = !sender.isSelected;
            reply.liked = sender.selected;
            reply.like_count = sender.isSelected ? reply.like_count + 1 : reply.like_count - 1;
            if (reply.like_count > 0) {
                [self.likeBtn setTitle:[NSString stringWithFormat:@"%ld", reply.like_count] forState:UIControlStateNormal];
                [self.likeBtn xhq_setImagePosition:XHQImagePositionTop spacing:2];
            } else {
                [self.likeBtn setTitle:@"" forState:UIControlStateNormal];
                self.likeBtn.titleEdgeInsets = UIEdgeInsetsZero;
                self.likeBtn.imageEdgeInsets = UIEdgeInsetsZero;
            }
        }
        sender.userInteractionEnabled = YES;
    }];
}

- (void)subReplyAction {
    TimelineInfoReplyCellItem *item = (TimelineInfoReplyCellItem *)self.item;
    item.username = self.nameL.text;
    !self.responseBlock ? : self.responseBlock();
}

- (void)seeUserTimeline {
    BlogReply *reply = (BlogReply *)self.item.cellModel;
    UserTimelineVC *timeline = [[UserTimelineVC alloc] initWithUserid:reply.user_id];
    [UIViewController.xhq_currentController.navigationController pushViewController:timeline animated:YES];
}

@end
