//
//  CZEditFourTableViewCell.h
//  GoChat
//
//  Created by mac on 2021/8/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CZEditFourTableViewCellDelegate <NSObject>

- (void)groupMemberClickwithobject:(NSObject *)cellmodel;

@end

@interface CZEditFourTableViewCell : UITableViewCell
//群管理员列表
@property (nonatomic, strong) NSArray *memberIsManagersList;
@property (weak, nonatomic) IBOutlet UILabel *groupManagerLabel;
@property (nonatomic,weak) id<CZEditFourTableViewCellDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
