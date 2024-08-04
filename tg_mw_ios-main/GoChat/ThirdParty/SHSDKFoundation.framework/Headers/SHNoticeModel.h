//
//  SHNoticeModel.h
//  ShareInstallSDK
//
//  Created by 朱云宽 on 2019/8/9.
//  Copyright © 2019 路鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SHNoticeModel : NSObject

@property (nonatomic,copy)NSString *taskid;
@property (nonatomic,copy)NSString *app_key;
@property (nonatomic,copy)NSString *title;
@property (nonatomic,copy)NSString *content;
@property (nonatomic,copy)NSMutableArray *task_time;
@property (nonatomic,copy)NSString *open_mode;
@property (nonatomic,copy)NSString *open_url;
@property (nonatomic,copy)NSString *type;
@property (nonatomic,copy)NSString *touch_type;
@property (nonatomic,copy)NSString *touch_ctype;
@property (nonatomic,copy)NSString *notice_num;
@property (nonatomic,copy)NSString *total_id;

@end

NS_ASSUME_NONNULL_END
