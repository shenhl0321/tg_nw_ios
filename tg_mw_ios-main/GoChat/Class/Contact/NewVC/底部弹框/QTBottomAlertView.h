//
//  QTBottomAlertView.h
//  BaseChat
//
//  Created by 漫漫人生路 on 2023/4/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^QTBottomAlertChooseBlock)(NSInteger chooseIndex, NSString *chooseStr);
@interface QTBottomAlertView : UIView

+(QTBottomAlertView *)sharedInstance;

- (void)alertViewTitle:(NSString *)title DataArr:(NSArray *)dataArr ChooseSuccess:(QTBottomAlertChooseBlock)chooseBlock;

@end

NS_ASSUME_NONNULL_END
