//
//  CZGroupShareLinkTableViewCell.h
//  GoChat
//
//  Created by mac on 2021/7/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CZGroupShareLinkTableViewCellDelegate <NSObject>

- (void)shareLinkClickWithTag:(NSInteger)tag;//100  链接点击   101  二维码点击

@end

@interface CZGroupShareLinkTableViewCell : UITableViewCell
@property (nonatomic,weak) id<CZGroupShareLinkTableViewCellDelegate>delegate;
@property (nonatomic, strong) SuperGroupFullInfo *super_groupFullInfo;
@end

NS_ASSUME_NONNULL_END
