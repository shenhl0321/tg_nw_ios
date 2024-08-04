//
//  TF_TimeBrowseCommentV.h
//  GoChat
//
//  Created by apple on 2022/2/10.
//

#import <UIKit/UIKit.h>
#import "BlogInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface TF_TimeBrowseCommentV : UIView
- (void)requestData;
/// 内容信息
@property (nonatomic,strong) BlogInfo *blog;
/// <#code#>
@property (nonatomic,copy) void(^replay)(NSInteger replyId, NSString *name);
/// <#code#>
@property (nonatomic,copy) void(^comment)(NSInteger blogId);

/// <#code#>
@property (nonatomic,copy) void(^closeCall)(void);

- (void)replyCommentChanged:(NSArray *)param;

@end

NS_ASSUME_NONNULL_END
