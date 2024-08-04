//
//  CZChoiceCountyTableViewCell.h
//  GoChat
//
//  Created by mac on 2021/6/30.
//

#import <UIKit/UIKit.h>
#import "CZRegisterInputModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CZVerifiyTableViewCell : UITableViewCell
@property (nonatomic,strong) CZRegisterInputModel *cellModel;
@property (nonatomic,strong)    NSString    *inputString;
@end

NS_ASSUME_NONNULL_END
