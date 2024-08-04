//
//  GC_MySetSwitchCell.h
//  GoChat
//
//  Created by wangfeiPro on 2021/12/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SetSwitchBlock)(BOOL isOn);

@interface GC_MySetSwitchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UISwitch *openSwitch;

@property (nonatomic, copy) SetSwitchBlock switchBlock;

@end

NS_ASSUME_NONNULL_END
