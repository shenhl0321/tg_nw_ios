//
//  FileCache.h
//

#import <Foundation/Foundation.h>

@interface FileCache : NSObject

+ (instancetype)sharedCache;

//保存文件到内存
- (void)storeFile:(id)file forKey:(NSString *)key;

//从内存中获取文件
- (id)fileFromMemoryCacheForKey:(NSString *)key;

////清除key索引的文件
//- (void)removeFileForKey:(NSString *)key;
//清除内存文件
- (void)clearMemory;

@end
