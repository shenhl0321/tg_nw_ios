//
//  CZGroupFirTableViewCell.h
//  GoChat
//
//  Created by mac on 2021/7/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CZGroupFirTableViewCellDelegate <NSObject>
- (void)cellFunctionBtnClickWithTag:(NSInteger)tag withSender:(UIButton *)sender;
@end

@interface CZGroupFirTableViewCell : UITableViewCell

@property (nonatomic, strong) ChatInfo *chatInfo;
@property (nonatomic,weak) id<CZGroupFirTableViewCellDelegate>delegate;
//群成员列表
@property (nonatomic, strong) NSArray *membersList;
@end

NS_ASSUME_NONNULL_END
