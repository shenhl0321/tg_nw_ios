//
//  ModifyFieldForMultiLineViewController.h
//  GoChat
//
//  Created by wangyutao on 2020/12/4.
//

#import "BaseTableVC.h"

typedef enum {
    //=群公告
    ModifyFieldForMultiLineType_Set_Group_Pinned_Message = 0,
    //群敏感词屏蔽设置
    Group_ShieldSensitiveWordsManagerStyle
} ModifyFieldForMultiLineType;

@interface ModifyFieldForMultiLineViewController : BaseTableVC
@property (nonatomic) ModifyFieldForMultiLineType fieldType;
@property (nonatomic) long chatId;
@property (nonatomic, copy) NSString *prevValueString;
@end
