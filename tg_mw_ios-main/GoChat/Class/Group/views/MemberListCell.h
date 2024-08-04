//
//  MemberListCell.h
//  GoChat
//
//  Created by wangyutao on 2020/12/10.
//

#import <UIKit/UIKit.h>

@class MemberListCell;
@protocol MemberListCellDelegate <NSObject>
@optional
- (void)MemberListCell_Click_Member:(MemberListCell *)cell member:(GroupMemberInfo *)member;
- (void)MemberListCell_AddMember:(MemberListCell *)cell;
- (void)MemberListCell_DeleteMember:(MemberListCell *)cell;
@end

@interface MemberListCell : UITableViewCell
+ (CGFloat)cellHeight:(NSArray *)members canAdd:(BOOL)canAdd canDelete:(BOOL)canDelete;
- (void)resetMembersList:(NSArray *)list canAdd:(BOOL)canAdd canDelete:(BOOL)canDelete;
- (void)resetTitle:(NSString *)title;
@property (nonatomic, weak) id<MemberListCellDelegate> delegate;
@end
