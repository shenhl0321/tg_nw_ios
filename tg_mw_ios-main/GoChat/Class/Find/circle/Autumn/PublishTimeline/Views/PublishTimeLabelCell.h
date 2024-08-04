//
//  PublishTimeLabelCell.h
//  GoChat
//
//  Created by Autumn on 2022/3/5.
//

#import "DYCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PublishTimeLabelType) {
    PublishTimeLabelType_At,
    PublishTimeLabelType_Topic,
};

@interface PublishTimeLabelCellItem : DYCollectionViewCellItem

@property (nonatomic, assign) PublishTimeLabelType label;

@end


@interface PublishTimeLabelCell : DYCollectionViewCell

@end

NS_ASSUME_NONNULL_END
