//
//  GC_DataSetInfo.h
//  GoChat
//
//  Created by apple on 2022/2/15.
//

#import <Foundation/Foundation.h>

@interface GC_MemoryUse : NSObject<NSCoding>

/// 保留缓存时间 0-3天；1-1周；2-1个月；3-永久
@property (nonatomic,assign) NSInteger cacheTime;
/// 最大缓存占用 0-3天；1-1周；2-1个月；3-永久
@property (nonatomic,assign) NSInteger maxCache;

@end

@interface GC_NetworkUse : NSObject<NSCoding>
/// 保留缓存时间 0-3天；1-1周；2-1个月；3-永久
@property (nonatomic,assign) NSInteger cacheTime;
/// 最大缓存占用 0-3天；1-1周；2-1个月；3-永久
@property (nonatomic,assign) NSInteger maxCache;
@end

@interface GC_DataSetMedia : NSObject<NSCoding>
/// 自动下载媒体
@property (nonatomic,assign) BOOL autoDownload;
/// 下载图片
@property (nonatomic,assign) BOOL image;
/// 下载视频
@property (nonatomic,assign) BOOL video;
/// 文件下载
@property (nonatomic,assign) BOOL file;

@end

@interface GC_DataSetInfo : NSObject<NSCoding>
/// 存储用量
@property (nonatomic,strong) GC_MemoryUse *memoryUse;
/// 网络用量
@property (nonatomic,strong) GC_NetworkUse *networkkUse;
/// 移动网络媒体设置
@property (nonatomic,strong) GC_DataSetMedia *mobileMediaSet;
/// wifi网络媒体设置
@property (nonatomic,strong) GC_DataSetMedia *wifiMediaSet;
/// 自动保存图片
@property (nonatomic,assign) BOOL autoSaveImg;
/// 保存已编辑的图片
@property (nonatomic,assign) BOOL saveEditedImg;
/// 自动播放GIF
@property (nonatomic,assign) BOOL autoPlayGif;

+ (GC_DataSetInfo *)getUserDataSetInfo;

+ (void)saveUserDataSetInfo:(GC_DataSetInfo *)info;


@end
