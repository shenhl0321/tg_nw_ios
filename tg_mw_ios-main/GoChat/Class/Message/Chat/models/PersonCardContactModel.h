//
//  PersonCardContactModel.h
//  GoChat
//
//  Created by mac on 2021/9/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PersonCardContactModel : NSObject

@property (nonatomic, copy) NSString *phone_number;
@property (nonatomic, copy) NSString *first_name;
@property (nonatomic, copy) NSString *last_name;
@property (nonatomic, copy) NSString *vcard;
@property (nonatomic, assign) NSInteger user_id;

@end

NS_ASSUME_NONNULL_END
