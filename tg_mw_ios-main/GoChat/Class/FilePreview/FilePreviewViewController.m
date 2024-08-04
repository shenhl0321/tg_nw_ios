//
//  FilePreviewViewController.m
//  GoChat
//
//  Created by wangyutao on 2021/6/2.
//

#import "FilePreviewViewController.h"
#import <QuickLook/QuickLook.h>

@interface FilePreviewViewController ()<BusinessListenerProtocol, QLPreviewControllerDelegate, QLPreviewControllerDataSource>
@property (nonatomic, weak) IBOutlet UIView *contentView2;
@property (nonatomic, strong) QLPreviewController *preview;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation FilePreviewViewController

- (void)dealloc
{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.customNavBar setTitle:@"文件预览".lv_localized];
    [self.contentView addSubview:self.contentView2];
    [self.contentView2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    [self loadDocument];
    
    
    //菜单
//    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    moreBtn.frame = CGRectMake(0, 0, 44, 44);
//    [moreBtn setImage:[UIImage imageNamed:@"icon_more_black"] forState:UIControlStateNormal];
//    [moreBtn setImage:[UIImage imageNamed:@"icon_more_black"] forState:UIControlStateHighlighted];
//    [moreBtn addTarget:self action:@selector(click_more) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    [self.customNavBar setRightBtnWithImageName:@"icon_more_black" title:nil highlightedImageName:@"icon_more_black"];
    
}
-(void)navigationBar:(MNNavigationBar *)navationBar didClickRightBtn:(UIButton *)btn{
    [self click_more];
}

- (void)loadDocument
{
    //先停止加载过程
    [self stopWaiting];
    DocumentInfo *documentInfo = self.previewMessage.content.document;
    if(!documentInfo.isFileDownloaded)
    {//未下载，启动下载
        [self startWaiting];
        if(![[TelegramManager shareInstance] isFileDownloading:documentInfo.document._id type:FileType_Message_Document] && documentInfo.document.remote.unique_id.length > 1)
        {
            NSString *key = [NSString stringWithFormat:@"%ld_%ld", self.previewMessage._id, documentInfo.document._id];
            [[TelegramManager shareInstance] DownloadFile:key fileId:documentInfo.document._id download_offset:0 type:FileType_Message_Document];
        }
    }
    else
    {
        QLPreviewController *preview = [[QLPreviewController alloc] init];
        preview.dataSource = self;
        preview.delegate = self;
        [self addChildViewController:preview];
        preview.view.frame = self.contentView.bounds;
        [self.contentView addSubview:preview.view];
        [preview didMoveToParentViewController:self];
        self.preview = preview;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.preview.view.frame = self.contentView.bounds;
}

- (void)startWaiting
{
    if (!self.activityIndicator)
    {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:activityIndicator];
        activityIndicator.hidesWhenStopped = YES;
        self.activityIndicator = activityIndicator;
    }
    self.activityIndicator.center = self.view.center;
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)stopWaiting
{
    [self.activityIndicator stopAnimating];
}

- (void)click_more
{
    NSString *localPath = [self documentPath:self.previewMessage];
    if(!IsStrEmpty(localPath))
    {
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"Image", [NSURL fileURLWithPath:localPath]] applicationActivities:nil];
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    else
    {
        [UserInfo showTips:nil des:@"文件未准备好，无法操作".lv_localized];
    }
}

- (NSString *)documentPath:(MessageInfo *)message
{
    if(message.content.document.isFileDownloaded)
    {
        return message.content.document.localFilePath;
    }
    return nil;
}

#pragma mark - QLPreviewController delegate
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:self.previewMessage.content.document.localFilePath];
}

#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Message_Document_Ok):
        {//@{@"task":task, @"file":fileInfo}
            NSDictionary *obj = inParam;
            if(obj != nil && [obj isKindOfClass:[NSDictionary class]])
            {
                FileTaskInfo *task = [obj objectForKey:@"task"];
                FileInfo *fileInfo = [obj objectForKey:@"file"];
                if(task != nil && fileInfo != nil)
                {
                    NSArray *list = [task._id componentsSeparatedByString:@"_"];
                    if(list.count == 2)
                    {
                        long msgId = [list.firstObject longLongValue];
                        if(self.previewMessage._id == msgId)
                        {
                            long fileId = [list.lastObject longLongValue];
                            if(self.previewMessage.content.document.document._id == fileId)
                            {
                                self.self.previewMessage.content.document.document = fileInfo;
                                [self loadDocument];
                            }
                        }
                    }
                }
            }
        }
            break;
        default:
            break;
    }
}

@end
