////
////  GC_PublishDynamicVC.m
////  GoChat
////
////  Created by wangfeiPro on 2021/12/16.
////
//
//#import "GC_PublishDynamicVC.h"
//#import "XWDragCellCollectionView.h"
//#import "QTRejectViewCell.h"
//
//@interface GC_PublishDynamicVC ()<UITextViewDelegate,XWDragCellCollectionViewDataSource, XWDragCellCollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate>
//@property(retain,nonatomic)UIView *topView;
//@property(retain,nonatomic)UIButton *publishBtn;
//@property(retain,nonatomic)UITextView *contentTextView;
//@property(retain,nonatomic)UILabel *promptLb;
//@property(retain,nonatomic)NSMutableArray *phonelist;//图片数组
//@property(retain,nonatomic)XWDragCellCollectionView *collectionView;
//@property (strong,nonatomic)UIButton *addPhoneBtn; //添加照片按钮
//@property(retain,nonatomic)NSMutableString *uploadImageUrl;
//
//
//
//@end
//
//@implementation GC_PublishDynamicVC
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//    [self.customNavBar setTitle:@"朋友圈"];
//    self.phonelist = [[NSMutableArray alloc]init];
//    self.uploadImageUrl = [NSMutableString string];
//
//    [self initUIViewController];
//    [self pageLayoutManagement];
//}
//-(void)initUIViewController{
//
//    self.publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.publishBtn addTarget:self action:@selector(publishBtnButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self.publishBtn setTitle:@"发布" forState:(UIControlStateNormal)];
//    [self.publishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    self.publishBtn.titleLabel.font = [UIFont regularCustomFontOfSize:15];
//    self.publishBtn.backgroundColor = [UIColor colorMain];
//    self.publishBtn.layer.cornerRadius = 4;
//    self.publishBtn.clipsToBounds = YES;
//    [self.customNavBar addSubview:self.publishBtn];
//
//    [self.publishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-15);
//        make.width.mas_equalTo(55);
//        make.height.mas_equalTo(29);
//        make.bottom.mas_equalTo(-10);
//    }];
//
//    self.contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(25, kNavBarAndStatusBarHeight + 15, SCREEN_WIDTH, 105)];
//    self.contentTextView.backgroundColor = [UIColor whiteColor];
//    self.contentTextView.delegate = self;
//    self.promptLb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
//    self.promptLb.enabled = NO;
//    self.promptLb.text = @"说点什么...";
//    self.promptLb.font =  [UIFont regularCustomFontOfSize:17];
//    self.promptLb.textColor = [UIColor colorTextForA9B0BF];
//    [self.contentTextView addSubview:self.promptLb];
//    [self.topView addSubview:self.contentTextView];
//
//    //    ---------------照片选择器-------------------
//    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
//    self.collectionView = [[XWDragCellCollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.contentTextView.frame) + 10,SCREEN_WIDTH - 50,(SCREEN_WIDTH-40)/3 * 2) collectionViewLayout:flowLayout];
//    self.collectionView.dataSource = self;
//    self.collectionView.delegate = self;
//    self.collectionView.backgroundColor = [UIColor whiteColor];
//    [self.collectionView registerClass:[QTRejectViewCell class] forCellWithReuseIdentifier:@"rejectViewMeCell"];
//    [self.topView addSubview:self.collectionView];
//
//    //添加照片按钮
//    self.addPhoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.addPhoneBtn.frame = CGRectMake(10, 10, (SCREEN_WIDTH-50 - 20)/3, (SCREEN_WIDTH-50-20)/3);
//    [self.addPhoneBtn setBackgroundImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
//    [self.addPhoneBtn addTarget:self action:@selector(BtnAddPhoneClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.collectionView addSubview:self.addPhoneBtn];
//}
//// textview Delegate
//- (void) textViewDidChange:(UITextView *)textView{
//    if ([textView.text length] == 0) {
//        [self.promptLb setHidden:NO];
//    }else{
//        [self.promptLb setHidden:YES];
//    }
//}
//#pragma mark ---------------照片选择器-------------------
////添加图片事件
//- (void)BtnAddPhoneClick{
//    if (self.phonelist.count >= 9) {
////        [self showAlertWithStr:@"最多选择9张照片"];
//    }else {
//        [self showSheetView];
//    }
//}
//
//-(void)showSheetView{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    UIAlertAction *setAlert = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self callCameraOrPhotoWithType:UIImagePickerControllerSourceTypeCamera];
//
//    }];
//    UIAlertAction *PhoneAlert = [UIAlertAction actionWithTitle:@"从手机选择" style:
//                                 UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                                     TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:nil];
//        imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
//                                     // 你可以通过block或者代理，来得到用户选择的照片.
//                                     [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets,BOOL isSelectOriginalPhoto) {
//                                         if (self.phonelist.count + photos.count <= 9) {
//                                             [self.phonelist addObjectsFromArray:photos];
//                                             [self resetLayout];
//
//                                             [self mulupload:self.phonelist];
//
//                                         }else{
//                                             dispatch_async(dispatch_get_main_queue(), ^{
////                                                 [self showAlertWithStr:@"最多选择9张照片"];
//                                             });
//                                         }
//                                     }];
//
//                                     imagePickerVc.allowPickingImage = YES;
//                                     imagePickerVc.allowPickingOriginalPhoto = NO;
//
//                                     // 4. 照片排列按修改时间升序
//                                     imagePickerVc.sortAscendingByModificationDate = NO;
//                                     // 在这里设置imagePickerVc的外观
//                                     imagePickerVc.navigationBar.barTintColor = [UIColor colorTextFor000000];
//                                     imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
//                                     imagePickerVc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//                                     [self presentViewController:imagePickerVc animated:YES completion:nil];
//
//                                 }];
//    UIAlertAction *hidAlert = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//    }];
//    [alert addAction:setAlert];
//    [alert addAction:PhoneAlert];
//    [alert addAction:hidAlert];
//
//    [self presentViewController:alert animated:YES completion:^{
//
//    }];
//
//}
//
//-(void)resetLayout{
//    int columnCount = ceilf((_phonelist.count + 1) * 1.0 / 4);
//    float height = columnCount * ((SCREEN_WIDTH-40)/4 +10)+10;
//    if (height < (SCREEN_WIDTH-40)/4+20) {
//        height = (SCREEN_WIDTH-40)/4+20;
//    }
//    CGRect rect = _collectionView.frame;
//    rect.size.height = height;
//    _collectionView.frame = rect;
//    [_collectionView reloadData];
//
//    self.addPhoneBtn.frame = CGRectMake(10+(10+(SCREEN_WIDTH-40)/4)*(self.phonelist.count%4), _collectionView.xhq_height-(SCREEN_WIDTH-40)/4-10,(SCREEN_WIDTH-40)/4,(SCREEN_WIDTH-40)/4);
//}
//
//-(void)callCameraOrPhotoWithType:(UIImagePickerControllerSourceType)sourceType{
//    BOOL isCamera = NO;
//    if (sourceType == UIImagePickerControllerSourceTypeCamera) {//判断是否有相机
//        isCamera = [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera];
//    }
//    if (isCamera) {
//
//        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//        imagePicker.delegate = self;
//        imagePicker.allowsEditing = NO;//为NO，则不会出现系统的编辑界面
//        imagePicker.sourceType = sourceType;
//        [self presentViewController:imagePicker animated:YES completion:^(){
//            if ([[[UIDevice currentDevice] systemVersion]floatValue]>=7.0) {
//                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//            }
//        }];
//
//    } else {
//
//    }
//}
//
//#pragma mark - UIImagePickerControllerDelegate
////相册或则相机选择上传的实现
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)aImage editingInfo:(NSDictionary *)editingInfo{
//
//    NSArray *photos = [[NSArray alloc]initWithObjects:aImage, nil];
//    [self.phonelist addObjectsFromArray:photos];
//    [picker dismissViewControllerAnimated:YES completion:^{
//        [self resetLayout];
//    }];
//}
//
//
//// 用户选择取消
//- (void) imagePickerControllerDidCancel: (UIImagePickerController *)picker
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//
//}
//
//
//#pragma mark - UICollectionViewDataSource
//- (NSArray *)dataSourceArrayOfCollectionView:(XWDragCellCollectionView *)collectionView{
//    return self.phonelist;
//}
//
//- (void)dragCellCollectionView:(XWDragCellCollectionView *)collectionView newDataArrayAfterMove:(NSMutableArray *)newDataArray{
//    [self.phonelist removeAllObjects];
//    [self.phonelist addObjectsFromArray:newDataArray];
//}
//
//
//-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
//    return 1;
//}
//
//-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//
//    return self.phonelist.count;
//}
//
//-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    QTRejectViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"rejectViewMeCell" forIndexPath:indexPath];
//    cell.imageView.image = [self.phonelist objectAtIndex:indexPath.row];
//    cell.delBtn.tag = 100+indexPath.row;
//    [cell.delBtn addTarget:self action:@selector(BtnDelPhone:) forControlEvents:UIControlEventTouchUpInside];
//    return cell;
//}
//
//#pragma mark --UICollectionViewDelegateFlowLayout
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake((SCREEN_WIDTH-50 - 20)/3, (SCREEN_WIDTH-50-20)/3);
//}
//
//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(10, 10, 10, 10);
//}
//-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
//    return 0;
//}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
//    return 10;
//}
//
////删除照片的事件
//- (void)BtnDelPhone:(UIButton *)sender{
//    [self.phonelist removeObjectAtIndex:sender.tag-100];
//    [self resetLayout];
//}
//
////删除照片
//- (void)DelClick{
//    [self.phonelist removeAllObjects];
//    [self resetLayout];
//}
//
////压缩图片
//- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
//{
//    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
//    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
//    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    return reSizeImage;
//
//}
//-(void)mulupload:(NSArray *)photoArr{
//       NSMutableDictionary *sendDic = [[NSMutableDictionary alloc]init];
//
//
//}
//
//-(void)publishBtnButtonClicked:(UIButton *)sender{
//
//}
//
//-(void)pageLayoutManagement{
//
//}
///*
//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}
//*/
//
//@end
