//
//  CallManager.h
//  GoChat
//
//  Created by wangyutao on 2021/3/1.
//

#import <Foundation/Foundation.h>

@interface CallManager : NSObject
+ (CallManager *)shareInstance;
- (void)reset;

//新来电
- (void)newIncomingCall:(RemoteCallInfo *)remoteCall;
//对方取消通话
- (void)cancelCall:(RemoteCallInfo *)remoteCall;
//对方离开通话
- (void)leaveCall:(RemoteCallInfo *)remoteCall;
//接听电话
- (void)acceptNewCall;

//是否可以发起新call
- (BOOL)canNewCall;
//是否正在通话
- (BOOL)isInCalling;
//发起新call
- (void)newCall:(LocalCallInfo *)call fromView:(UIViewController *)from;
//结束call
- (void)endCurrentCall;
//获得当前通话状态
- (CallingState)currentCallState;
//检测耳机是否可用
- (BOOL)hasHeadset;
//切换麦克风模式
- (void)enableSpeaker:(BOOL)speaker;
- (BOOL)isEnableSpeaker;
//是否静音
- (void)muteLocalAudio;
- (BOOL)isMuteLocalAudio;
//是否禁止本地视频
- (void)muteLocalVideo:(BOOL)mute;
//摄像头切换
- (void)toggleCamera;
//显示本地视频
- (void)showLocalVideoToView:(UIView *)view;
//显示本地视频
- (void)showRemoteVideoToView:(UIView *)view;
//获取通话时间
- (NSString *)callDisplayTime;

//获得c2c user
- (UserInfo *)c2cUser;
//获得c2c userid
- (long)c2cUserId;
//是否视频
- (BOOL)isVideo;
//是否来电
- (BOOL)isIncoming;

//显示置顶小窗口
- (void)showSmallTopView;
//隐藏置顶小窗口
- (void)hideSmallTopView;
//关闭置顶小窗口
- (void)removeSmallTopView;
//是否存在了置顶小窗口
- (BOOL)isHaveSmallTopView;
//小窗口目前的rect
- (CGRect)smallTopViewRect;
@end
