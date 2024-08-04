#import <Foundation/Foundation.h>
#import "BusinessListenerProtocol.h"
#import "BusinessModuleProtocol.h"

//业务框架，用于分发业务事件和获取业务数据
@interface BusinessFramework : NSObject {
 @private
    NSMutableDictionary* businessModuleDict_;
    NSMutableArray* businessListenerArray_;
}

//获取默认的业务框架句柄
+ (id)defaultBusinessFramework;

//释放业务框架资源
+ (void)releaseDefaultBusinessFramework;

//初始化
- (id)init;

//注册业务模块
- (void)registerBusinessModule:(id<BusinessModuleProtocol>) businessModule;

//注册业务事件监听对象
- (void)registerBusinessListener:(id<BusinessListenerProtocol>) businessListener;

//取消某个业务事件监听对象
- (void)unregisterBusinessListener:(id<BusinessListenerProtocol>)businessListener;

//在所有业务事件监听对象上广播业务通知
- (void)broadcastBusinessNotify:(int)notifcationId withInParam:(id)inParam;

//调用具体某个业务处理，需要返回输出参数
- (int)callBusinessProcess:(int)funcId withInParam:(id)inParam andOutParam:(id*)outParam;

//调用具体某个业务处理，不需要返回输出参数
- (int)callBusinessProcess:(int)funcId withInParam:(id)inParam;

@end
