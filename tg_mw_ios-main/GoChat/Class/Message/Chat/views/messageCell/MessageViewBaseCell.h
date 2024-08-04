//
//  MessageViewBaseCell.h
//  GoChat
//
//  Created by wangyutao on 2020/11/12.
//

#import <UIKit/UIKit.h>

//昵称高度
#define MessageCellNicknameHeight 20
//头像宽度+高度
#define MessageCellAvatarWidth 42
#define MessageCellAvatarHeight 42
//头像边距，左右边距-10
#define MessageCellHeadHorizontalMargins 10
//内容区最小高度
#define MessageCellContentMinHeight 42
//时间戳区域所占的高度
#define MessageCellTimestampRegionHeight 20
//消息cell上下边距
#define MessageCellVertMargins 12

@class MessageViewBaseCell;

@protocol MessageViewBaseCellDelegate <NSObject>

@optional

/**
 *  即将删除消息的回调，即长按菜单选择了删除消息
 *
 *  @param cell 消息所在cell
 */
- (void)messageCellWillDeleteMessage:(MessageViewBaseCell *)cell;

/**
 *  即将撤回消息的回调，即长按菜单选择了撤回消息
 *
 *  @param cell 消息所在cell
 */
- (void)messageCellWillRevokeMessage:(MessageViewBaseCell *)cell;

/**
 *  转发回调，即长按菜单选择了转发消息
 *
 *  @param cell 消息所在cell
 */
- (void)messageCellWillForwardMessage:(MessageViewBaseCell *)cell;

//引用
- (void)messageCellWillQuoteMessage:(MessageViewBaseCell *)cell;

/**
 *  收藏
 */
- (void)messageCellWillFavorMessage:(MessageViewBaseCell *)cell;

/**
 *  进入多选模式
 *
 *  @param cell 消息所在cell
 */
- (void)messageCellWillGotoMultiSelectingMode:(MessageViewBaseCell *)cell;

/**
 *  是否多选模式-touch屏蔽使用
 */
- (BOOL)messageCellIsMultiSelectingMode;

/**
 *  是否可以进入多选模式
 *
 *  @param cell 消息所在cell
 */
- (BOOL)messageCellIsCanGotoMultiSelectingMode:(MessageViewBaseCell *)cell;

/**
 *  选择变化事件
 *
 *  @param cell 消息所在cell
 */
- (void)messageCellSelectChanged:(MessageViewBaseCell *)cell;

@end

@interface MessageViewBaseCell : UITableViewCell

@property (nonatomic, assign) BOOL isGroup;//判断一下是不是群组

@property (nonatomic, assign) BOOL isSecret;//是否是私密聊天

@property (nonatomic, strong) NSArray *groupMembers;

@property (nonatomic, strong, readonly) MessageInfo *chatRecordDTO;
/// 回话信息，私密聊天时有用
@property (nonatomic,strong) ChatInfo *chatInfo;

//展示内容的父view，一般是xib的基础view
@property (nonatomic, strong) IBOutlet UIView *contentBaseView;

@property (nonatomic, weak) id <MessageViewBaseCellDelegate> delegate;

/**
*  某条消息内容在tableView中展示时所需的cell高度
*
*  @param chatRecordDTO 待展示的消息
*
*  @return 实际需要的高度，默认返回0，
*/
+ (CGFloat)contentHeightForTableViewWith:(MessageInfo *)chatRecordDTO showNickName:(BOOL)showNickName;

/**
 *  加载聊天消息
 *
 *  @param chatRecordDTO 待配置的消息
 */
- (void)loadChatRecord:(MessageInfo *)chatRecordDTO;

- (void)loadChatRecord:(MessageInfo *)chatRecordDTO isGroup:(BOOL)isGroup;

//安装或卸载手势
- (void)setupTapGesture;

/**
 *  还原cell，子类实现，并且需要super该方法
 */
- (void)reset;

/**
 *  初始化contentBaseView，子类根据实际实现以及是否需super该方法，并初始化自己的一些状态
 */
- (void)initialize;

/**
 *  配置，子类实现，并且需要super该方法
 */
- (void)config;

/**
 *  调整frame，子类实现，并且需要super该方法
 */
- (void)adjustFrame;

/**
 *  长按消息内容时的菜单，子类实现
 *
 *  @return 由各个子类实现 返回nil或者包含不少于一个的UIMenuItem，默认返回一个nil
 */
- (NSArray *)menuItems;

/**
 *  单击，子类实现，需要super该方法
 *
 */
- (void)singleTap:(UITapGestureRecognizer *)singleTapGesture;

/**
 *  双击，子类实现，需要super该方法
 *
 *  @param doubleTapGesture 双击手势
 */
- (void)doubleTap:(UITapGestureRecognizer *)doubleTapGesture;

/**
 *  长按，子类实现，需要super该方法
 *
 *  @param longPressGesture 手势
 */
- (void)longPress:(UILongPressGestureRecognizer *)longPressGesture;

//派生类使用
- (BOOL)IsCanGotoMultiSelectingMode;
- (BOOL)IsMultiSelectingMode;
@end
