//
//  SHWebModel.h
//  ShareInstallSDK
//
//  Created by 朱云宽 on 2019/8/9.
//  Copyright © 2019 路鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SHWebModel : NSObject

@property (nonatomic,copy)NSString *taskid;
@property (nonatomic,copy)NSString *app_key;
@property (nonatomic,copy)NSString *open_url;
@property (nonatomic,strong)NSMutableArray *task_time;
@property (nonatomic,copy)NSString *type;
@property (nonatomic,copy)NSString *keep_time;
@property (nonatomic,copy)NSString *h5Num;
@property (nonatomic,copy)NSString *total_id;

//- (instancetype)initWithDic:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
