//
//  GC_NearCell.h
//  GoChat
//
//  Created by wangfeiPro on 2021/12/16.
//

#import <UIKit/UIKit.h>
#import "ChatsNearby.h"
//#import "GC_NearGroupChatInfo.h"
@class ChatInfo;

NS_ASSUME_NONNULL_BEGIN

@interface NearGroupChatInfo : NSObject
/// 群聊信息
@property (nonatomic,strong) ChatInfo *chatInfo;
/// 自己是否在这个群中
@property (nonatomic,assign, getter=isSelfInChat) BOOL selfInChat;
/// 群成员列表
@property (nonatomic,strong) NSArray *membersList;
/// 在线人数
@property (nonatomic,assign) NSInteger onlineNum;
/// 全部人数
@property (nonatomic,assign) NSInteger totalNum;
@end

@interface GC_NearCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageV;

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *addressLab;
@property (weak, nonatomic) IBOutlet UIImageView *locationImageV;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageV;

/// 数据
/// 群聊信息
@property (nonatomic,strong) NearGroupChatInfo *chat;
@property (nonatomic,strong) ChatNearby *userInfo;

@end



NS_ASSUME_NONNULL_END
