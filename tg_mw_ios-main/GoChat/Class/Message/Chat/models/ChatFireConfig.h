//
//  ChatFireConfig.h
//  GoChat
//
//  Created by 吴亮 on 2021/9/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatFireConfig : NSObject

@property (nonatomic, strong) NSMutableDictionary * fireConfigDic;

+ (instancetype)shareInstance;
@end

NS_ASSUME_NONNULL_END
