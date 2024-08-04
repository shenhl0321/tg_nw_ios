//
//  GC_ModifyFieldVC.h
//  GoChat
//
//  Created by wangfeiPro on 2022/1/5.
//

#import "BaseVC.h"

typedef enum {
    ModifyFieldType_Set_My_Nickname = 0,
    ModifyFieldType_Set_My_Username,
    ModifyFieldType_Set_Group_Name,
    ModifyFieldType_Set_Group_Nickname,
    ModifyFieldType_Set_User_NickName,
} ModifyFieldType;

NS_ASSUME_NONNULL_BEGIN

@interface GC_ModifyFieldVC : BaseVC

@property (nonatomic) ModifyFieldType fieldType;
@property (nonatomic) long chatId;
@property (nonatomic, copy) NSString *prevValueString;
@property (nonatomic, strong) UserInfo *toBeModifyUser;

@end

NS_ASSUME_NONNULL_END
