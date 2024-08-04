//
//  SelectMemberVC.h
//  GoChat
//
//  Created by Autumn on 2021/11/7.
//

#import "DYTableViewController.h"

typedef NS_ENUM(NSUInteger, SelectMemberFrom) {
    SelectMemberFromGroup,
    SelectMemberFromContact,
};


NS_ASSUME_NONNULL_BEGIN

typedef void(^SelectedGroupBlock)(NSArray<ChatInfo *> *groups);
typedef void(^SelectedContactBlock)(NSArray<UserInfo *> *contacts);

@interface SelectMemberVC : DYTableViewController

/// 选择联系人后弹出保存标签提醒
@property (nonatomic, assign, getter=isShowSaveToTagAlert) BOOL showSaveToTagAlert;

@property (nonatomic, assign) SelectMemberFrom from;

@property (nonatomic, strong) NSMutableArray<ChatInfo *> *selectedGroups;
@property (nonatomic, strong) NSMutableArray<UserInfo *> *selectedContacts;

@property (nonatomic, copy) SelectedGroupBlock groupBlock;
@property (nonatomic, copy) SelectedContactBlock contactBlock;

@end

NS_ASSUME_NONNULL_END
