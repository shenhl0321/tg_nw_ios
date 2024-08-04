//
//  MNDetailDynamicView.h
//  GoChat
//
//  Created by 许蒙静 on 2022/1/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNDetailDynamicView : UIView
@property (nonatomic, strong) UICollectionView *collectionView;
- (void)fillDataWithArray:(NSMutableArray *)array;
@end

NS_ASSUME_NONNULL_END
