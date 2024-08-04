//
//  MNChatBgTableViewController.m
//  GoChat
//
//  Created by 许蒙静 on 2022/1/2.
//

#import "MNChatBgTableViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MNChatViewController.h"
#import "ChatExCacheManager.h"
#import "TZImagePickerController.h"
#import "AssetsChatBgViewController.h"
#import "MNChatBgCell1.h"
#import "MNChatBgCell2.h"

@interface MNChatBgTableViewController ()
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) NSMutableArray *rows;
@end

@implementation MNChatBgTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.customNavBar setTitle:@"聊天背景".lv_localized];
    self.tableView.backgroundColor = HexRGB(0xf2f2f2);
    _rows = [[NSMutableArray alloc] init];
    NSArray *row0 = @[@"选择背景图".lv_localized,@"从手机相册选择".lv_localized,@"拍一张".lv_localized];
    [_rows addObject:row0];
    if (self.currentChatId == CHAT_GLOBAL_ID) {
        NSArray *row1 = @[@"将背景应用到所有场景".lv_localized];
        [_rows addObject:row1];
    }

}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.rows.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = self.rows[section];
    return arr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *aView = [[UIView alloc] init];
//   
//    return aView;
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *row = self.rows[indexPath.section];
    NSString *rowName = row[indexPath.row];
    if (indexPath.section == 0) {
        static NSString *cellId = @"MNChatBgCell1";
        MNChatBgCell1 *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[MNChatBgCell1 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        cell.titleLabel.text = rowName;
        return cell;
    }else{
        static NSString *cellId = @"MNChatBgCell2";
        MNChatBgCell2 *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[MNChatBgCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        cell.titleLabel.text = rowName;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *row = self.rows[indexPath.section];
    NSString *rowName = row[indexPath.row];
    
    
//    NSArray *row0 = @[@"选择背景图",@"从手机相册选择",@"拍一张"];
//    [_rows addObject:row0];
//    if (self.currentChatId == CHAT_GLOBAL_ID) {
//        NSArray *row1 = @[@"将背景应用到所有场景"];
//        [_rows addObject:row1];
//    }
    
    if ([rowName isEqualToString:@"选择背景图".lv_localized]) {
        
        AssetsChatBgViewController *v = [[UIStoryboard storyboardWithName:@"Chat" bundle:nil] instantiateViewControllerWithIdentifier:@"AssetsChatBgViewController"];
        v.currentChatId = self.currentChatId;
        [self.navigationController pushViewController:v animated:YES];
    }else if ([rowName isEqualToString:@"从手机相册选择".lv_localized]) {
        [self click_photo];
    }else if ([rowName isEqualToString:@"拍一张".lv_localized]) {
        [self click_camera];
    }else if ([rowName isEqualToString:@"将背景应用到所有场景".lv_localized]) {
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
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if([@"SelectBgPicIdentifier" isEqualToString:segue.identifier])
//    {
//        AssetsChatBgViewController *v = segue.destinationViewController;
//        v.currentChatId = self.currentChatId;
//    }
//}


@end
