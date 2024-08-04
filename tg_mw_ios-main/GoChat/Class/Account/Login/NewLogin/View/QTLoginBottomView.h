//
//  QTLoginBottomView.h
//  BaseChat
//
//  Created by 漫漫人生路 on 2023/3/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^QTLoginBottomSuccessBlock)(void);
@interface QTLoginBottomView : UIView

+(QTLoginBottomView *)sharedInstance;

- (void)alertViewSuccessBlock:(QTLoginBottomSuccessBlock)successBlock;

@end

NS_ASSUME_NONNULL_END
