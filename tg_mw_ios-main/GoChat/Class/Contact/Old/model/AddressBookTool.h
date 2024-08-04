//
//  AddressBookTool.h
//  GoChat
//
//  Created by mac on 2021/9/6.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
NS_ASSUME_NONNULL_BEGIN

@interface AddressBookTool : NSObject

#pragma mark 获取通讯录权限状态
+ (CNAuthorizationStatus)requestAddressBookPermissionsStatus;
#pragma mark 请求通信录授权
+ (void)requestAddressBookPermissionsAuthorized:(void (^)(BOOL granted))completionHandler;
#pragma mark 通讯录列表
+ (NSMutableArray *)requestAddressBookList;
+(NSMutableArray *)sortObjectsAccordingToInitialWith:(NSArray *)phoneArray;

@end

NS_ASSUME_NONNULL_END
