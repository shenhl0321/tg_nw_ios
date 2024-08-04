//
//  GC_MinePakgeCell.h
//  GoChat
//
//  Created by wangfeiPro on 2021/12/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GC_MinePakgeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageV;
@property (weak, nonatomic) IBOutlet UIImageView *maPakgeImageV;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageV;
@property (weak, nonatomic) IBOutlet UILabel *priceLab;

@property (weak, nonatomic) IBOutlet UILabel *wtLab;
@end

NS_ASSUME_NONNULL_END
