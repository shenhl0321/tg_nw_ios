//
//  PublishPrivacyTagsCell.h
//  GoChat
//
//  Created by Autumn on 2021/11/15.
//

#import "DYTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PublishPrivacyTagsCellItem : DYTableViewCellItem

@property (nonatomic, assign, getter=isSelected) BOOL selected;

@end

@interface PublishPrivacyTagsCell : DYTableViewCell

@end

NS_ASSUME_NONNULL_END
