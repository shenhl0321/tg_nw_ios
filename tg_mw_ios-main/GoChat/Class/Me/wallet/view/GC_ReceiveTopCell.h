//
//  GC_ReceiveTopCell.h
//  GoChat
//
//  Created by wangfeiPro on 2021/12/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GC_ReceiveTopCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerImageV;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLab;
@property (weak, nonatomic) IBOutlet UILabel *priceLab;
@property (weak, nonatomic) IBOutlet UILabel *numLab;

@end

NS_ASSUME_NONNULL_END
