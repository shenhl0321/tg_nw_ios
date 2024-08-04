//
//  ChatQrScanViewController.h
//  GoChat
//
//  Created by wangyutao on 2021/1/5.
//

#import "BaseViewController.h"

@class ChatQrScanViewController;
@protocol ChatQrScanViewControllerDelegate <NSObject>
@optional
- (void)ChatQrScanViewController_Result:(NSString *)result;
@end

@interface ChatQrScanViewController : BaseViewController
@property (nonatomic, weak) id<ChatQrScanViewControllerDelegate> delegate;
@end
