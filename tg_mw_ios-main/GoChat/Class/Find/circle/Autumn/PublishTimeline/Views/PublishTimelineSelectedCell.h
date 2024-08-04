//
//  PublishTimelineSelectedCell.h
//  GoChat
//
//  Created by Autumn on 2021/11/4.
//

#import "DYCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PublishTimelineSelectedCellItem : DYCollectionViewCellItem

@property (nonatomic, copy) NSString *content;

@property (nonatomic, assign, getter=isChangeColor) BOOL changeColor;

@end

@interface PublishTimelineSelectedCell : DYCollectionViewCell

@end

NS_ASSUME_NONNULL_END
