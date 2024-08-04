//
//  PhotoPreviewItemViewController.h
//  GoChat
//
//  Created by wangyutao on 2020/12/28.
//

@class PhotoPreviewItemViewController;
@protocol PhotoPreviewItemViewControllerDelegate <NSObject>
@optional
- (void)PhotoPreviewItemViewController_SingleTap:(PhotoPreviewItemViewController *)controller;
- (void)PhotoPreviewItemViewController_LongPress:(PhotoPreviewItemViewController *)controller;
@end

@interface PhotoPreviewItemViewController : UIViewController
@property (nonatomic, strong) MessageInfo *photo_message;
@property (nonatomic, weak) id<PhotoPreviewItemViewControllerDelegate> delegate;
@end
