//
//  MNTabExploreVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/21.
//

#import "MNTabExploreVC.h"
#import <WebKit/WebKit.h>


@interface MNTabExploreVC ()<WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate, BusinessListenerProtocol>

@property (nonatomic, strong) WKWebView *  webView;
//网页加载进度视图
@property (nonatomic, strong) UIProgressView * progressView;

@end

@implementation MNTabExploreVC

#pragma mark - Override
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    
    [self setupNavigationItem];
    [self.contentView addSubview:self.webView];
    [self.contentView addSubview:self.progressView];
    //添加监测网页加载进度的观察者
    [self.webView addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(estimatedProgress))
                      options:0
                      context:nil];
    [self.webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
//    UIEdgeInsets insets = self.view.safeAreaInsets;
//    self.progressView.frame = CGRectMake(0, insets.top + 2, self.view.frame.size.width, 2);
    self.progressView.frame = CGRectMake(0,  2, self.view.frame.size.width, 2);
}

- (void)dealloc
{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
    //移除注册的js方法
    //[[_webView configuration].userContentController removeScriptMessageHandlerForName:@"jsToOcNoPrams"];
    //[[_webView configuration].userContentController removeScriptMessageHandlerForName:@"jsToOcWithPrams"];
    //移除观察者
    [_webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [_webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(title))];
}

#pragma mark - UI
- (void)setupNavigationItem
{
    self.title = self.titleString;
    
    [self.customNavBar setTitle:self.titleString];
    
    UIButton *btn = [self.customNavBar setLeftBtnWithImageName:@"NavBack" title:nil highlightedImageName:@"NavBack"];
    [btn addTarget:self action:@selector(gotoBack_Present) forControlEvents:UIControlEventTouchUpInside];
}

- (void)gotoBack_Present
{
    if (self.webView.canGoBack==YES) {
            [self.webView goBack];
    }
//    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (void)goBackAction:(id)sender
//{
//    [_webView goBack];
//}

#pragma mark - KVO
//kvo 监听进度 必须实现此方法
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]
        && object == _webView)
    {
        NSLog(@"网页加载进度 = %f",_webView.estimatedProgress);
        self.progressView.progress = _webView.estimatedProgress;
        if (_webView.estimatedProgress >= 1.0f)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.progress = 0;
            });
        }
    }
    else if([keyPath isEqualToString:@"title"]
             && object == _webView)
    {
        self.navigationItem.title = _webView.title;
    }
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

#pragma mark - Getter
- (UIProgressView *)progressView
{
    if (!_progressView)
    {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusBarHeight + 2, self.view.frame.size.width, 2)];
        _progressView.tintColor = COLOR_CG1;
        _progressView.trackTintColor = [UIColor clearColor];
    }
    return _progressView;
}

