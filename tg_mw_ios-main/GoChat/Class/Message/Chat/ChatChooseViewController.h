//
//  ChatChooseViewController.h
//  GoChat
//
//  Created by wangyutao on 2020/12/2.
//

#import "BaseTableVC.h"

@class ChatChooseViewController;
@protocol ChatChooseViewControllerDelegate <NSObject>
@optional
- (void)ChatChooseViewController_Chat_Choose:(id)chat msg:(NSArray *)msgs;
// 群发
- (void)ChatChooseViewController_Chats_ChooseArr:(NSArray *)chatArr msg:(NSArray *)msgs;
- (void)ChatChooseViewController_PersonalCard_Choose:(id)chat;
@end

@interface ChatChooseViewController : BaseTableVC
//1、选择发送名片 2、推荐给好友
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) ChatInfo *sendChatInfo;

@property (nonatomic, weak) id<ChatChooseViewControllerDelegate> delegate;
//转发的消息列表
@property (nonatomic, strong) NSArray *toSendMsgsList;
@end
