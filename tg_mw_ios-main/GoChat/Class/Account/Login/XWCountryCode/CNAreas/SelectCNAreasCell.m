//
//  SelectCNAreasCell.m
//  GoChat
//
//  Created by Autumn on 2022/3/12.
//

#import "SelectCNAreasCell.h"
#import "CNAreasModel.h"

@implementation SelectCNAreasCellItem

- (CGFloat)cellHeight {
    return 60;
}

@end

@interface SelectCNAreasCell ()

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation SelectCNAreasCell

- (void)setItem:(DYTableViewCellItem *)item {
    [super setItem:item];
    SelectCNAreasCellItem *m = (SelectCNAreasCellItem *)item;
    CNAreasModel *mm = (CNAreasModel *)item.cellModel;
    _nameLabel.text = mm.name;
    self.accessoryType = m.isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}


- (void)dy_initUI {
    [super dy_initUI];
    
    [self dy_noneSelectionStyle];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

@end
