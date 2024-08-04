//
//  GC_MineInfoCell.h
//  GoChat
//
//  Created by wangfeiPro on 2021/12/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GC_MineInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerImageV;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *desLab;
@property (weak, nonatomic) IBOutlet UIButton *scanBtn;
@property (weak, nonatomic) IBOutlet UIButton *setBtn;
@property (weak, nonatomic) IBOutlet UIButton *saoyisaoBtn;

@property (nonatomic, copy)  void(^clickBlock)(void);

- (void)resetUI;

@end

NS_ASSUME_NONNULL_END
