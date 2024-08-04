//
//  ChatMultiSelOptToolView.h
//  GoChat
//
//  Created by wangyutao on 2021/5/15.
//

#import <UIKit/UIKit.h>

@protocol ChatMultiSelOptToolViewDelegate <NSObject>
@optional
- (void)ChatMultiSelOptToolView_Forword;
- (void)ChatMultiSelOptToolView_Fov;
- (void)ChatMultiSelOptToolView_Revoke;
- (void)ChatMultiSelOptToolView_Delete;
@end

@interface ChatMultiSelOptToolView : UIView
@property (nonatomic, weak) IBOutlet UIButton *forwordBtn;
@property (nonatomic, weak) IBOutlet UIButton *fovBtn;
@property (nonatomic, weak) IBOutlet UIButton *revokeBtn;
@property (nonatomic, weak) IBOutlet UIButton *delBtn;

@property (nonatomic, weak) id<ChatMultiSelOptToolViewDelegate> delegate;
/// <#code#>
@property (nonatomic,strong) ChatInfo *chatInfo;
@end
