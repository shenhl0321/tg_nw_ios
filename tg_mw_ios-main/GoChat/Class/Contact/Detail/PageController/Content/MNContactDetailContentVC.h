//
//  MNContactDetailContentVC.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/20.
//

#import "BaseTableVC.h"

#define NotifyGoToTopNotification               @"NotifyGoToTopNotification"
#define NotifyLeaveTopNotification              @"NotifyLeaveTopNotification"

NS_ASSUME_NONNULL_BEGIN
@class MNContactDetailContentVC;
@protocol MNContactDetailContentVCDelegate <NSObject>

-(void)contentVC:(MNContactDetailContentVC *)contentVC scrollViewDidScroll:(UIScrollView *)scrollView;

@end

@interface MNContactDetailContentVC : BaseTableVC
<UICollectionViewDelegate,UICollectionViewDataSource>
- (void)refreshConetentViewWithHeight:(CGFloat)height;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) UserInfo *userInfo;
@property (nonatomic, assign) long startId;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, weak) id<MNContactDetailContentVCDelegate>delegate;

- (instancetype)initWithUser:(UserInfo *)user type:(NSInteger)type;
- (void)initDataComplete:(NullBlock)complete loadMore:(BOOL)loadMore;
- (void)initDataCompleteFunc;
- (MJRefreshAutoNormalFooter *)addFooterRefresh;


/// 历史消息进入
@property (nonatomic, assign, getter=isHistory) BOOL history;
@property (nonatomic, assign) long chatId;

@end

NS_ASSUME_NONNULL_END
