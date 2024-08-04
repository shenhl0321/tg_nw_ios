//
//  SelectMemberCell.h
//  GoChat
//
//  Created by Autumn on 2021/11/7.
//

#import "DYTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectMemberCellItem : DYTableViewCellItem

@property (nonatomic, assign, getter=isSelected) BOOL selected;

@property (nonatomic, strong) UserInfo *member;
@property (nonatomic, strong) ChatInfo *group;

@property (nonatomic, strong) UIImage *image;

@end

@interface SelectMemberCell : DYTableViewCell

@end

NS_ASSUME_NONNULL_END
