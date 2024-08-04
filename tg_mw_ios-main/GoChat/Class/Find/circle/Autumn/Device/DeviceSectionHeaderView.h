//
//  DeviceSectionHeaderView.h
//  GoChat
//
//  Created by mac on 2022/2/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DeviceSessionTerminal) {
    Current = 0,
    Other
};

@interface DeviceSectionHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, assign) DeviceSessionTerminal terminal;

@end

NS_ASSUME_NONNULL_END
