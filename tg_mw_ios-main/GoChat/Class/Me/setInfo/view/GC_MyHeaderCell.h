//
//  GC_MyHeaderCell.h
//  GoChat
//
//  Created by wangfeiPro on 2021/12/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GC_MyHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageV;

@property (weak, nonatomic) IBOutlet UIView *lineView;

- (void)setImageV;

@end

NS_ASSUME_NONNULL_END
