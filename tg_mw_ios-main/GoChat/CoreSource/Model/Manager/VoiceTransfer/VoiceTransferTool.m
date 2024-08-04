//
//  VoiceTransferTool.m
//  GoChat
//
//  Created by apple on 2022/2/16.
//

#import "VoiceTransferTool.h"
#import "FileStreamOperation.h"
#import "SliceIdGenerator.h"
#import "TF_Timer.h"
#import "PermenantThread.h"
#import "VoiceTransferRequest.h"


@implementation TransferResModel

@end

@interface VoiceTransferTool()

@property(strong,nonatomic) FileStreamOperation *fileStreamer;

@property(assign,nonatomic) NSInteger currentIndex;
/// 任务id
@property (nonatomic,copy) NSString *taskId;
/// 定时器名称
@property (nonatomic,copy) NSString *taskName;
/// 处理线程
@property (strong, nonatomic) PermenantThread *thread;
/// <#code#>
@property (nonatomic,copy) transferFailure failureCall;
/// <#code#>
@property (nonatomic,copy) transferSuccess successCall;
/// <#code#>
@property (nonatomic,assign, getter=isFailured) BOOL failured;

@property (strong, nonatomic) dispatch_semaphore_t semaphore;

/// <#code#>
@property (nonatomic,strong) NSURLSessionUploadTask *uploadTask;
/// <#code#>
@property (nonatomic,strong) NSURLSessionTask *sessionTask;
@end

@implementation VoiceTransferTool

- (instancetype)init{
    if (self = [super init]) {
        self.thread = [[PermenantThread alloc] init];
    }
    return self;
}

- (void)transferInPath:(NSString *)path success:(transferSuccess)success failure:(transferFailure)failure{
    FileStreamOperation *fileStreamer = [[FileStreamOperation alloc] initFileOperationAtPath:path forReadOperation:YES];
    self.fileStreamer = fileStreamer;
    self.successCall = success;
    self.failureCall = failure;
    
    [self.thread executeTask:^{
        self.canceled = NO;
        // 预处理
        self.sessionTask = [VoiceTransferRequest prepareWithLen:fileStreamer.fileSize fileName:fileStreamer.fileName success:^(NSString *taskId) {
            self.taskId = taskId;
            // 上传
            [self uploadSuccess:^(id response) {
                // 合并
                self.sessionTask = [VoiceTransferRequest mergeWithTaskId:self.taskId success:^(id response) {
                    // 获取处理进度
                    [self getProgressSuccess:^(id response) {
                        // 查询结果
                        self.sessionTask = [VoiceTransferRequest getResultWithTaskId:self.taskId success:^(NSArray *response) {

                            NSArray<TransferResModel *> *res = [TransferResModel mj_objectArrayWithKeyValuesArray:response];
                            NSMutableArray *texts = [NSMutableArray array];
                            for (TransferResModel *result in res) {
                                [texts addObject:result.onebest];
                            }
                            if (self.successCall) {
                                self.successCall(response, [texts componentsJoinedByString:@""]);
                            }
                        } failure:self.failureCall];
                    }];
                } failure:self.failureCall];
            }];
        } failure:self.failureCall];
    }];
    
    
    
//    [self.thread executeTask:^{
//        self.semaphore = dispatch_semaphore_create(5);
//        // 预处理
//        [self prepareDeal];
//        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
//        if (self.isFailured) {
//            return;
//        }
//        [self uploadVoice];
//        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
//        if (self.isFailured) {
//            return;
//        }
//        [self merge];
//        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
//        if (self.isFailured) {
//            return;
//        }
//        [self getProgressSuccess:^(id  _Nonnull response) {
//            [self getResult];
//        }];
//
//    }];
//
}

- (void)cancelTransfer{
    if (self.isCanceled) {
        return;
    }
    [self.uploadTask cancel];
    [self.sessionTask cancel];
    self.canceled = YES;
}

