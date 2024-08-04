//
//  ReadyEditViewController.m
//  GoChat
//
//  Created by 吴亮 on 2021/10/19.
//

#import "ReadyEditViewController.h"
#import "IJSImageManagerController.h"
#import <IJSFoundation/IJSFoundation.h>
#import "IJSMapViewModel.h"
@interface ReadyEditViewController ()
@property (nonatomic, strong) UIImageView * imageV;
@property (nonatomic, strong) UIButton * editBtn;
@property (nonatomic, strong) UIButton * finishBtn;

@property(nonatomic,strong) NSMutableArray *mapDataArr;  // 贴图

@end

@implementation ReadyEditViewController
-(NSMutableArray *)mapDataArr
{
    if (_mapDataArr == nil)
    {
        _mapDataArr =[NSMutableArray array];
    }
    return _mapDataArr;
}
- (void) loadEmojiData{
    // 设置贴图数据
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"JSPhotoSDK" ofType:@"bundle"];
    NSString *filePath = [bundlePath stringByAppendingString:@"/Expression"];
    [IJSFFilesManager ergodicFilesFromFolderPath:filePath completeHandler:^(NSInteger fileCount, NSInteger fileSzie, NSMutableArray *filePath) {
        IJSMapViewModel *model = [[IJSMapViewModel alloc] initWithImageDataModel:filePath];
        [self.mapDataArr addObject:model];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"main_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backItemClick)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    
    self.navigationController.navigationBar.translucent = YES;
    UIColor * color = [UIColor clearColor];
    CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, kNavBarHeight);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.clipsToBounds = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadEmojiData];
    [self buildUI];
}
-(void)buildUI{
    self.imageV = [[UIImageView alloc] initWithImage:self.oriImage];
    [self.view addSubview:self.imageV];
    
    
    [self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    
    UIView * bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:bottomView];
    
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.equalTo(@(40+kBottomSafeHeight));
    }];
    
    
    self.editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.editBtn setTitle:@"编辑".lv_localized forState:UIControlStateNormal];
    [self.editBtn addTarget:self action:@selector(editBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:self.editBtn];
    [self.editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(bottomView);
        make.width.equalTo(@80);
        make.height.equalTo(@40);
    }];
    
    self.finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.finishBtn setTitle:@"完成".lv_localized forState:UIControlStateNormal];
    [self.finishBtn addTarget:self action:@selector(finishBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:self.finishBtn];
    [self.finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.equalTo(bottomView);
        make.width.equalTo(@80);
        make.height.equalTo(@40);
    }];
    
}

-(void)editBtnClick{
    __weak typeof (self) weakSelf = self;
    IJSImageManagerController *vc =[[IJSImageManagerController alloc]initWithEditImage:self.oriImage];
    [vc loadImageOnCompleteResult:^(UIImage *image, NSURL *outputPath, NSError *error) {
        weakSelf.imageV.image = image;
    }];
    vc.mapImageArr = self.mapDataArr;
    [self.navigationController showViewController:vc sender:nil];
}

-(void)finishBtnClick{
    if (self.doneButtonClickBlock) {
        self.doneButtonClickBlock(self.imageV.image);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)backItemClick{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
