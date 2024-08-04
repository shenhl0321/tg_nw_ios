//
//  ModelPannelView.m
//  GoChat
//
//  Created by wangyutao on 2021/3/30.
//

#import "ModelPannelView.h"
#import "SDCycleScrollView.h"

@interface ModelPannelView ()<SDCycleScrollViewDelegate, ModelPannelCellDelegate>
@property (nonatomic, strong) NSMutableArray *modelPannelList;
@end

@implementation ModelPannelView

- (NSMutableArray *)modelPannelList
{
    if(_modelPannelList == nil)
    {
        _modelPannelList = [NSMutableArray array];
    }
    return _modelPannelList;
}

- (void)resetP2pModelData:(BOOL)isMyFov
{
    [self.modelPannelList removeAllObjects];
    //万聊隐藏位置   最后一个位置 统一隐藏
    if(isMyFov)
    {
        
        [self.modelPannelList addObject:@[
//            [ChatModelInfo modelInfoWithType:ChatModelType_Photo title:@"相册".lv_localized icon:@"icon_pn_photo"],
//            [ChatModelInfo modelInfoWithType:ChatModelType_Camera title:@"拍摄".lv_localized icon:@"icon_pn_pictures"],
//            [ChatModelInfo modelInfoWithType:ChatModelType_Card title:@"名片".lv_localized icon:@"icon_pn_card"],
//            [ChatModelInfo modelInfoWithType:ChatModelType_File title:@"文件".lv_localized icon:@"icon_pn_file"],
//            [ChatModelInfo modelInfoWithType:ChatModelType_Location title:@"位置".lv_localized icon:@"icon_pn_location"]
            
            [ChatModelInfo modelInfoWithType:ChatModelType_Photo title:@"相册".lv_localized icon:@"icon_chat01"],
            [ChatModelInfo modelInfoWithType:ChatModelType_Camera title:@"拍摄".lv_localized icon:@"icon_chat02"],
            [ChatModelInfo modelInfoWithType:ChatModelType_Card title:@"名片".lv_localized icon:@"icon_chat06"],
            [ChatModelInfo modelInfoWithType:ChatModelType_File title:@"文件".lv_localized icon:@"icon_chat07"],
            [ChatModelInfo modelInfoWithType:ChatModelType_Location title:@"位置".lv_localized icon:@"icon_chat08"]
        ]];
    }
    else
    {
        NSMutableArray *arr = [NSMutableArray array];
//        [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_Photo title:@"相册".lv_localized icon:@"icon_pn_photo"]];
//        [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_Camera title:@"拍摄".lv_localized icon:@"icon_pn_pictures"]];
//        if(ShowLocal_VoiceChat){
//            [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_AVCall title:@"视频通话".lv_localized icon:@"icon_pn_video"]];
//        }
//        AppConfigInfo *config = [AppConfigInfo sharedInstance];
//        if (config.can_send_redpacket) {
//            [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_Hongbao title:@"红包".lv_localized icon:@"icon_pn_hongbao"]];
//        }
//        if (config.can_remit) {
//            [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_Transfer title:@"转账".lv_localized icon:@"icon_pn_transfer"]];
//        }
//        [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_Card title:@"名片".lv_localized icon:@"icon_pn_card"]];
//        if (config.can_send_file) {
//            [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_File title:@"文件".lv_localized icon:@"icon_pn_file"]];
//        }
//        if (config.can_send_location) {
//            [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_Location title:@"位置".lv_localized icon:@"icon_pn_location"]];
//        }
        
        [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_Photo title:@"相册".lv_localized icon:@"icon_chat01"]];
        [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_Camera title:@"拍摄".lv_localized icon:@"icon_chat02"]];
        if(ShowLocal_VoiceChat){
            [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_AVCall title:@"视频通话".lv_localized icon:@"icon_chat03"]];
        }
        AppConfigInfo *config = [AppConfigInfo sharedInstance];
        if (config.can_send_redpacket) {
            [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_Hongbao title:@"红包".lv_localized icon:@"icon_chat04"]];
        }
        if (config.can_remit) {
            [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_Transfer title:@"转账".lv_localized icon:@"icon_chat05"]];
        }
        [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_Card title:@"名片".lv_localized icon:@"icon_chat06"]];
        if (config.can_send_file) {
            [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_File title:@"文件".lv_localized icon:@"icon_chat07"]];
        }
        if (config.can_send_location) {
            [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_Location title:@"位置".lv_localized icon:@"icon_chat08"]];
        }
        
        
        [self.modelPannelList addObject:arr];
