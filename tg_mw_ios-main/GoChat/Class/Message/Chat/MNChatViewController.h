//
//  MNChatViewController.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/10.
//

#import "BaseVC.h"
#import "BaseViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface MNChatViewController : BaseVC
@property (nonatomic, strong) NSMutableArray *messageList;
@property (nonatomic, strong) ChatInfo *chatInfo;
@property (nonatomic) long destMsgId;

+ (NSString *)localPhotoPath:(UIImage *)image;

- (BOOL)isSystemChat;

- (MessageViewBaseCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)getScrollToBottomCanPlayCellIndexPath;
@end

NS_ASSUME_NONNULL_END
