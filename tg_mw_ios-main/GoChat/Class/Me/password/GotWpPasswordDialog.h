//
//  GotWpPasswordDialog.h

#import <UIKit/UIKit.h>
#import "MMPopupView.h"


typedef enum  {
    PAYMENT_TYPE_OTHER  = 0,
    PAYMENT_TYPE_RED_PACKET,
    PAYMENT_TYPE_GROUP_RED_PACKET,
    PAYMENT_TYPE_TIXIAN,
} PAYMENT_TYPE;

@class GotWpPasswordDialog;
@protocol GotWpPasswordDialogDelegate <NSObject>
@optional
- (void)GotWpPasswordDialog_withPassword:(NSString *)password;
@end

@interface GotWpPasswordDialog : MMPopupView
- (instancetype)initDialog:(id)wt payPrice:(float)payPrice paymentType:(PAYMENT_TYPE)type;
@property (nonatomic, weak) id<GotWpPasswordDialogDelegate> delegate;
@end
