//
//  PublishTimelineMediaCell.h
//  GoChat
//
//  Created by Autumn on 2021/11/4.
//

#import "DYCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PublishTimelineMediaCellItem : DYCollectionViewCellItem

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign, getter=isVideo) BOOL video;

@end

@interface PublishTimelineMediaCell : DYCollectionViewCell

@end

NS_ASSUME_NONNULL_END
