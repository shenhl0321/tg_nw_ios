//
//  MNContactSearchContentVC.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/4.
//

#import "BaseTableVC.h"

typedef NS_OPTIONS(NSInteger, MNContactSearchType) {
    MNContactSearchTypeFriend,
    MNContactSearchTypeGroup,
    MNContactSearchTypeChat,
   
};

NS_ASSUME_NONNULL_BEGIN

@interface MNContactSearchContentVC : BaseTableVC
@property (nonatomic, assign) MNContactSearchType type;
- (instancetype)initWithType:(MNContactSearchType)type;

- (void)refreshViewWithData:(NSMutableArray *)dataArray;

@end

NS_ASSUME_NONNULL_END