- (WKWebView *)webView
{
    if(_webView == nil)
    {
        NSString *userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 16_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.3 Mobile/15E148 Safari/604.1";
        
        //创建网页配置对象
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        // 创建设置对象
        WKPreferences *preference = [[WKPreferences alloc]init];
        //最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
        preference.minimumFontSize = 0;
        //设置是否支持javaScript 默认是支持的
        preference.javaScriptEnabled = YES;
        // 在iOS上默认为NO，表示是否允许不经过用户交互由javaScript自动打开窗口
        preference.javaScriptCanOpenWindowsAutomatically = YES;
        config.preferences = preference;

        // 是使用h5的视频播放器在线播放, 还是使用原生播放器全屏播放
        config.allowsInlineMediaPlayback = YES;
        //设置视频是否需要用户手动播放  设置为NO则会允许自动播放
        //config.requiresUserActionForMediaPlayback = YES;
        //设置是否允许画中画技术 在特定设备上有效
        config.allowsPictureInPictureMediaPlayback = YES;
        //设置请求的User-Agent信息中应用程序名称 iOS9后可用
        config.applicationNameForUserAgent = userAgent;
        
        //自定义的WKScriptMessageHandler 是为了解决内存不释放的问题
        //WeakWebViewScriptMessageDelegate *weakScriptMessageDelegate = [[WeakWebViewScriptMessageDelegate alloc] initWithDelegate:self];
        //这个类主要用来做native与JavaScript的交互管理
        //WKUserContentController * wkUController = [[WKUserContentController alloc] init];
        //注册一个name为jsToOcNoPrams的js方法 设置处理接收JS方法的对象
        //[wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"jsToOcNoPrams"];
        //[wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"jsToOcWithPrams"];
        //config.userContentController = wkUController;
        
        //以下代码适配文本大小
        NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        //用于进行JavaScript注入
        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [config.userContentController addUserScript:wkUScript];
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.contentView.frame.size.height) configuration:config];
        _webView.customUserAgent = userAgent;
        // UI代理
        _webView.UIDelegate = self;
        // 导航代理
        _webView.navigationDelegate = self;
        // 是否允许手势左滑返回上一级, 类似导航控制的左滑返回
        _webView.allowsBackForwardNavigationGestures = YES;

        TabExMenuInfo *curTabExMenuInfo = [TabExMenuInfo getTabExMenuInfo];
        if(curTabExMenuInfo != nil && [curTabExMenuInfo isValid])
        {
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:curTabExMenuInfo.site_url]]];
//                self.title = curTabExMenuInfo.title;
            [self.customNavBar setTitle:curTabExMenuInfo.site_name];
        }
    }
    return _webView;
}

//解决 页面内跳转（a标签等）还是取不到cookie的问题
- (void)getCookie
{
    //取出cookie
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //js函数
    NSString *JSFuncString =
    @"function setCookie(name,value,expires)\
    {\
    var oDate=new Date();\
    oDate.setDate(oDate.getDate()+expires);\
    document.cookie=name+'='+value+';expires='+oDate+';path=/'\
    }\
    function getCookie(name)\
    {\
    var arr = document.cookie.match(new RegExp('(^| )'+name+'=([^;]*)(;|$)'));\
    if(arr != null) return unescape(arr[2]); return null;\
    }\
    function delCookie(name)\
    {\
    var exp = new Date();\
    exp.setTime(exp.getTime() - 1);\
    var cval=getCookie(name);\
    if(cval!=null) document.cookie= name + '='+cval+';expires='+exp.toGMTString();\
    }";
    
    //拼凑js字符串
    NSMutableString *JSCookieString = JSFuncString.mutableCopy;
    for (NSHTTPCookie *cookie in cookieStorage.cookies)
    {
        NSString *excuteJSString = [NSString stringWithFormat:@"setCookie('%@', '%@', 1);", cookie.name, cookie.value];
        [JSCookieString appendString:excuteJSString];
    }
    //执行js
    [_webView evaluateJavaScript:JSCookieString completionHandler:nil];
}

//被自定义的WKScriptMessageHandler在回调方法里通过代理回调回来，绕了一圈就是为了解决内存不释放的问题
//通过接收JS传出消息的name进行捕捉的回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"name:%@\\\\n body:%@\\\\n frameInfo:%@\\\\n",message.name,message.body,message.frameInfo);
    //用message.body获得JS传出的参数体
//    NSDictionary * parameter = message.body;
    //JS调用OC
//    if([message.name isEqualToString:@"jsToOcNoPrams"])
//    {
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"js调用到了oc" message:@"不带参数" preferredStyle:UIAlertControllerStyleAlert];
//        [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        }])];
//        [self presentViewController:alertController animated:YES completion:nil];
//
//    }else if([message.name isEqualToString:@"jsToOcWithPrams"]){
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"js调用到了oc" message:parameter[@"params"] preferredStyle:UIAlertControllerStyleAlert];
//        [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        }])];
//        [self presentViewController:alertController animated:YES completion:nil];
//    }
}

