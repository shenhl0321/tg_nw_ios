//
//  QTSetInfoBottomView.h
//  BaseChat
//
//  Created by 漫漫人生路 on 2023/3/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef enum {
    QT_Set_My_Nickname = 0,
    QT_Set_My_Group_Nickname = 1,
    QT_Set_Group_Nickname = 2
} QTSetInfoBottomType;

typedef void(^QTSetInfoBottomSuccessBlock)(NSString *contentStr);
@interface QTSetInfoBottomView : UIView

+(QTSetInfoBottomView *)sharedInstance;

/// 设置
/// - Parameters:
///   - type: 类型
///   - titleStr: 标题
///   - contentStr: 内容
///   - placeStr: 占位符
///   - successBlock: 成功回调
- (void)alertViewType:(QTSetInfoBottomType)type TitleStr:(NSString *)titleStr ContentStr:(NSString *)contentStr PlaceStr:(NSString *)placeStr;

/// 设置
/// - Parameters:
///   - type: 类型
///   - chatId: 聊天ID
///   - titleStr: 标题
///   - contentStr: 内容
///   - placeStr: 占位符
///   - successBlock: 成功回调
- (void)alertViewType:(QTSetInfoBottomType)type ChatId:(NSString *)chatId TitleStr:(NSString *)titleStr ContentStr:(NSString *)contentStr PlaceStr:(NSString *)placeStr;


@property (strong, nonatomic) QTSetInfoBottomSuccessBlock successBlock;

@end

NS_ASSUME_NONNULL_END
