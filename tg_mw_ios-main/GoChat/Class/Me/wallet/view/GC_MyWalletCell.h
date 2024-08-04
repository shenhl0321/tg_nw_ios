//
//  GC_MyWalletCell.h
//  GoChat
//
//  Created by wangfeiPro on 2021/12/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GC_MyWalletCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (nonatomic, strong)NSDictionary *dataDic;

@end

NS_ASSUME_NONNULL_END
