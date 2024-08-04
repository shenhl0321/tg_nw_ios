//
//  VoiceTransferRequest.h
//  GoChat
//
//  Created by apple on 2022/2/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 失败回调
 */
typedef void(^XFResponseFailureBlock)(NSError *error);

/**
 成功回调
 */
typedef void(^XFResponseSuccessBlock)(id response);

@interface VoiceTransferRequest : NSObject



/// 预处理接口
/// @param fileLen 文件大小（单位：字节）
/// @param fileName 文件名称（带后缀）
+ (NSURLSessionTask *)prepareWithLen:(NSInteger)fileLen fileName:(NSString *)fileName success:(XFResponseSuccessBlock)success failure:(XFResponseFailureBlock)failure ;

/// 文件分片上传接口
/// @param taskId 任务ID（预处理接口返回值）
/// @param sliceId 分片序号
/// @param content 分片文件内容
/// @param filePath 文件路径
+ (NSURLSessionUploadTask *)uploadWithTaskId:(NSString *)taskId sliceId:(NSString *)sliceId content:(NSData *)content filePath:(NSString *)filePath success:(XFResponseSuccessBlock)success failure:(XFResponseFailureBlock)failure;

/// 合并文件接口
/// @param taskId 任务ID（预处理接口返回值）
+ (NSURLSessionTask *)mergeWithTaskId:(NSString *)taskId  success:(XFResponseSuccessBlock)success failure:(XFResponseFailureBlock)failure;

/// 查询处理进度接口
/// @param taskId 任务ID（预处理接口返回值）
+ (NSURLSessionTask *)getProgressWithTaskId:(NSString *)taskId  success:(XFResponseSuccessBlock)success failure:(XFResponseFailureBlock)failure;

/// 查询处理进度接口
/// @param taskId 任务ID（预处理接口返回值）
+ (NSURLSessionTask *)getResultWithTaskId:(NSString *)taskId  success:(XFResponseSuccessBlock)success failure:(XFResponseFailureBlock)failure;


@end

NS_ASSUME_NONNULL_END
