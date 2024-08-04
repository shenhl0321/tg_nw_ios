//
//  CZEditSedTableViewCell.h
//  GoChat
//
//  Created by mac on 2021/8/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZEditSedTableViewCell : UITableViewCell
@property (nonatomic,strong) MessageInfo *cellModel;

@property (nonatomic,strong) NSString *groupIntroStr;
@end

NS_ASSUME_NONNULL_END
