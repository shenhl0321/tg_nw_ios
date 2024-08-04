//
//  ModifyFieldViewController.h
//  GoChat
//
//  Created by wangyutao on 2020/12/4.
//

#import "BaseViewController.h"
#import "GC_ModifyFieldVC.h"


@interface ModifyFieldViewController : BaseTableVC
@property (nonatomic) ModifyFieldType fieldType;
@property (nonatomic) long chatId;
@property (nonatomic, copy) NSString *prevValueString;
@property (nonatomic, strong) UserInfo *toBeModifyUser;
@end