- (void)uploadSuccess:(XFResponseSuccessBlock)success{
    [self.thread executeTask:^{
        SliceIdGenerator *ger = [[SliceIdGenerator alloc] init];
        __block NSInteger staus = 0;
        while (true) {
            if (staus > 0) {
                break;
            }
            if (self.currentIndex < self.fileStreamer.fileFragments.count) {
                if (self.fileStreamer.fileFragments[self.currentIndex].fragmentStatus == FileUpStateWaiting) {
                    self.fileStreamer.fileFragments[self.currentIndex].fragmentStatus = FileUpStateLoading;
                    NSData *data = [self.fileStreamer readDateOfFragment:self.fileStreamer.fileFragments[self.currentIndex]];
                    NSString *sliceId = [ger getNextSliceId];
                    self.uploadTask = [VoiceTransferRequest uploadWithTaskId:self.taskId sliceId:sliceId content:data filePath:self.fileStreamer.filePath success:^(id response) {
                        self.currentIndex++;
                    } failure:^(NSError *error) {
                        staus = 2;
                    }];
                    
                }
            } else {
                staus = 1;
                break;
            }
        }
        if (staus == 1) {
            if (success) {
                success(@"1");
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"ErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"上传失败".lv_localized}];
            if (self.failureCall) {
                self.failureCall(error);
            }
        }
    }];
}

- (void)getProgressSuccess:(XFResponseSuccessBlock)success{
    self.taskName = [TF_Timer execTask:^{
        self.sessionTask = [VoiceTransferRequest getProgressWithTaskId:self.taskId success:^(NSString *status) {
            if ([status intValue] == 9) {
                if (success) {
                    success(@"1");
                }
                [TF_Timer cancelTask:self.taskName];
            } else {
                
            }

        } failure:^(NSError *error) {
            [TF_Timer cancelTask:self.taskName];
            if (self.failureCall) {
                self.failureCall(error);
            }
            
        }];
    } start:0 interval:3.0 repeats:YES async:YES];
}

- (void)prepareDeal{
    MJWeakSelf
    [VoiceTransferRequest prepareWithLen:self.fileStreamer.fileSize fileName:self.fileStreamer.fileName success:^(NSString *taskId) {
        weakSelf.taskId = taskId;
        dispatch_semaphore_signal(weakSelf.semaphore);
    } failure:^(NSError * _Nonnull error) {
        weakSelf.failured = YES;
        dispatch_semaphore_signal(weakSelf.semaphore);
        if (weakSelf.failureCall) {
            weakSelf.failureCall(error);
        }
    }];
}

- (void)uploadVoice{
    
    SliceIdGenerator *ger = [[SliceIdGenerator alloc] init];
    __block NSInteger staus = 0;
    while (true) {
        if (staus > 0) {
            break;
        }
        if (self.currentIndex < self.fileStreamer.fileFragments.count) {
            if (self.fileStreamer.fileFragments[self.currentIndex].fragmentStatus == FileUpStateWaiting) {
                self.fileStreamer.fileFragments[self.currentIndex].fragmentStatus = FileUpStateLoading;
                NSData *data = [self.fileStreamer readDateOfFragment:self.fileStreamer.fileFragments[self.currentIndex]];
                NSString *sliceId = [ger getNextSliceId];
                [VoiceTransferRequest uploadWithTaskId:self.taskId sliceId:sliceId content:data filePath:self.fileStreamer.filePath success:^(id response) {
                    self.currentIndex++;
                } failure:^(NSError *error) {
                    staus = 2;
                }];
                
            }
        } else {
            staus = 1;
            break;
        }
    }
    
    if (staus == 2) {
        self.failured = YES;
        NSError *error = [NSError errorWithDomain:@"ErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"上传失败".lv_localized}];
        if (self.failureCall) {
            self.failureCall(error);
        }
    }
    dispatch_semaphore_signal(self.semaphore);
}

- (void)merge{
    MJWeakSelf
    [VoiceTransferRequest mergeWithTaskId:self.taskId success:^(id  _Nonnull response) {
        
        dispatch_semaphore_signal(self.semaphore);
    } failure:^(NSError * _Nonnull error) {
        weakSelf.failured = YES;
        dispatch_semaphore_signal(weakSelf.semaphore);
        if (weakSelf.failureCall) {
            weakSelf.failureCall(error);
        }
        dispatch_semaphore_signal(self.semaphore);
    }];
}



- (void)getResult{
    MJWeakSelf
    [VoiceTransferRequest getResultWithTaskId:self.taskId success:^(NSArray *response) {
        
        NSLog(@"===%@", response);
        if (weakSelf.successCall) {
            weakSelf.successCall(response, @"");
        }
    } failure:^(NSError *error) {
        weakSelf.failured = YES;
        if (weakSelf.failureCall) {
            weakSelf.failureCall(error);
        }
        
    }];
}

@end
