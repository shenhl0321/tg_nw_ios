//
//  GotWpPasswordContentDialog.h

#import <UIKit/UIKit.h>

@class GotWpPasswordContentDialog;
@protocol GotWpPasswordContentDialogDelegate <NSObject>
@optional
- (void)GotWpPasswordContentDialog_withPassword:(NSString *)password;
@end

@interface GotWpPasswordContentDialog : UIView
- (void)initWt:(id)wt payPrice:(float)payPrice;

@property (weak, nonatomic) IBOutlet UILabel *paymentTypeLabel;
@property (nonatomic, weak) IBOutlet UIButton *closeBtn;
@property (nonatomic, weak) id<GotWpPasswordContentDialogDelegate> delegate;
@end
