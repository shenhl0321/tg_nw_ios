//
//  PublishTimelineInputCell.m
//  GoChat
//
//  Created by Autumn on 2021/11/4.
//

#import "PublishTimelineInputCell.h"
#import "PublishTimeline.h"


@implementation PublishTimelineInputCellItem

- (CGSize)cellSize {
    return CGSizeMake(kScreenWidth() - 40, 120);
}

@end


@interface PublishTimelineInputCell ()

@end

@implementation PublishTimelineInputCell

- (void)dy_initUI {
    [super dy_initUI];
    
    _textView = ({
        UITextView *view = UITextView.new;
//        view.delegate = self;
        view.font = UIFont.xhq_font16;
        view.textColor = XHQHexColor(0x04020C);
//        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
//        [text yy_setFont:UIFont.xhq_font16 range:NSMakeRange(0, 0)];
//        [text yy_setColor:XHQHexColor(0x04020C) range:NSMakeRange(0, 0)];
//        view.attributedText = text;
//        view.placeholderText = @"说点什么...";
        view.zw_placeHolder = @"说点什么...".lv_localized;
        view;
    });
    [self addSubview:_textView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

@end
