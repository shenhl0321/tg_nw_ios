//
//  EmojiManager.m
//  GoChat
//
//  Created by wangyutao on 2021/2/23.
//

#import "EmojiManager.h"
#import "TelegramManager.h"

static EmojiManager *g_emojiManager = nil;

@interface EmojiManager()
@property (nonatomic, strong) NSArray *emojiList;
@property (nonatomic, strong) NSArray *collectList;

@end

@implementation EmojiManager

+ (EmojiManager *)shareInstance
{
    if(g_emojiManager == nil)
    {
        g_emojiManager = [[EmojiManager alloc] init];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [g_emojiManager load];
        });
    }
    return g_emojiManager;
}

- (void)load
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"plist"];
    NSArray *list = [[NSArray alloc] initWithContentsOfFile:path];
    if(list.count<=0)
    {
        NSLog(@"EmojiManager->load:emoji.plist 内容为空".lv_localized);
        return;
    }
    self.emojiList = list;
}

- (NSString *)toString:(NSDictionary *)dic
{
    if(dic != nil && [dic isKindOfClass:[NSDictionary class]])
    {
        return [dic objectForKey:@"char"];
    }
    return @"";
}

- (NSArray *)emojiListCopy
{
    return [self.emojiList copy];
}

@end
