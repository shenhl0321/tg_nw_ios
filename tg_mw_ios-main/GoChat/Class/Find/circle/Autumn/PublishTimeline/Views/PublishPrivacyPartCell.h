//
//  PublishPrivacyPartCell.h
//  GoChat
//
//  Created by Autumn on 2021/11/5.
//

#import "DYTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PublishPrivacyPartType) {
    PublishPrivacyPartTypeGroup,
    PublishPrivacyPartTypeContact
};

@interface PublishPrivacyPartCellItem : DYTableViewCellItem

@property (nonatomic, strong) NSArray *names;
@property (nonatomic, assign) PublishPrivacyPartType type;

@end

@interface PublishPrivacyPartCell : DYTableViewCell

@end

NS_ASSUME_NONNULL_END
