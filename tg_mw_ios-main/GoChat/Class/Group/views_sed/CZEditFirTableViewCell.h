//
//  CZEditFirTableViewCell.h
//  GoChat
//
//  Created by mac on 2021/8/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CZEditFirTableViewCellDelegate <NSObject>

- (void)uploadGroupImageViewClick;
- (void)editGrouNameClick;

@end

@interface CZEditFirTableViewCell : UITableViewCell
@property (nonatomic, strong) ChatInfo *chatInfo;
@property (nonatomic,weak) id<CZEditFirTableViewCellDelegate>delegate;

@property (nonatomic,strong) NSString *groupTitleStr;

- (void)resetBaseInfo;
@end

NS_ASSUME_NONNULL_END
