//
//  MNDelayView.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/8.
//

#import "MNDelayView.h"

@implementation MNDelayView

-(UILabel *)timerLabel{
    if (!_timerLabel) {
        _timerLabel = [[UILabel alloc] init];
        _timerLabel.font = fontSemiBold(16);
        _timerLabel.textColor = [UIColor colorTextFor23272A];
    }
    return _timerLabel;
}

-(UIImageView *)timerIcon{
    if (!_timerIcon) {
        _timerIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    }
    return _timerIcon;
}

@end
