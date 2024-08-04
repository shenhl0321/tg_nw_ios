//
//  PublishPrivacyTagsCell.m
//  GoChat
//
//  Created by Autumn on 2021/11/15.
//

#import "PublishPrivacyTagsCell.h"
#import "BlogUserGroup.h"
#import "UserinfoHelper.h"
#import "CreateTagsVC.h"

@implementation PublishPrivacyTagsCellItem

- (CGFloat)cellHeight {
    return 60;
}

@end

@interface PublishPrivacyTagsCell ()

@property (nonatomic, strong) UIImageView *selectedImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIButton *settingButton;

@end

@implementation PublishPrivacyTagsCell

- (void)dy_initUI {
    [super dy_initUI];
    
    [self dy_noneSelectionStyle];
    self.hideSeparatorLabel = true;
    
    _selectedImageView = ({
        UIImageView *iv = [[UIImageView alloc] init];
        iv;
    });
    _titleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.xhq_aTitle;
        label.font = UIFont.xhq_font16;
        label;
    });
    _subtitleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.xhq_content;
        label.font = UIFont.xhq_font12;
        label;
    });
    _settingButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"nav_setting"] forState:UIControlStateNormal];
        [btn xhq_addTarget:self action:@selector(settingAction)];
        btn;
    });
    [self addSubview:_selectedImageView];
    [self addSubview:_titleLabel];
    [self addSubview:_subtitleLabel];
    [self addSubview:_settingButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(35);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(15);
    }];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_centerY).offset(-2);
        make.leading.mas_equalTo(_selectedImageView.mas_trailing).offset(15);
    }];
    [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_titleLabel);
        make.top.mas_equalTo(self.mas_centerY).offset(2);
    }];
    [_settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.trailing.mas_equalTo(-15);
        make.size.mas_equalTo(40);
    }];
}

- (void)settingAction {
    BlogUserGroup *group = (BlogUserGroup *)self.item.cellModel;
    CreateTagsVC *tags = [[CreateTagsVC alloc] init];
    tags.type = CreateTagsTypeEdit;
    tags.tagName = group.title;
    tags.tagId = (int)group.ids;
    tags.selectedContacts = group.userinfos;
    [self.xhq_currentController.navigationController pushViewController:tags animated:YES];
}

- (void)setItem:(DYTableViewCellItem *)item {
    [super setItem:item];
    PublishPrivacyTagsCellItem *m = (PublishPrivacyTagsCellItem *)item;
    _selectedImageView.image = [UIImage imageNamed:m.isSelected ? @"icon_choose_sel" : @"icon_choose"];
    BlogUserGroup *group = (BlogUserGroup *)m.cellModel;
    _titleLabel.text = group.title;
    if (group.usernames.count > 0) {
        _subtitleLabel.text = [group.usernames componentsJoinedByString:@"，"];
    } else {
        [UserinfoHelper getUsernames:group.users completion:^(NSArray * _Nonnull names) {
            group.usernames = names;
            self.subtitleLabel.text = [names componentsJoinedByString:@"，"];
        }];
    }
}

@end
