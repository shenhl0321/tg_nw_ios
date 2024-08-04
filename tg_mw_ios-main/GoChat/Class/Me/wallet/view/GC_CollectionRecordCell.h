//
//  GC_CollectionRecordCell.h
//  GoChat
//
//  Created by wangfeiPro on 2021/12/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GC_CollectionRecordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *contentV;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *moneyLab;
@property (weak, nonatomic) IBOutlet UILabel *lineLab;

@property (nonatomic, strong)NSDictionary *dataDic;

@end

NS_ASSUME_NONNULL_END
