//
//  chatInviteLinkInfo.h
//  GoChat
//
//  Created by mac on 2021/7/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatInviteLinkInfo : NSObject

@property (nonatomic,assign)    long             chat_id;
@property (nonatomic,assign)    BOOL            is_public;
@property (nonatomic,assign)    int             member_count;
@property (nonatomic,strong)    NSArray         *member_user_ids;
@property (nonatomic,strong)    ProfilePhoto    *photo;
@property (nonatomic,strong)    NSString        *title;
@property (nonatomic,strong)    ChatType        *type;

@end

NS_ASSUME_NONNULL_END
