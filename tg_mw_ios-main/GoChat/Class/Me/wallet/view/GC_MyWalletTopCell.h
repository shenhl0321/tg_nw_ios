//
//  GC_MyWalletTopCell.h
//  GoChat
//
//  Created by wangfeiPro on 2021/12/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GC_MyWalletTopCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageV;
@property (weak, nonatomic) IBOutlet UIView *rechargeView;
@property (weak, nonatomic) IBOutlet UIView *cashOutView;
@property (weak, nonatomic) IBOutlet UILabel *priceLab;

@end

NS_ASSUME_NONNULL_END
