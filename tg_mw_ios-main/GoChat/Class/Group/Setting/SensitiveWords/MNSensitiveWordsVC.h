//
//  MNSensitiveWordsVC.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/27.
//

#import "BaseTableVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNSensitiveWordsVC : BaseTableVC
@property (nonatomic, assign)BOOL canEdit;
@property (nonatomic, strong)ChatInfo *chat;
@end

NS_ASSUME_NONNULL_END
