//
//  BlogUserGroup.h
//  GoChat
//
//  Created by Autumn on 2021/11/6.
//

#import "JWModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BlogUserGroup : JWModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSMutableArray *users;

@property (nonatomic, strong) NSMutableArray *userinfos;

@property (nonatomic, strong) NSMutableArray *usernames;


@end

NS_ASSUME_NONNULL_END
