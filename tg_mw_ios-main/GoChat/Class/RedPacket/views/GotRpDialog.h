//
//  GotRpDialog.h

#import <UIKit/UIKit.h>
#import "MMPopupView.h"

@class GotRpDialog;
@protocol GotRpDialogDelegate <NSObject>
@optional
- (void)GotRpDialog_viewDetail:(RedPacketInfo *)rp;
@end

@interface GotRpDialog : MMPopupView
- (instancetype)initDialog:(RedPacketInfo *)rp;
@property (nonatomic, weak) id<GotRpDialogDelegate> delegate;
@end
