#import <Foundation/Foundation.h>

#import "BusinessModuleInfo.h"

//业务模块协议接口
@protocol BusinessModuleProtocol

//初始化业务模块
- (int)initBusinessModule:(BusinessModuleInfo*)info;

//调用业务模块功能处理
- (int)callBusinessProcess:(int)capabilityId withInParam:(id)inParam andOutParam:(id*)outParam;

@optional

- (int)callBusinessDataProcess:(int)capabilityId withInParam:(id)inParam andOutParam:(id*)outParam;

@end
