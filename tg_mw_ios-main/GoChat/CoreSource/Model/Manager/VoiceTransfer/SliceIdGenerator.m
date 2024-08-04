//
//  SliceIdGenerator.m
//  GoChat
//
//  Created by apple on 2022/2/16.
//

#import "SliceIdGenerator.h"

@interface SliceIdGenerator ()
/// <#code#>
@property (nonatomic,assign) NSInteger len;
/// <#code#>
@property (nonatomic,strong) NSMutableArray *chars;
@end

@implementation SliceIdGenerator

+ (SliceIdGenerator *)shareInstance{
    return [[self alloc] init];
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
        SliceIdGenerator *gener = (SliceIdGenerator *)instance;
        NSMutableArray *mut = [NSMutableArray array];
        const char *chat = [@"a" UTF8String];
        NSString *chatStr = [NSString stringWithUTF8String:chat];
        for (int i = 0; i < 10; i++) {
            
            [mut addObject:chatStr];
        }
        gener.chars = mut;
        gener.len = 9;
    });
    return instance;
}
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return self;
}

- (NSString *)getNextSliceId{
    
    NSString *res = [self.chars componentsJoinedByString:@""];
    for (NSInteger i = 0, j = self.len - 1; i < self.len && j >= 0; i++) {
        if (![self.chars[j] isEqualToString:@"z"]) {
            const char *chat = [self.chars[j] UTF8String];
            char first = chat[0];
            first++;
            self.chars[j] = [NSString stringWithFormat:@"%c", first];
            break;
        } else {
            self.chars[j] = @"a";
            j--;
            continue;
        }
    }

    return res;
}

@end
