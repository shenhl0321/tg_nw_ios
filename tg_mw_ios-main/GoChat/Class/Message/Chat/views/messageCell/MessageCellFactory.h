//
//  MessageCellFactory.h
//  GoChat
//
//  Created by wangyutao on 2020/11/12.
//

#import <Foundation/Foundation.h>
#import "MessageViewBaseCell.h"
#import "MessageBubbleCell.h"
#import "TextMessageCell.h"
#import "PhotoMessageCell.h"
#import "VideoMessageCell.h"
#import "AudioMessageCell.h"
#import "TipMessageCell.h"
#import "EmptyMessageCell.h"
#import "CallMessageCell.h"
#import "RedPacketMessageCell.h"
#import "FileMessageCell.h"
#import "LocationMessageCell.h"
#import "PersonalCardCell.h"
#import "TransferMessageCell.h"

//cell的高度
#define ChatViewCellHeight @"ChatViewCellHeight"

@interface MessageCellFactory : NSObject

+ (Class)classForChatRecord:(MessageInfo *)chatRecord;

@end
