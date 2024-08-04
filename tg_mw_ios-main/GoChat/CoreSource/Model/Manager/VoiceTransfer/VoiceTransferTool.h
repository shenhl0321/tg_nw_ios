//
//  VoiceTransferTool.h
//  GoChat
//
//  Created by apple on 2022/2/16.
//

#import <Foundation/Foundation.h>

@class TransferResModel;
/**
 失败回调
 */
typedef void(^transferFailure)(NSError *error);

/**
 成功回调
 */
typedef void(^transferSuccess)(NSArray<TransferResModel *> *response, NSString *text);

@interface TransferResModel : NSObject
/// 句子相对于本音频的起始时间，单位为ms
@property (nonatomic,assign) NSInteger bg;
/// 句子相对于本音频的终止时间，单位为ms
@property (nonatomic,assign) NSInteger ed;
/// 说话人编号，从1开始，未开启说话人分离时speaker都为0
@property (nonatomic,assign) NSInteger speaker;
/// 句子内容
@property (nonatomic,copy) NSString *onebest;
@end

@interface VoiceTransferTool : NSObject

/// <#code#>
@property (nonatomic,assign, getter=isCanceled) BOOL canceled;
/// 将指定路径的语音转成文字
/// @param path 语音文件路径
- (void)transferInPath:(NSString *)path success:(transferSuccess)success failure:(transferFailure)failure;

/// 取消转换
- (void)cancelTransfer;
@end

