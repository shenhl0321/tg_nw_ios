//
//  DeleteTipPopView.h
//  LoganSmart
//
//  Created by 许蒙静 on 2021/10/25.
//

#import "BottomPopView.h"
#import "UIColorButton.h"
//#import "RegisterDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface DeleteTipPopView : BottomPopView
<CommonDelegate>
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIColorButton *cancelBtn;
@property (nonatomic, strong) UIColorButton *deleteBtn;

- (void)refreshContent:(NSString *)content;

//@property (nonatomic, weak)  id <CommonDelegate> commonDelegate;

- (instancetype)initWithContent:(NSString *)content;
@end

NS_ASSUME_NONNULL_END
