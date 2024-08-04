//
//  MessageCellFactory.m
//  GoChat
//
//  Created by wangyutao on 2020/11/12.
//

#import "MessageCellFactory.h"

@implementation MessageCellFactory

+ (Class)classForChatRecord:(MessageInfo *)chatRecord
{
    switch (chatRecord.messageType)
    {
        case MessageType_Text:
            return [TextMessageCell class];
        case MessageType_Text_AudioAVideo_Done:
            return [CallMessageCell class];
        case MessageType_Text_New_Rp:
            return [RedPacketMessageCell class];
        case MessageType_Photo:
            return [PhotoMessageCell class];
        case MessageType_Video:
            return [VideoMessageCell class];
        case MessageType_Audio:
            return [AudioMessageCell class];
        case MessageType_Voice:
            return [AudioMessageCell class];
        case MessageType_Pinned:
            return [EmptyMessageCell class];
        case MessageType_Document:
            return [FileMessageCell class];
        case MessageType_Location:
            return [LocationMessageCell class];
        case MessageType_Animation:
            return [AnimationTableViewCell class];
        case MessageType_Card:
            return [PersonalCardCell class];
        case MessageType_Text_Transfer:
            return TransferMessageCell.class;
        default:
            return [TipMessageCell class];
    }
}

@end
