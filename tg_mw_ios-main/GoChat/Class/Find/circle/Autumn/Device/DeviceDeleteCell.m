//
//  DeviceDeleteCell.m
//  GoChat
//
//  Created by Autumn on 2022/2/15.
//

#import "DeviceDeleteCell.h"


@implementation DeviceDeleteCellItem

- (CGFloat)cellHeight {
    return 100;
}

@end

@interface DeviceDeleteCell ()

@property (strong, nonatomic) IBOutlet UIButton *deleteButton;


@end

@implementation DeviceDeleteCell

- (void)dy_initUI {
    [super dy_initUI];
    [self dy_noneSelectionStyle];
    [self.deleteButton xhq_cornerRadius:5];
    [self.deleteButton xhq_borderColor:XHQHexColor(0xFD4E57) borderWidth:0.8];
}

- (IBAction)deleteAction:(id)sender {
    !self.responseBlock ? : self.responseBlock();
}


@end
