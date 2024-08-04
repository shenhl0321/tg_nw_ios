//
//  GC_CommonInputCell.h
//  GoChat
//
//  Created by wangfeiPro on 2021/12/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GC_CommonInputCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UITextField *input;

@property (nonatomic, strong)NSDictionary *dataDic;

@end

NS_ASSUME_NONNULL_END
