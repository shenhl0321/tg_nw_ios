//
//  EmojiManager.h
//  GoChat
//
//  Created by wangyutao on 2021/2/23.
//

#import <Foundation/Foundation.h>

@interface EmojiManager : NSObject
+ (EmojiManager *)shareInstance;
- (NSString *)toString:(NSDictionary *)dic;
- (NSArray *)emojiListCopy;
@end
