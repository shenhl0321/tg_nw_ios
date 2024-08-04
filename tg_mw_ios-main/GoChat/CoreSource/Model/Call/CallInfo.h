//
//  CallInfo.h
//  GoChat
//
//  Created by wangyutao on 2021/2/25.
//

#import <Foundation/Foundation.h>

//通话过程状态定义
typedef enum {
    CallingState_Init = 1, //初始状态
    CallingState_None, //无状态
    CallingState_Outgoing_Prepare, //呼出准备中
    CallingState_Outgoing_Prepare_error,//呼出准备失败
    CallingState_Outgoing_Calling, //呼出中，等待对方接听
    CallingState_Incoming_Waiting, //来电等待中
    CallingState_Incoming_Prepare, //来电接听前准备中
    CallingState_Canceled, //自己取消
    CallingState_Canceled_2_Timeout, //对方无应答\自己超时
    CallingState_C2C_Canceled, //对方取消
    CallingState_In_Calling, //通话中
    CallingState_Call_End, //通话结束
} CallingState;

@interface CallBaseInfo : NSObject
//通话标识
@property (nonatomic) long callId;
//频道名称
@property (nonatomic, copy) NSString *channelName;
//通话发起者userid
@property (nonatomic) long from;
//邀请对象，userid list
@property (nonatomic, strong) NSArray *to;
//归属chat，可以为0
@property (nonatomic) long chatId;
//是否视频
@property (nonatomic) BOOL isVideo;
//是否多人会议
@property (nonatomic) BOOL isMeetingAV;

- (long)getRealChatId;
- (NSString *)done_jsonForMessage;
@end

@interface RemoteCallInfo : CallBaseInfo
@property (nonatomic) long createAt;  //创建时间10位时间戳
@property (nonatomic) long closeAt;   //关闭时间10位时间戳
@property (nonatomic) long enterAt;   //进入时间10位时间戳
@property (nonatomic) long leaveAt;   //离开时间10位时间戳
//查询历史记录时，无效
@property (nonatomic) BOOL isTimeOut; //是否已经超时
@end

@interface LocalCallInfo : CallBaseInfo
@property (nonatomic, copy) NSString *rtcToken;
//是否已取消
//@property (nonatomic) BOOL isCanceled;
//呼叫时间
@property (nonatomic) long callTime;
//开始通话时间
@property (nonatomic) long startTime;
//结束通话时间
@property (nonatomic) long endTime;
//通话状态
@property (nonatomic) CallingState callState;
//
@property (nonatomic) BOOL isSendedLocalMsg;
//来电场景-加入房间后的超时处理
@property (nonatomic) long incoming_join_time;

- (NSString *)displayDesc;
- (NSString *)displayDetailDesc;
- (NSString *)displayCallTime;
+ (instancetype)callWithRemote:(RemoteCallInfo *)call;
@end
