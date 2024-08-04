//
//  VideoPreviewItemViewController.h
//  GoChat
//
//  Created by wangyutao on 2020/12/28.
//

@interface VideoPreviewItemViewController : UIViewController
@property (nonatomic, strong) MessageInfo *video_message;

@property (nonatomic, copy) dispatch_block_t longPressBlock;

@end
