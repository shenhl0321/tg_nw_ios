//
//  BaseWebViewController.h

#import "BaseVC.h"
#import <WebKit/WebKit.h>
typedef enum
{
    WEB_LOAD_TYPE_NORMAL = 0,
    WEB_LOAD_TYPE_URL,
    WEB_LOAD_TYPE_TAB_EX_URL,
} WEB_LOAD_TYPE;


// WKWebView 内存不释放的问题解决
@interface WeakWebViewScriptMessageDelegate : NSObject<WKScriptMessageHandler>
//WKScriptMessageHandler 这个协议类专门用来处理JavaScript调用原生OC的方法
@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;
@end

@interface BaseWebViewController : BaseVC
@property (nonatomic, strong) NSString *htmlString;
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSString *urlStr;

@property (nonatomic) WEB_LOAD_TYPE type;
@property (nonatomic) BOOL canRotate;

/// 是否禁止缩放， 默认不禁止
@property (assign, nonatomic) BOOL isNoZoom;

@end