#pragma mark - WKNavigationDelegate
/*
 WKNavigationDelegate主要处理一些跳转、加载处理操作，WKUIDelegate主要处理JS脚本，确认框，警告框等
 */
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [self.progressView setProgress:0.0f animated:NO];
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self getCookie];
}

//提交发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self.progressView setProgress:0.0f animated:NO];
}

// 接收到服务器跳转请求即服务重定向时之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
}

// 根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSString * urlStr = navigationAction.request.URL.absoluteString;
    NSLog(@"发送跳转请求：%@",urlStr);
    
    
    if ([urlStr containsString:@".mobileprovision"] || [urlStr containsString:@"mobile_config_steam"] ||[urlStr containsString:@".ipa"] ||[urlStr containsString:@".apk"] || [urlStr hasPrefix:@"itms-services://"]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否下载安装？" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        }])];
        [alertController addAction:([UIAlertAction actionWithTitle:@"打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        }])];
        [self presentViewController:alertController animated:YES completion:nil];

        decisionHandler(WKNavigationActionPolicyCancel);

    }
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

// 根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    NSString * urlStr = navigationResponse.response.URL.absoluteString;
    NSLog(@"当前跳转地址：%@",urlStr);
    
    if ([urlStr containsString:@".mobileprovision"] || [urlStr containsString:@"mobile_config_steam"] ||[urlStr containsString:@".ipa"] ||[urlStr containsString:@".apk"] || [urlStr hasPrefix:@"itms-services://"]) {
        //不允许跳转
        decisionHandler(WKNavigationResponsePolicyCancel);
    } else {
        //允许跳转
        decisionHandler(WKNavigationResponsePolicyAllow);
    }

}

//需要响应身份验证时调用 同样在block中需要传入用户身份凭证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    //用户身份信息
    NSURLCredential *newCred = [[NSURLCredential alloc] initWithUser:@"user123" password:@"123" persistence:NSURLCredentialPersistenceNone];
    //为 challenge 的发送方提供 credential
    [challenge.sender useCredential:newCred forAuthenticationChallenge:challenge];
    completionHandler(NSURLSessionAuthChallengeUseCredential,newCred);
}

//进程被终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
}

#pragma mark - WKUIDelegate
/**
 *  web界面中有弹出警告框时调用
 *
 *  @param webView           实现该代理的webview
 *  @param message           警告框中的内容
 *  @param completionHandler 警告框消失调用
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确定".lv_localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 确认框
//JavaScript调用confirm方法后回调的方法 confirm是js中的确定框，需要在block中把用户选择的情况传递进去
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消".lv_localized style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确定".lv_localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 输入框
//JavaScript调用prompt方法后回调的方法 prompt是js中的输入框 需要在block中把用户输入的信息传入
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确定".lv_localized style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 页面是弹出窗口 _blank 处理
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame)
    {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Tab_Ex_Menu_Changed):
        {
            TabExMenuInfo *curTabExMenuInfo = [TabExMenuInfo getTabExMenuInfo];
            if(curTabExMenuInfo != nil && [curTabExMenuInfo isValid])
            {
                [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:curTabExMenuInfo.site_url]]];
                self.title = curTabExMenuInfo.site_name;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - 控制屏幕旋转方法
//是否自动旋转,返回YES可以自动旋转,返回NO禁止旋转
- (BOOL)shouldAutorotate
{
    return self.canRotate;
}

//返回支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if(self.canRotate)
        return UIInterfaceOrientationMaskAllButUpsideDown;
    else
        return UIInterfaceOrientationMaskPortrait;
}

//由模态推出的视图控制器 优先支持的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if(self.canRotate)
        return UIInterfaceOrientationPortrait|UIInterfaceOrientationLandscapeLeft|UIInterfaceOrientationLandscapeRight;
    else
        return UIInterfaceOrientationPortrait;
}

@end
