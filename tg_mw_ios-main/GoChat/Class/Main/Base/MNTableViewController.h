//
//  MNTableViewController.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNTableViewController : UITableViewController
<MNNavigationBarDelegate>
@property (nonatomic, strong) MNNavigationBar *customNavBar;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *backBtn;
- (void)refreshCustonNavBarFrame:(CGRect)frame;


-(void)back;
@end

NS_ASSUME_NONNULL_END
