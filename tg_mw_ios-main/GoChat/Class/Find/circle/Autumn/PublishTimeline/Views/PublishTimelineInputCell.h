//
//  PublishTimelineInputCell.h
//  GoChat
//
//  Created by Autumn on 2021/11/4.
//

#import "DYCollectionViewCell.h"
#import "YYText.h"

NS_ASSUME_NONNULL_BEGIN

@interface PublishTimelineInputCellItem : DYCollectionViewCellItem

@end

@interface PublishTimelineInputCell : DYCollectionViewCell

@property (nonatomic, strong) UITextView *textView;

@end

NS_ASSUME_NONNULL_END