//        if (Battling()) {
//            [self.modelPannelList addObject:@[
//                [ChatModelInfo modelInfoWithType:ChatModelType_Photo title:@"相册".lv_localized icon:@"icon_pn_photo"],
//                [ChatModelInfo modelInfoWithType:ChatModelType_Camera title:@"拍摄".lv_localized icon:@"icon_pn_pictures"],
//                [ChatModelInfo modelInfoWithType:ChatModelType_AVCall title:@"视频通话".lv_localized icon:@"icon_pn_video"],
//                [ChatModelInfo modelInfoWithType:ChatModelType_Card title:@"名片".lv_localized icon:@"icon_pn_card"],
//                [ChatModelInfo modelInfoWithType:ChatModelType_File title:@"文件".lv_localized icon:@"icon_pn_file"],
//                [ChatModelInfo modelInfoWithType:ChatModelType_Location title:@"位置".lv_localized icon:@"icon_pn_location"]
//            ]];
//        } else {
//            [self.modelPannelList addObject:@[
//                [ChatModelInfo modelInfoWithType:ChatModelType_Photo title:@"相册".lv_localized icon:@"icon_pn_photo"],
//                [ChatModelInfo modelInfoWithType:ChatModelType_Camera title:@"拍摄".lv_localized icon:@"icon_pn_pictures"],
//                [ChatModelInfo modelInfoWithType:ChatModelType_AVCall title:@"视频通话".lv_localized icon:@"icon_pn_video"],
//                [ChatModelInfo modelInfoWithType:ChatModelType_Hongbao title:@"红包".lv_localized icon:@"icon_pn_hongbao"],
//                [ChatModelInfo modelInfoWithType:ChatModelType_Transfer title:@"转账".lv_localized icon:@"icon_pn_transfer"],
//                [ChatModelInfo modelInfoWithType:ChatModelType_Card title:@"名片".lv_localized icon:@"icon_pn_card"],
//                [ChatModelInfo modelInfoWithType:ChatModelType_File title:@"文件".lv_localized icon:@"icon_pn_file"],
//                [ChatModelInfo modelInfoWithType:ChatModelType_Location title:@"位置".lv_localized icon:@"icon_pn_location"]
//            ]];
//        }
    }
    
}

