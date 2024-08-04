//
//  TransferNoteCell.m
//  GoChat
//
//  Created by Autumn on 2022/1/18.
//

#import "TransferNoteCell.h"
#import "TransferObject.h"

@implementation TransferNoteCellItem

- (CGFloat)cellHeight {
    return 50;
}


@end

@interface TransferNoteCell ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;

@end

@implementation TransferNoteCell

- (void)dy_initUI {
    [super dy_initUI];
    [self dy_noneSelectionStyle];
    self.hideSeparatorLabel = YES;
    _textView = ({
        UITextView *view = UITextView.new;
        view.delegate = self;
        view.font = [UIFont regularCustomFontOfSize:15];
        view.textColor = UIColor.colorTextFor23272A;
        view.zw_placeHolder = @"添加转账说明".lv_localized;
        view.zw_placeHolderColor = XHQHexColor(0xA9B0BF);
        view;
    });
    [self addSubview:_textView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.leading.mas_equalTo(25);
        make.trailing.mas_equalTo(-25);
    }];
}

- (void)textViewDidChange:(UITextView *)textView {
    TransferObject *obj = (TransferObject *)self.item.cellModel;
    obj.descriptions = textView.text;
}

@end
