//
//  TF_CommonSettingCell.h
//  GoChat
//
//  Created by apple on 2022/1/28.
//

#import <UIKit/UIKit.h>


typedef enum{
    TF_settingTipTypeNone = 0,
    TF_settingTipTypeArrow,
    TF_settingTipTypeSwith,
} TF_settingTipType;


@interface TF_settingModel : NSObject

/// 标题名称-左侧文字
@property (nonatomic,copy) NSString *title;
/// 提示值 - 右侧文字内容
@property (nonatomic,copy) NSString *tipValue;
/// 跳转目标控制器的名称
@property (nonatomic,copy) NSString *targetVC;
/// 右侧提示形式，默认是没有
@property (nonatomic,assign) TF_settingTipType tipType;
/// switch开关状态
@property (nonatomic,assign) BOOL switchOn;
/// cell对应的模型属性
@property (nonatomic,strong) id model;
/// 身份特殊标记
@property (nonatomic,copy) NSString *identityName;

@end

@interface TF_CommonSettingCell : UITableViewCell

/// 数据模型
@property (nonatomic,strong) TF_settingModel *model;
/// 按钮点击事件回调
@property (nonatomic,copy) void(^controlCall)(TF_settingModel *model);

@end


@interface TF_SettingSectionHeaderV : UITableViewHeaderFooterView
/// 标题
@property (nonatomic,copy) NSString *title;
@end

