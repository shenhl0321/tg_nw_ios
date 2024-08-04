//
//  QTAddPersonVC.h
//  BaseChat
//
//  Created by 漫漫人生路 on 2023/4/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^QTAddPersonRefreshBlock)(void);
@interface QTAddPersonVC : UIViewController

@property (nonatomic, strong) UserInfo *user;

@property (nonatomic) BOOL toShowInvidePath;
@property (nonatomic) long chatId;
@property (nonatomic) BOOL blockContact;////此为群组功能

@property (strong, nonatomic) QTAddPersonRefreshBlock refreshBlock;

@end

NS_ASSUME_NONNULL_END
