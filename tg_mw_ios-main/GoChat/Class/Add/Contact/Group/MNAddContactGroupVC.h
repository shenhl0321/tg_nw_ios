//
//  MNAddContactGroupVC.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/5.
//

#import "BaseTableVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNAddContactGroupVC : BaseTableVC

@end


#pragma mark - ChatInfo + NumberOfMember
@interface ChatInfo (NumberOfMember)

@property (nonatomic, assign) NSInteger totalNumber;

@property (nonatomic, assign) NSInteger onlineNumber;

@end

NS_ASSUME_NONNULL_END
