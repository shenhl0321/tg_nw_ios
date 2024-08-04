//
//  UserTimelineInfoCell.h
//  GoChat
//
//  Created by Autumn on 2021/12/15.
//

#import "DYCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserTimelineInfoCellItem : DYCollectionViewCellItem

@property (nonatomic, assign) NSInteger userid;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) UserInfoExt *ext;

@property (nonatomic, assign, getter=isDisplayAllDesc) BOOL displayAllDesc;

@end

@interface UserTimelineInfoCell : DYCollectionViewCell

@end

NS_ASSUME_NONNULL_END
