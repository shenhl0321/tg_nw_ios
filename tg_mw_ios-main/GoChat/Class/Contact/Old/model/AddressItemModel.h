//
//  AddressItemModel.h
//  GoChat
//
//  Created by Demi on 2021/9/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddressItemModel : NSObject
@property (nonatomic, copy) NSString *phone_number;
@property (nonatomic, copy) NSString *first_name;
@property (nonatomic, copy) NSString *last_name;
@property (nonatomic, copy) NSString *vcard;
@property (nonatomic, copy) NSString *user_id;
//是否是好友
@property (nonatomic, assign) BOOL is_contact;

@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *pinyin;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, strong) NSDictionary * profile_photo;
@end

NS_ASSUME_NONNULL_END
