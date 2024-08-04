//
//  ChatTableView.m

#import "BaseChatTableView.h"

#define Header_Type_ActivityIndicatorView 1000
#define Header_Type_TipView 1001
#define Header_Type_ActivityIndicatorViewATipView 1002
#define Header_Tip_Def [NSString stringWithFormat:@"当前对话已被%@端对端加密保护", APP_NAME]
@interface BaseChatTableView ()
@end

@implementation BaseChatTableView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableViewWasTouched:)])
    {
        [(id<BaseChatTableViewDelegate>)self.delegate tableViewWasTouched:self];
    }
    [super touchesBegan:touches withEvent:event];
}

- (UIView *)headerIndicatorContentView  //只有等待动画
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    view.backgroundColor = [UIColor clearColor];
    view.tag = Header_Type_ActivityIndicatorView;
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = CGPointMake(view.center.x, view.center.y);
    [activityIndicatorView startAnimating];
    activityIndicatorView.hidesWhenStopped = YES;
    [view addSubview:activityIndicatorView];
    return view;
}

//- (UIView *)headerTipContentView   //只有顶部加密提示
//{
//    return [UIView new];
//}

//- (UIView *)headerIndicatorContentViewATipContentView   //加密提示和动画
//{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 90)];
//    view.tag = Header_Type_ActivityIndicatorViewATipView;
//    view.backgroundColor = [UIColor clearColor];
//
//    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    activityIndicatorView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 30);
//    [activityIndicatorView startAnimating];
//    activityIndicatorView.hidesWhenStopped = YES;
//    [view addSubview:activityIndicatorView];
//
//    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 40, SCREEN_WIDTH - 100, 50)];
//    tipLabel.backgroundColor = [UIColor clearColor];
//    tipLabel.textColor = HEX_COLOR(@"#999999");
//    tipLabel.layer.cornerRadius = 8;
//    tipLabel.text = Header_Tip_Def;
//    tipLabel.textAlignment = NSTextAlignmentCenter;
//    tipLabel.layer.borderWidth = 0.5f;
//    tipLabel.layer.borderColor = RGB(198, 199, 200).CGColor;
//    tipLabel.font = [UIFont systemFontOfSize:FONT_S2];
//    [view addSubview:tipLabel];
//    return view;
//}

- (void)addHeaderView
{
    if(self.isGroup || self.isMyFov)
    {
        self.tableHeaderView = self.headerIndicatorContentView;
    }
    else
    {
        self.tableHeaderView = self.headerIndicatorContentView;
    }
}

- (void)removeHeaderView
{
    if(self.isGroup || self.isMyFov) //是群组  是收藏
    {
        self.tableHeaderView = nil;
    }
    else
    {//不是群组  不是收藏   私聊？
        self.tableHeaderView = nil;
    }
}

- (void)addFooterView
{
    if (self.tableFooterView)
    {
        return;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    view.backgroundColor = [UIColor clearColor];
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.tag = 2003;
    activityIndicatorView.center = CGPointMake(view.center.x, view.center.y);
    [activityIndicatorView startAnimating];
    activityIndicatorView.hidesWhenStopped = YES;
    
    [view addSubview:activityIndicatorView];
    
    self.tableFooterView = view;
}

- (void)removeFooterView
{
    self.tableFooterView = nil;
}

- (BOOL)isHeaderViewShowing
{
    if(self.isGroup || self.isMyFov)
    {
        return self.tableHeaderView != nil;
    }
    else
    {
        if(self.tableHeaderView == nil)
        {
            return NO;
        }
        else
        {
            if(self.tableHeaderView.tag == Header_Type_ActivityIndicatorViewATipView)
            {
                return YES;
            }
            else
            {
                return NO;
            }
        }
    }
}

- (BOOL)isFooterViewShowing
{
    return self.tableFooterView != nil;
}

@end
