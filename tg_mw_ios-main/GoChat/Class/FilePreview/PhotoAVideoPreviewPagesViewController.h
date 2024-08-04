//
//  PhotoAVideoPreviewPagesViewController.h
//  GoChat
//
//  Created by wangyutao on 2020/12/28.
//

#import "WMPageController.h"

@interface PhotoAVideoPreviewPagesViewController : WMPageController
@property (nonatomic, strong) NSArray *previewList;
@property (nonatomic) int curIndex;
@property (nonatomic, copy) dispatch_block_t previewPopCallback;
@end
