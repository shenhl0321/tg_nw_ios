#import <Foundation/Foundation.h>

//业务事件监听协议接口
@protocol BusinessListenerProtocol 

- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam;

@end
