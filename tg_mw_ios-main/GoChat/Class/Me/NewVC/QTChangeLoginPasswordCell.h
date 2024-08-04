//
//  QTChangeLoginPasswordCell.h
//  GoChat
//
//  Created by mac on 2021/6/30.
//

#import <UIKit/UIKit.h>
#import "CZRegisterInputModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface QTChangeLoginPasswordCell : UITableViewCell
@property (nonatomic,strong) CZRegisterInputModel *cellModel;
@property (nonatomic,strong)    NSString    *inputString;
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;
@property (weak, nonatomic) IBOutlet UITextField *inputField;

@end

NS_ASSUME_NONNULL_END
