//
//  ReadyEditViewController.h
//  GoChat
//
//  Created by 吴亮 on 2021/10/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReadyEditViewController : UIViewController

@property (nonatomic, strong) UIImage * oriImage;
@property (nonatomic, copy) void (^doneButtonClickBlock)(UIImage * image);

@end

NS_ASSUME_NONNULL_END
