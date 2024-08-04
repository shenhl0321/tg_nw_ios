//
//  GC_OtherPhotoCell.h
//  GoChat
//
//  Created by wangfeiPro on 2022/1/7.
//

#import <UIKit/UIKit.h>
#import "BlogInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface GC_OtherPhotoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *photoContainView;
- (void)setData:(NSArray <BlogInfo *>*)arr;

@end

NS_ASSUME_NONNULL_END
