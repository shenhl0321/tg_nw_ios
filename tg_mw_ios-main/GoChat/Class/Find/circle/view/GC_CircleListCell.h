//
//  GC_CircleListCell.h
//  GoChat
//
//  Created by wangfeiPro on 2021/12/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GC_CircleListCell : UITableViewCell

@property (nonatomic, strong)NSDictionary *dataDic;
@property (nonatomic, strong) UILabel *desLab;
@property (nonatomic, strong) UILabel *timeLab;
@property (nonatomic, strong) UIButton *deleteBtn;

@end

NS_ASSUME_NONNULL_END
