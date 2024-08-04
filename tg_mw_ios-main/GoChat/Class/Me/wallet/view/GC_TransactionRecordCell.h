//
//  GC_TransactionRecordCell.h
//  GoChat
//
//  Created by wangfeiPro on 2021/12/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GC_TransactionRecordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *moneyLab;
@property (weak, nonatomic) IBOutlet UILabel *statusLab;
@property (weak, nonatomic) IBOutlet UIView *contentV;

- (void)resetOrderInfo:(WalletOrderInfo *)info;

@end

NS_ASSUME_NONNULL_END
