//
//  MNContactDetailSearchReusableView.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/22.
//

#import <UIKit/UIKit.h>
#import "ContactSearchBar.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^DetailSelectedBlock)(NSInteger index);

@interface MNContactDetailSearchReusableView : UICollectionReusableView
@property (nonatomic, strong) ContactSearchBar *searchBar;
//@property (nonatomic, strong)
@property (nonatomic, strong) UIButton *clearBtn;

@property (nonatomic, copy) DetailSelectedBlock block;

@end

NS_ASSUME_NONNULL_END
