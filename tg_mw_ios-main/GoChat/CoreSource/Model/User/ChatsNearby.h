//
//  ChatsNearby.h
//  GoChat
//
//  Created by apple on 2021/12/20.
//

#import "JWModel.h"
@class UserInfo;
NS_ASSUME_NONNULL_BEGIN

@interface ChatNearby : JWModel
/// Chat identifier.
@property (nonatomic,copy) NSString *chat_id;
/// Distance to the chat location, in meters.
@property (nonatomic,assign) NSInteger distance;

/// <#code#>
@property (nonatomic,strong) UserInfo *user;
@end

@interface ChatsNearby : JWModel
/// List of users nearby.
@property (nonatomic,strong) NSArray<ChatNearby *> *users_nearby;
/// List of location-based supergroups nearby.
@property (nonatomic,strong) NSArray<ChatNearby *> *supergroups_nearby;
@end

NS_ASSUME_NONNULL_END
