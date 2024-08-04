//
//  ModelPannelView.h
//  GoChat
//
//  Created by wangyutao on 2021/3/30.
//

#import <UIKit/UIKit.h>
#import "ModelPannelCell.h"

@protocol ModelPannelViewDelegate <NSObject>
@optional
- (void)ModelPannelView_Click_Model:(ChatModelType)type;
@end

@interface ModelPannelView : UIView
- (void)initP2pModel:(BOOL)isMyFov;
- (void)initGroupModel;
/// 群发助手模式
- (void)initGroupSentModel;
@property (nonatomic, weak) id<ModelPannelViewDelegate> delegate;
@end
