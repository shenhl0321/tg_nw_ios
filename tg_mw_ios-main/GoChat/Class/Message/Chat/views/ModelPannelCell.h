//
//  ModelPannelCell.h
//  GoChat
//
//  Created by wangyutao on 2021/3/30.
//

#import <UIKit/UIKit.h>

//文件类型定义
typedef enum {
    //相册
    ChatModelType_Photo = 1,
    //拍摄
    ChatModelType_Camera,
    //视频通话
    ChatModelType_AVCall,
    
    ChatModelType_Hongbao,
    
    ChatModelType_Transfer,
    //文件
    ChatModelType_File,
    //位置
    ChatModelType_Location,
    //名片
    ChatModelType_Card,
} ChatModelType;

@class ModelPannelCell;
@class ChatModelInfo;
@protocol ModelPannelCellDelegate <NSObject>
@optional
- (void)ModelPannelCell_Click_Model:(ModelPannelCell *)cell model:(ChatModelInfo *)model;
@end

@interface ChatModelInfo : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic) ChatModelType type;

+ (instancetype)modelInfoWithType:(ChatModelType)type title:(NSString *)title icon:(NSString *)icon;
@end

@interface ModelPannelCell : UICollectionViewCell
- (void)resetModelsList:(NSArray *)list;
@property (nonatomic, weak) id<ModelPannelCellDelegate> delegate;
@end
