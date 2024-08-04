//
//  DeviceListCell.m
//  GoChat
//
//  Created by Autumn on 2022/2/9.
//

#import "DeviceListCell.h"
#import "SessionDevice.h"
#import "TimeFormatting.h"

@implementation DeviceListCellItem

- (CGFloat)cellHeight {
    return 90;
}

@end

@interface DeviceListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *deviceIcon;
@property (weak, nonatomic) IBOutlet UILabel *deviceName;
@property (weak, nonatomic) IBOutlet UILabel *systemVersion;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;


@end

@implementation DeviceListCell

- (void)setItem:(DYTableViewCellItem *)item {
    [super setItem:item];
    DeviceListCellItem *m = (DeviceListCellItem *)item;
    SessionDevice *s = (SessionDevice *)item.cellModel;
    _deviceName.text = s.device_model;
    _systemVersion.text = s.versionText;
    
    NSString *time = s.is_current ? @"当前在线".lv_localized : [TimeFormatting formatTimeWithTimeInterval:s.last_active_date];;
    _descLabel.text = [NSString stringWithFormat:@"%@ · %@", s.country, time];
    if (m.isEdit) {
        _deviceIcon.image = [UIImage imageNamed:@"icon_device_remove"];
    } else {
        _deviceIcon.image = s.deviceIcon;
    }
    
//    DeviceListCellItem *m = (DeviceListCellItem *)item;
//    if (m.position == DeviceListCellPosition_Middle) {
//        [self xhq_roundCorners:UIRectCornerAllCorners radius:0];
//        return;
//    }
//    UIRectCorner corner;
//    if (m.position == DeviceListCellPosition_Top) {
//        corner = UIRectCornerTopLeft | UIRectCornerTopRight;
//    } else if (m.position == DeviceListCellPosition_Bottom) {
//        corner = UIRectCornerBottomLeft | UIRectCornerBottomRight;
//    } else {
//        corner = UIRectCornerAllCorners;
//    }
//    [self xhq_roundCorners:corner radius:10];
}

- (void)dy_initUI {
    [super dy_initUI];
    
    self.hideSeparatorLabel = YES;
    @weakify(self);
    [_deviceIcon xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        @strongify(self);
        DeviceListCellItem *m = (DeviceListCellItem *)self.item;
        if (m.isEdit) {
            !self.responseBlock ? : self.responseBlock();
        }
    }];
}


@end
