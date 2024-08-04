//
//  GC_ExpressionCell.h
//  GoChat
//
//  Created by wangfeiPro on 2021/12/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GC_ExpressionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerImageV;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *userLab;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

- (void)setFollowStatus:(BOOL)isSelect;
@end

NS_ASSUME_NONNULL_END
