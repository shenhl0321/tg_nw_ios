//
//  DeviceListCell.h
//  GoChat
//
//  Created by Autumn on 2022/2/9.
//

#import "DYTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DeviceListCellPosition) {
    DeviceListCellPosition_Middle = 0,
    DeviceListCellPosition_Top,
    DeviceListCellPosition_Bottom,
    DeviceListCellPosition_Only
};

@interface DeviceListCellItem : DYTableViewCellItem

@property (nonatomic, assign) DeviceListCellPosition position;

@property (nonatomic, assign, getter=isEdit) BOOL edit;

@end

@interface DeviceListCell : DYTableViewCell

@end

NS_ASSUME_NONNULL_END
