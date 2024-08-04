//
//  ChatTableView.h

@protocol BaseChatTableViewDelegate <UITableViewDelegate>
- (void)tableViewWasTouched:(UITableView *)tableView;
@end

@interface BaseChatTableView : UITableView

@property (nonatomic) BOOL isGroup;
@property (nonatomic) BOOL isMyFov;

- (BOOL)isHeaderViewShowing;
- (BOOL)isFooterViewShowing;
- (void)addHeaderView;
- (void)removeHeaderView;
- (void)addFooterView;
- (void)removeFooterView;
@end
