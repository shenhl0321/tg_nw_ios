//
//  MNAddGroupVC.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/5.
//

#import "BaseTableVC.h"

typedef enum {
    //创建群组
    MNContactChooseType_CreateBasicGroup = 0,
    //从联系人详情创建群组
    MNContactChooseType_CreateBasicGroup_From_Contact,
    //群组增加成员-从联系人列表增加
    MNContactChooseType_Group_Add_Member,
    //群组移除成员-从现有群组成员移除
    MNContactChooseType_Group_Delete_Member,
    //群组增加管理员-从现有群组成员提升-只有群组拥有者，即创建者，才有权限增加或者删除群组管理员
    MNContactChooseType_Group_Add_Manager,
    //群组删除管理员-从现有群管理员降级
    MNContactChooseType_Group_Delete_Manager,
    //群组@人
    MNContactChooseType_Group_At_Someone,
    
    MNContactChooseType_Private_Chat,
    /// 群发助手
    MNContactChooseType_Group_Sent,
    /// 朋友圈提醒某人
    MNContactChooseType_Timeline_At_Someone,
} MNContactChooseType;


@protocol MNChooseUserDelegate <NSObject>

@optional
- (void)chooseUser:(UserInfo *)user;

- (void)chooseUsers:(NSArray<UserInfo *> *)users;

- (void)chooseClose;

@end
NS_ASSUME_NONNULL_BEGIN

@interface MNAddGroupVC : BaseTableVC

@property (nonatomic, weak) id<MNChooseUserDelegate> delegate;

@property (nonatomic) MNContactChooseType chooseType;
@property (nonatomic, copy) NSString *chooseTitle;
//从联系人详情创建群组
@property (nonatomic) long fromContactId;

//群组管理相关
//群组增加成员-从联系人列表增加
//群组移除成员-从现有群组成员移除(不包括自己和管理员)
//群组增加管理员-从现有群组成员提升
@property (nonatomic, strong) NSArray *group_membersList;
//群组增加管理员-从现有群组成员提升
//群组删除管理员-从现有群管理员降级
@property (nonatomic, strong) NSArray *group_managersList;
@property (nonatomic) BOOL isSuperGroup;
@property (nonatomic) long chatId;
//超过200人时，需要处理
//超级讨论组时有效
@property (nonatomic) long supergroup_id;
@property (nonatomic, strong) SuperGroupFullInfo *super_groupFullInfo;

/// YES:present进来 NO：push进来（默人push）
@property (assign, nonatomic) BOOL isPresent;

@end

NS_ASSUME_NONNULL_END
