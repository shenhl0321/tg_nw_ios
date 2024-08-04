//
//  CZGroupMediaHeaderView.h
//  GoChat
//
//  Created by mac on 2021/7/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CZGroupMediaHeaderViewDelegate <NSObject>

- (void)sectionHeaderViewClickWithTag:(NSInteger)tag;

@end

@interface CZGroupMediaHeaderView : UIView
@property (nonatomic,weak) id<CZGroupMediaHeaderViewDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
