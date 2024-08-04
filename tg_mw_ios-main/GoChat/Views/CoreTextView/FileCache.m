//
//  FileCache.m

#import "FileCache.h"

@interface FileCache ()

@property (strong, nonatomic) NSCache *memCache;

@end

@implementation FileCache

+ (instancetype)sharedCache;
{
    static dispatch_once_t once;
    static FileCache *instance = nil;
    dispatch_once(&once, ^{
        instance = [[FileCache alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _memCache = [[NSCache alloc] init];
        _memCache.countLimit = 250;
        _memCache.totalCostLimit = 10*1024*1024;//bytes ,10MB
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

//保存文件到内存
- (void)storeFile:(id)file forKey:(NSString *)key;
{
    if (!file || !key) {
        return;
    }
    [self.memCache setObject:file forKey:key];
}

//从内存中获取文件
- (id)fileFromMemoryCacheForKey:(NSString *)key;
{
    if (!key) {
        return nil;
    }
    return [self.memCache objectForKey:key];
}


//清除内存文件
- (void)clearMemory;
{
    [self.memCache removeAllObjects];
    NSLog(@"FileCache:clearMemory");
}

@end
