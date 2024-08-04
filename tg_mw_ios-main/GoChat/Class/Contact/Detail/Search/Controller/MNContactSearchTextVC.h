//
//  MNContactSearchTextVC.h
//  GoChat
//
//  Created by Autumn on 2022/3/14.
//

#import "DYRefreshViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNContactSearchTextVC : DYRefreshViewController

@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, strong) NSNumber *chatId;

@end

NS_ASSUME_NONNULL_END
