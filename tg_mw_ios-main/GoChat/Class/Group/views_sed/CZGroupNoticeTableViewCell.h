//
//  CZGroupNoticeTableViewCell.h
//  GoChat
//
//  Created by mac on 2021/7/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZGroupNoticeTableViewCell : UITableViewCell

@property (nonatomic,assign) BOOL isShowAll;
@property (nonatomic,copy) NSString *groupNoticeStr;
@property (nonatomic, copy) NSString *gonggaoStr;
- (void)refreshMainLabelWithText:(NSString *)text;
@property (nonatomic, assign) BOOL hiddeLine;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;

@end

NS_ASSUME_NONNULL_END
