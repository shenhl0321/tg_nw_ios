//
//  CreateTagsTitleCell.m
//  GoChat
//
//  Created by Autumn on 2021/11/9.
//

#import "CreateTagsTitleCell.h"

@implementation CreateTagsTitleCellItem

- (CGSize)cellSize {
    return CGSizeMake(kScreenWidth(), 45);
}

@end


@interface CreateTagsTitleCell ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;

@end

@implementation CreateTagsTitleCell

- (void)dy_initUI {
    [super dy_initUI];
    _textField = ({
        UITextField *view = UITextField.new;
        view.placeholder = @"例如家人、朋友".lv_localized;
        view.font = [UIFont systemFontOfSize:15];
        view.textColor = UIColor.xhq_aTitle;
        [view setMylimitCount:@200];
        view.delegate = self;
        [view addTarget:self action:@selector(textContentChanged:) forControlEvents:UIControlEventEditingChanged];
        view;
    });
    [self addSubview:_textField];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 20, 0, 20));
    }];
}

- (void)textContentChanged:(UITextField *)textField {
    CreateTagsTitleCellItem *m = (CreateTagsTitleCellItem *)self.item;
    m.title = textField.text;
    !self.responseBlock ? : self.responseBlock();
}


- (void)setItem:(DYCollectionViewCellItem *)item {
    [super setItem:item];
    
    CreateTagsTitleCellItem *m = (CreateTagsTitleCellItem *)item;
    _textField.text = m.title;
}

@end
