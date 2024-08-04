//
//  TestViewController.m
//  GoChat
//
//  Created by wangyutao on 2021/2/25.
//

#import "TestViewController.h"
#import "TestHistoryViewController.h"
#import "TestInfo.h"
#import <AgoraRtcKit/AgoraRtcEngineKit.h>

@interface TestViewController ()<TestHistoryViewControllerDelegate>
@property (nonatomic, weak) IBOutlet UITextField *nameTf;
@property (nonatomic, weak) IBOutlet UITextField *methodTf;
@property (nonatomic, weak) IBOutlet UITextView *bodyTv;
@property (nonatomic, weak) IBOutlet UITextView *resultTv;
@end

@implementation TestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"自定义测试".lv_localized;
    
    self.methodTf.text = @"relayData";
    self.bodyTv.text = @"{\"action\":\"test\",\"from\":136817707,\"to\":[136817689],\"data\":{\"uid\":\"123\"}}";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"历史".lv_localized forState:UIControlStateNormal];
    if(Is_Special_Theme)
    {
        [btn setTitleColor:COLOR_CG1 forState:UIControlStateNormal];
    }
    else
    {
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    [btn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    CGSize titleSize = [@"历史".lv_localized sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    btn.frame = CGRectMake(0, 0, titleSize.width, 44);
    [btn addTarget:self action:@selector(gotoHistory) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)gotoHistory
{
    TestHistoryViewController *v = [[UIStoryboard storyboardWithName:@"test" bundle:nil] instantiateViewControllerWithIdentifier:@"TestHistoryViewController"];
    v.delegate = self;
    [self.navigationController pushViewController:v animated:YES];
}

- (void)TestHistoryViewController_Choose:(TestInfo *)test
{
    self.nameTf.text = test.name;
    self.methodTf.text = test.method;
    self.bodyTv.text = test.body;
    self.resultTv.text = nil;
}

- (IBAction)click_run:(id)sender
{
    NSString *name = self.nameTf.text;
    NSString *method = self.methodTf.text;
    if(IsStrEmpty(method))
    {
        [UserInfo showTips:nil des:@"请输入方法名称".lv_localized];
        return;
    }
    NSString *body = self.bodyTv.text;
    if(IsStrEmpty(body))
    {
        [UserInfo showTips:nil des:@"请输入参数".lv_localized];
        return;
    }
    
    self.resultTv.text = nil;
    [UserInfo show:@"开始执行方法...".lv_localized];
    [[TelegramManager shareInstance] sendCustomRequest:method parameters:body resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        self.resultTv.text = [NSString stringWithFormat:@"%@", response];
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        self.resultTv.text = @"执行超时".lv_localized;
    }];
    
    //保存历史
    TestInfo *test = [TestInfo new];
    test.method = method;
    test.body = body;
    if(IsStrEmpty(name))
    {
        test.name = method;
    }
    else
    {
        test.name = name;
    }
    [TestInfo saveTestInfo:test];
}

@end
