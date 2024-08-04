//
//  MNGroupAnnounceVC.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/25.
//

#import "BaseTableVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNGroupAnnounceVC : BaseTableVC
@property (nonatomic, assign)BOOL canEdit;
@property (nonatomic, strong)ChatInfo *chat;
@property (nonatomic, copy) NSString *originName;

@end

NS_ASSUME_NONNULL_END
