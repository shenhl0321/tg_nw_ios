//
//  BlogUserGroup.m
//  GoChat
//
//  Created by Autumn on 2021/11/6.
//

#import "BlogUserGroup.h"
#import "UserinfoHelper.h"

@implementation BlogUserGroup

- (void)setUsers:(NSMutableArray *)users {
    _users = users;
    [UserinfoHelper getUserinfos:users completion:^(NSArray * _Nonnull userinfos) {
        self.userinfos = userinfos.mutableCopy;
    }];
}

- (NSMutableArray *)usernames {
    if (!_usernames) {
        _usernames = NSMutableArray.array;
        for (UserInfo *userinfo in self.userinfos) {
            [_usernames addObject:userinfo.displayName];
        }
    }
    return _usernames;
}

@end
