//
//  GotRpContentDialog.h

#import <UIKit/UIKit.h>

@class GotRpContentDialog;
@protocol GotRpContentDialogDelegate <NSObject>
@optional
- (void)GotRpContentDialog_viewDetail:(RedPacketInfo *)rp;
- (void)GotRpContentDialog_close;
@end

@interface GotRpContentDialog : UIView
- (void)initRp:(RedPacketInfo *)rp;

@property (nonatomic, weak) IBOutlet UIButton *closeBtn;
@property (nonatomic, weak) id<GotRpContentDialogDelegate> delegate;
@end
