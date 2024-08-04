//
//  QTGroupFirTableViewCell.h
//  GoChat
//
//  Created by mac on 2021/7/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QTGroupFirTableViewCellDelegate <NSObject>
- (void)cellFunctionBtnClickWithTag:(NSInteger)tag withSender:(UIButton *)sender;
@end

@interface QTGroupFirTableViewCell : UITableViewCell

@property (nonatomic, strong) ChatInfo *chatInfo;
@property (nonatomic,weak) id<QTGroupFirTableViewCellDelegate>delegate;
//群成员列表
@property (nonatomic, strong) NSArray *membersList;

@property (weak, nonatomic) IBOutlet UIView *guanliView;

@end

NS_ASSUME_NONNULL_END
