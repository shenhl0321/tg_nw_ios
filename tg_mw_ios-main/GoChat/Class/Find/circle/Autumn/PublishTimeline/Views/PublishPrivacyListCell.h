//
//  PublishPrivacyListCell.h
//  GoChat
//
//  Created by Autumn on 2021/11/5.
//

#import "DYTableViewCell.h"
#import "PublishTimeline.h"

NS_ASSUME_NONNULL_BEGIN


@interface PublishPrivacyListCellItem : DYTableViewCellItem

@property (nonatomic, assign) VisibleType type;
@property (nonatomic, assign, getter=isSelected) BOOL selected;

@end


@interface PublishPrivacyListCell : DYTableViewCell

@end

NS_ASSUME_NONNULL_END
