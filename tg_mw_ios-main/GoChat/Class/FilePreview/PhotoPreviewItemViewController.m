//
//  PhotoPreviewItemViewController.m
//  GoChat
//
//  Created by wangyutao on 2020/12/28.
//

#import "PhotoPreviewItemViewController.h"
#import "PZPhotoView.h"

@interface PhotoPreviewItemViewController ()<PZPhotoViewDelegate, BusinessListenerProtocol>
@property (nonatomic, strong) PZPhotoView *photoView;
@end

@implementation PhotoPreviewItemViewController

- (void)dealloc
{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    
    self.photoView.photoViewDelegate = self;
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.photoView];
    [self.photoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self loadData];
}

-(PZPhotoView *)photoView{
    if (!_photoView) {
        _photoView = [[PZPhotoView alloc] init];
    }
    return _photoView;
}
- (void)loadData
{
    if(self.photo_message.messageType == MessageType_Photo)
    {
        [self loadImage];
    }
    else if(self.photo_message.messageType == MessageType_Animation){
        [self loadAnimation];
    }
    else
    {
        [self loadDocumentImage];
    }
}

- (void)loadImage
{
    //先停止加载过程
    [self.photoView stopWaiting];
    
    UIImage *image = nil;
    PhotoSizeInfo *b_photoInfo = self.photo_message.content.photo.previewPhoto;
    if(b_photoInfo != nil && b_photoInfo.isPhotoDownloaded)
    {//首先加载大图
        image = [UIImage imageWithContentsOfFile:b_photoInfo.photo.local.path];
    }
    else
    {//大图没有下载，则加载小图
        PhotoSizeInfo *s_photoInfo = self.photo_message.content.photo.messagePhoto;
        if(s_photoInfo != nil && s_photoInfo.isPhotoDownloaded)
        {
            image = [UIImage imageWithContentsOfFile:s_photoInfo.photo.local.path];
        }
        else
        {//小图也没有，则显示加载视图
            [self.photoView startWaiting];
        }
        //开始下载大图
        if(![[TelegramManager shareInstance] isFileDownloading:b_photoInfo.photo._id type:FileType_Message_Preview_Photo] && b_photoInfo.photo.remote.unique_id.length > 1)
        {
            NSString *key = [NSString stringWithFormat:@"%ld_%ld", self.photo_message._id, b_photoInfo.photo._id];
            [[TelegramManager shareInstance] DownloadFile:key fileId:b_photoInfo.photo._id download_offset:0 type:FileType_Message_Preview_Photo];
        }
    }
    //显示图片
    if(image != nil)
    {
        [self.photoView displayImage:image];
    }
}

- (void)loadAnimation {
    //先停止加载过程
    [self.photoView stopWaiting];
    
    AnimationInfo *videoInfo = self.photo_message.content.animation;
    if (!videoInfo.animation.local.is_downloading_completed) {
        [self.photoView startWaiting];
        if(![[TelegramManager shareInstance] isFileDownloading:videoInfo.animation._id type:FileType_Message_Animation]
           && videoInfo.animation.remote.unique_id.length > 1) {
            NSString *key = [NSString stringWithFormat:@"%ld_%ld", self.photo_message.chat_id, self.photo_message._id];
            [[TelegramManager shareInstance] DownloadFile:key fileId:videoInfo.animation._id download_offset:0 type:FileType_Message_Animation];
//            NSString *appUrl = [NSString stringWithFormat:@"app://video/%ld/%ld/%@", videoInfo.animation._id,videoInfo.animation.expected_size,videoInfo.mime_type];
//            [self setupGifPlayer:appUrl];
            
//            NSString *key = [NSString stringWithFormat:@"%ld_%ld", self.photo_message._id, b_photoInfo.photo._id];
//            [[TelegramManager shareInstance] DownloadFile:key fileId:b_photoInfo.photo._id download_offset:0 type:FileType_Message_Preview_Photo];
        }
        
    } else {
        [self setupGifPlayer:videoInfo.localVideoPath];
    }
}

- (void)setupGifPlayer:(NSString *)path {
    
    
    if (![path hasSuffix:@".gif"]) {
        path = [path stringByAppendingString:@".gif"];
    }
    
    NSData *imageData = [NSData dataWithContentsOfFile:path];

    UIImage *fadImage = [UIImage sd_imageWithGIFData:imageData];
    //显示图片
    if(fadImage != nil)
    {
        [self.photoView displayImage:fadImage];
    }
    
}

- (void)loadDocumentImage
{
    //先停止加载过程
    [self.photoView stopWaiting];
    
    UIImage *image = nil;
    if(self.photo_message.content.document.isFileDownloaded)
    {
        image = [UIImage imageWithContentsOfFile:self.photo_message.content.document.localFilePath];
    }
    else
    {//显示加载视图
        [self.photoView startWaiting];
    }
    //开始下载
    FileInfo *fileInfo = self.photo_message.content.document.document;
    if(![[TelegramManager shareInstance] isFileDownloading:fileInfo._id type:FileType_Message_Document]
       && fileInfo.remote.unique_id.length > 1)
    {
        NSString *key = [NSString stringWithFormat:@"%ld_%ld", self.photo_message._id, fileInfo._id];
        [[TelegramManager shareInstance] DownloadFile:key fileId:fileInfo._id download_offset:0 type:FileType_Message_Document];
    }
    //显示图片
    if(image != nil)
    {
        [self.photoView displayImage:image];
    }
}

#pragma mark - PZPhotoViewDelegate
- (void)photoViewDidSingleTap:(PZPhotoView *)photoView
{//单击退出浏览
    if([self.delegate respondsToSelector:@selector(PhotoPreviewItemViewController_SingleTap:)])
    {
        [self.delegate PhotoPreviewItemViewController_SingleTap:self];
    }
}

- (void)handleSwipeFrom:(PZPhotoView *)photoView{
    //退出浏览
    if([self.delegate respondsToSelector:@selector(PhotoPreviewItemViewController_SingleTap:)])
    {
        [self.delegate PhotoPreviewItemViewController_SingleTap:self];
    }
}

- (void)photoViewDidLongSingleTap:(PZPhotoView *)photoView
{//长按
    if([self.delegate respondsToSelector:@selector(PhotoPreviewItemViewController_LongPress:)])
    {
        [self.delegate PhotoPreviewItemViewController_LongPress:self];
    }
}

#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Message_Preview_Photo_Ok):
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
                        if(self.photo_message._id == msgId)
                        {
                            long fileId = [list.lastObject longLongValue];
                            if(self.photo_message.content.photo.previewPhoto.photo._id == fileId)
                            {
                                self.photo_message.content.photo.previewPhoto.photo = fileInfo;
                                [self loadData];
                            }
                        }
                    }
                }
            }
        }
            break;
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
                        if(self.photo_message._id == msgId)
                        {
                            long fileId = [list.lastObject longLongValue];
                            if(self.photo_message.content.document.document._id == fileId)
                            {
                                self.photo_message.content.document.document = fileInfo;
                                [self loadData];
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
