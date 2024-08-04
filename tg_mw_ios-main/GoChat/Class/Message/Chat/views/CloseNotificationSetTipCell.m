//
//  CloseNotificationSetTipCell.m
//  GoChat
//
//  Created by wangyutao on 2021/2/22.
//

#import "CloseNotificationSetTipCell.h"

@interface CloseNotificationSetTipCell ()
@property (weak, nonatomic) IBOutlet UILabel *aLabel;

@end
@implementation CloseNotificationSetTipCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.aLabel.textColor = [UIColor colorMain];
    self.aLabel.font = fontRegular(14);
}

- (IBAction)click_close:(id)sender
{
//    if([self.delegate respondsToSelector:@selector(CloseNotificationSetTipCell_Remove:)])
//    {
//        [self.delegate CloseNotificationSetTipCell_Remove:self];
//    }
}

@end