- (void)resetGroupModelData
{
    [self.modelPannelList removeAllObjects];
//    if (Battling()) {
//        [self.modelPannelList addObject:@[
//            [ChatModelInfo modelInfoWithType:ChatModelType_Photo title:@"相册".lv_localized icon:@"icon_pn_photo"],
//            [ChatModelInfo modelInfoWithType:ChatModelType_Camera title:@"拍摄".lv_localized icon:@"icon_pn_pictures"],
//            [ChatModelInfo modelInfoWithType:ChatModelType_Card title:@"名片".lv_localized icon:@"icon_pn_card"],
//            [ChatModelInfo modelInfoWithType:ChatModelType_File title:@"文件".lv_localized icon:@"icon_pn_file"],
//            [ChatModelInfo modelInfoWithType:ChatModelType_Location title:@"位置".lv_localized icon:@"icon_pn_location"]
//        ]];
//    } else {
//        [self.modelPannelList addObject:@[
//            [ChatModelInfo modelInfoWithType:ChatModelType_Photo title:@"相册".lv_localized icon:@"icon_pn_photo"],
//            [ChatModelInfo modelInfoWithType:ChatModelType_Camera title:@"拍摄".lv_localized icon:@"icon_pn_pictures"],
//            [ChatModelInfo modelInfoWithType:ChatModelType_Hongbao title:@"红包".lv_localized icon:@"icon_pn_hongbao"],
//            [ChatModelInfo modelInfoWithType:ChatModelType_Card title:@"名片".lv_localized icon:@"icon_pn_card"],
//            [ChatModelInfo modelInfoWithType:ChatModelType_File title:@"文件".lv_localized icon:@"icon_pn_file"],
//            [ChatModelInfo modelInfoWithType:ChatModelType_Location title:@"位置".lv_localized icon:@"icon_pn_location"]
//        ]];
//    }
    NSMutableArray *arr = [NSMutableArray array];
    
    [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_Photo title:@"相册".lv_localized icon:@"icon_chat01"]];
    [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_Camera title:@"拍摄".lv_localized icon:@"icon_chat02"]];
    if(ShowLocal_VoiceChat){
        [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_AVCall title:@"视频通话".lv_localized icon:@"icon_chat03"]];
    }
    AppConfigInfo *config = [AppConfigInfo sharedInstance];
    if (config.can_send_redpacket) {
        [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_Hongbao title:@"红包".lv_localized icon:@"icon_chat04"]];
    }
    if (config.can_remit) {
        [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_Transfer title:@"转账".lv_localized icon:@"icon_chat05"]];
    }
    [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_Card title:@"名片".lv_localized icon:@"icon_chat06"]];
    if (config.can_send_file) {
        [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_File title:@"文件".lv_localized icon:@"icon_chat07"]];
    }
    if (config.can_send_location) {
        [arr addObject:[ChatModelInfo modelInfoWithType:ChatModelType_Location title:@"位置".lv_localized icon:@"icon_chat08"]];
    }
    [self.modelPannelList addObject:arr];
}

- (void)resetGroupSentModel {
    
    [self.modelPannelList addObject:@[
        [ChatModelInfo modelInfoWithType:ChatModelType_Photo title:@"相册".lv_localized icon:@"icon_chat01"],
        [ChatModelInfo modelInfoWithType:ChatModelType_Camera title:@"拍摄".lv_localized icon:@"icon_chat02"]
    ]];
    
}

- (void)initP2pModel:(BOOL)isMyFov
{
    [self resetP2pModelData:isMyFov];
    [self resetUI];
}

- (void)initGroupModel
{
    [self resetGroupModelData];
    [self resetUI];
}

- (void)initGroupSentModel {
    [self resetGroupSentModel];
    [self resetUI];
}

- (void)resetUI
{
    
    self.backgroundColor = [UIColor clearColor];
    for(UIView * v in [self subviews])
    {
        [v removeFromSuperview];
    }
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 240) delegate:self placeholderImage:nil];
    cycleScrollView.backgroundColor = [UIColor clearColor];
    cycleScrollView.showPageControl = self.modelPannelList.count>1;
//    cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
//    cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
//    cycleScrollView.pageControlBottomOffset = -5;
//    cycleScrollView.currentPageDotImage = [UIImage imageNamed:@"icon_full_circle"];
//    cycleScrollView.pageDotImage = [UIImage imageNamed:@"icon_empty_circle"];
    NSMutableArray *images = [NSMutableArray array];
    for(int i=0; i<self.modelPannelList.count; i++)
    {
        [images addObject:@""];
    }
    cycleScrollView.imageURLStringsGroup = images;
    cycleScrollView.autoScroll = NO;
    [self addSubview:cycleScrollView];
}

#pragma mark - SDCycleScrollViewDelegate
- (UINib *)customCollectionViewCellNibForCycleScrollView:(SDCycleScrollView *)view
{
    return [UINib nibWithNibName:@"ModelPannelCell" bundle:nil];
}

- (void)setupCustomCell:(UICollectionViewCell *)cell forIndex:(NSInteger)index cycleScrollView:(SDCycleScrollView *)view
{
    ModelPannelCell *pannel = (ModelPannelCell *)cell;
    [pannel resetModelsList:[self.modelPannelList objectAtIndex:index]];
    pannel.delegate = self;
}

- (void)ModelPannelCell_Click_Model:(ModelPannelCell *)cell model:(ChatModelInfo *)model
{
    if([self.delegate respondsToSelector:@selector(ModelPannelView_Click_Model:)])
    {
        [self.delegate ModelPannelView_Click_Model:model.type];
    }
}

@end
