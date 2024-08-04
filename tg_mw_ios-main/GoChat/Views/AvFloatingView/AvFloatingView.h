//
//  AvFloatingView.h
//  GoChat
//
//  Created by wangyutao on 2021/3/1.
//

#import "FloatingView.h"

@interface AvFloatingView : FloatingView
@property (nonatomic, weak) IBOutlet UIImageView *flagView;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;

- (void)resetCallInfo;
@end
