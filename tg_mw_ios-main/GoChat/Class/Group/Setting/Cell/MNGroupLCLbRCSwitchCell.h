//
//  MNGroupLCLbRCSwitchCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/15.
//

#import "BaseTableCell.h"
#import "ASwitch.h"

@class MNGroupLCLbRCSwitchCell;
typedef void (^MNGroupSwitchBlock)(MNGroupLCLbRCSwitchCell *cell,ASwitch *aSwith,BOOL isOn,NSString *rowName);
NS_ASSUME_NONNULL_BEGIN

@interface MNGroupLCLbRCSwitchCell : BaseTableCell
<ASwitchDelegate>
@property (nonatomic, strong) UILabel *lcLabel;
@property (nonatomic, strong) ASwitch *rcSwitch;
@property (nonatomic, copy) NSString *rowName;
@property(nonatomic, copy) MNGroupSwitchBlock groupSwitchBlock;

//- (void)fillDataWithRowName:(NSString *)rowName;

@end

NS_ASSUME_NONNULL_END
