//
//  ChatBgTableViewController.m
//  GoChat
//
//  Created by 李标 on 2021/5/15.
//

#import "ChatBgTableViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MNChatViewController.h"
#import "ChatExCacheManager.h"
#import "TZImagePickerController.h"
#import "AssetsChatBgViewController.h"

@interface ChatBgTableViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation ChatBgTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"聊天背景".lv_localized;
//    [self.customNavBar setTitle:@"聊天背景"];
    //初始化表格
//    self.tableView.sectionIndexColor = COLOR_CG1;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableView.backgroundColor = HEX_COLOR(@"#f2f2f2");
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.currentChatId == CHAT_GLOBAL_ID) {
        return 6;
    }
    return 4;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1)
    {
        NSLog(@"选择背景图");
    }
    if (indexPath.row == 2)
    {
        [self click_photo];
    }
    if (indexPath.row == 3)
    {
        [self click_camera];
    }
    if (indexPath.row == 5)
    {
        [[ChatExCacheManager shareInstance] applyGlobalBgToAllChatView];
        [UserInfo showTips:self.view des:@"所有场景背景设置成功".lv_localized];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *cellId = @"cellId";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
//    }
//    cell.textLabel.textColor = [UIColor colorTextFor23272A];
//    cell.textLabel.font = fontRegular(15);
//    return cell;
//}
// 从手机相册选择
- (void)click_photo
{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    imagePickerVc.allowCrop = NO;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingGif = NO;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if(photos.count>0)
        {
            UIImage *toSendImage = [Common fixOrientation:[photos firstObject]];
            NSString *path = [MNChatViewController localPhotoPath:toSendImage];
            if(path != nil)
            {
                // 设置聊天窗口背景
                [[ChatExCacheManager shareInstance] setChatBgWithChatId:self.currentChatId chatBg:path];
                // 退出当前视图
                for (UIViewController *controller in self.navigationController.viewControllers)
                {
                    if ([controller isKindOfClass:[MNChatViewController class]])
                    {
                        MNChatViewController *vc =(MNChatViewController *)controller;
                        [self.navigationController popToViewController:vc animated:YES];
                    }
                }
            }
        }
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

// 拍照
- (void)click_camera
{
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self showNeedCameraAlert];
        return;
    }
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized || authStatus == AVAuthorizationStatusNotDetermined)
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = NO;
        [self presentViewController:picker animated:YES completion:nil];
    }
    else
    {
        [self showNeedCameraAlert];
    }
}

- (void)showNeedCameraAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法使用相机".lv_localized message:@"请在iPhone的\"设置-隐私-相机\"中允许访问相机".lv_localized preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelButton = [UIAlertAction actionWithTitle:@"确定".lv_localized style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancelButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info
{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *toSendImage = [Common fixOrientation:image];
        NSString *path = [MNChatViewController localPhotoPath:toSendImage];
        if(path != nil)
        {
            // 设置聊天窗口背景
            [[ChatExCacheManager shareInstance] setChatBgWithChatId:self.currentChatId chatBg:path];
            // 退出当前视图
            for (UIViewController *controller in self.navigationController.viewControllers)
            {
                if ([controller isKindOfClass:[MNChatViewController class]])
                {
                    MNChatViewController *vc =(MNChatViewController *)controller;
                    [self.navigationController dismissViewControllerAnimated:YES completion:^{
                        [self.navigationController popToViewController:vc animated:YES];
                    }];
                }
            }
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

//next segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([@"SelectBgPicIdentifier" isEqualToString:segue.identifier])
    {
        AssetsChatBgViewController *v = segue.destinationViewController;
        v.currentChatId = self.currentChatId;
    }
}


@end
