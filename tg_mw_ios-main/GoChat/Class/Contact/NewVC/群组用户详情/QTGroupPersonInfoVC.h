//
//  QTGroupPersonInfoVC.h
//  BaseChat
//
//  Created by 漫漫人生路 on 2023/4/9.
//

#import <UIKit/UIKit.h>
#import "QTAddPersonVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface QTGroupPersonInfoVC : UIViewController

@property (nonatomic, strong) UserInfo *user;

@property (nonatomic) BOOL toShowInvidePath;
@property (nonatomic) long chatId;
@property (nonatomic) BOOL blockContact;////此为群组功能

@end

NS_ASSUME_NONNULL_END
