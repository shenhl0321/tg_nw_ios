//
//  QTGroupPersonEditVC.h
//  BaseChat
//
//  Created by 漫漫人生路 on 2023/4/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^QTGroupPersonEditBlock)(NSString *nickName);
@interface QTGroupPersonEditVC : UIViewController

@property (nonatomic) long chatId;
@property (nonatomic, copy) NSString *prevValueString;
@property (nonatomic, strong) UserInfo *toBeModifyUser;

@property (strong, nonatomic) QTGroupPersonEditBlock successBlock;

@end

NS_ASSUME_NONNULL_END
