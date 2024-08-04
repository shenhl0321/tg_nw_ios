//
//  TestHistoryViewController.h
//  GoChat
//
//  Created by wangyutao on 2021/2/25.
//

#import "BaseViewController.h"
#import "TestInfo.h"

@class TestHistoryViewController;
@protocol TestHistoryViewControllerDelegate <NSObject>
@optional
- (void)TestHistoryViewController_Choose:(TestInfo *)test;
@end

@interface TestHistoryViewController : BaseTableViewController
@property (nonatomic, weak) id<TestHistoryViewControllerDelegate> delegate;
@end
