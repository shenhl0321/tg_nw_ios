//
//  GC_DataSetInfo.m
//  GoChat
//
//  Created by apple on 2022/2/15.
//

#import "GC_DataSetInfo.h"

@implementation GC_MemoryUse
MJCodingImplementation
@end

@implementation GC_NetworkUse
MJCodingImplementation
@end



@implementation GC_DataSetMedia
MJCodingImplementation
@end


@implementation GC_DataSetInfo
MJCodingImplementation

- (GC_MemoryUse *)memoryUse{
    if (!_memoryUse) {
        _memoryUse = [[GC_MemoryUse alloc] init];
        _memoryUse.cacheTime = 3;
        _memoryUse.maxCache = 3;
    }
    return _memoryUse;
}

- (GC_NetworkUse *)networkkUse{
    if (!_networkkUse) {
        _networkkUse = [[GC_NetworkUse alloc] init];
        _networkkUse.cacheTime = 3;
        _networkkUse.maxCache = 3;
    }
    return _networkkUse;
}

- (GC_DataSetMedia *)mobileMediaSet{
    if (!_mobileMediaSet) {
        _mobileMediaSet = [[GC_DataSetMedia alloc] init];
        _mobileMediaSet.autoDownload = YES;
        _mobileMediaSet.image = YES;
        _mobileMediaSet.video = YES;
        _mobileMediaSet.file = YES;
    }
    return _mobileMediaSet;
}

- (GC_DataSetMedia *)wifiMediaSet{
    if (!_wifiMediaSet) {
        _wifiMediaSet = [[GC_DataSetMedia alloc] init];
        _wifiMediaSet.autoDownload = YES;
        _wifiMediaSet.image = YES;
        _wifiMediaSet.video = YES;
        _wifiMediaSet.file = YES;
    }
    return _wifiMediaSet;
}

+ (GC_DataSetInfo *)getUserDataSetInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"UserDataSetInfo"];
    if(data)
    {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:nil];
        unarchiver.requiresSecureCoding = NO;
        return [unarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:nil];
    } else {
        GC_DataSetInfo *set = [[GC_DataSetInfo alloc] init];
        set.autoPlayGif = YES;
        set.saveEditedImg = YES;
        set.autoSaveImg = YES;
        [GC_DataSetInfo saveUserDataSetInfo:set];
        return set;
    }
}

+ (void)saveUserDataSetInfo:(GC_DataSetInfo *)info
{
    if(info != nil)
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:info requiringSecureCoding:NO error:nil];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"UserDataSetInfo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


@end
