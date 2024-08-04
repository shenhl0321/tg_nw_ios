//
//  CycleMainViewController.m
//  GoChat
//
//  Created by 吴亮 on 2021/10/7.
//

#import "CycleMainViewController.h"
#import "CycleMainViewCell.h"
@interface CycleMainViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UIImageView * headImageV;
@property (nonatomic, strong) UILabel * nameL;
@property (nonatomic, strong) UIButton * editBtn;
@property (nonatomic, strong) UILabel * desL;
@property (nonatomic, strong) UILabel * activeL;
@property (nonatomic, strong) UILabel * fansL;
@property (nonatomic, strong) UILabel * loveL;
@property (nonatomic, strong) UIView * headView;
@property (nonatomic, strong) UICollectionView * collectionV;

@property (nonatomic, strong) NSArray * dataArr;

@end

@implementation CycleMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataArr = @[@"",@"",@"",@"",@"",@"",@"",@"",@"",@""];
    self.view.backgroundColor = HEX_COLOR(@"#E1E1E1");
    
    [self buildHeaderView];
    [self buildCollectionView];
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"main_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backItemClick)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem * msgItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"main_msgList"] style:UIBarButtonItemStylePlain target:self action:@selector(msgItemClick)];
    self.navigationItem.rightBarButtonItem = msgItem;
    
//    self.navigationController.navigationBar.alpha = 0;
//    self.navigationController.navigationBar.translucent = YES;
//    UIColor * color = [UIColor clearColor];
//    CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, kNavBarHeight);
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [color CGColor]);
//    CGContextFillRect(context, rect);
//    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
//    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
}
-(void)buildHeaderView{
    self.headView = [[UIView alloc] initWithFrame:CGRectMake(0, -kNavBarHeight, SCREEN_WIDTH, 350)];
    self.headView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.headView];
    
    UIImageView * headBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
    headBgView.backgroundColor = [UIColor orangeColor];
    [self.headView addSubview:headBgView];
    
    self.headImageV = [[UIImageView alloc] init];
    self.headImageV.layer.masksToBounds = YES;
    self.headImageV.layer.cornerRadius = 45;
    [self.headView addSubview:self.headImageV];
    

    
    self.nameL = [[UILabel alloc] init];
    self.nameL.text = @"昵称".lv_localized;
    self.nameL.font = [UIFont boldSystemFontOfSize:20];
    self.nameL.textColor = HEX_COLOR(@"#09060E");
    [self.headView addSubview:self.nameL];
    
    self.desL = [[UILabel alloc] init];
    self.desL.text = @"尘世的繁华掩盖不住心里那一抹伤，满目的浮云带不走隐痛的过往。".lv_localized;
    self.desL.textColor = HEX_COLOR(@"#8E8E8E");
    self.desL.font = [UIFont systemFontOfSize:13];
    self.desL.numberOfLines = 2;
    self.desL.backgroundColor = [UIColor orangeColor];
    [self.headView addSubview:self.desL];
    
    self.editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.editBtn setTitle:@"编辑主页".lv_localized forState:UIControlStateNormal];
    [self.editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.editBtn.backgroundColor = [UIColor color];
    self.editBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    self.editBtn.layer.masksToBounds = YES;
    self.editBtn.layer.cornerRadius = 5;
    [self.headView addSubview:self.editBtn];
    
    
    UIView * lineV = [[UIView alloc] init];
    lineV.backgroundColor = HEX_COLOR(@"#E1E1E1");
    [self.headView addSubview:lineV];
    
    self.activeL = [[UILabel alloc] init];
    self.activeL.textAlignment = NSTextAlignmentCenter;
    self.activeL.font = [UIFont systemFontOfSize:15];
    self.activeL.textColor = HEX_COLOR(@"#666A76");
    self.activeL.text = @"28动态".lv_localized;
    [self.headView addSubview:self.activeL];
    
    UIView * lineOneView = [[UIView alloc] init];
    lineOneView.backgroundColor = HEX_COLOR(@"#E1E1E1");
    [self.headView addSubview:lineOneView];
    
    self.fansL = [[UILabel alloc] init];
    self.fansL.textAlignment = NSTextAlignmentCenter;
    self.fansL.font = [UIFont systemFontOfSize:15];
    self.fansL.textColor = HEX_COLOR(@"#666A76");
    self.fansL.text = @"28粉丝".lv_localized;
    [self.headView addSubview:self.fansL];
    
    UIView * lineTwoView = [[UIView alloc] init];
    lineTwoView.backgroundColor = HEX_COLOR(@"#E1E1E1");
    [self.headView addSubview:lineTwoView];
    
    self.loveL = [[UILabel alloc] init];
    self.loveL.textAlignment = NSTextAlignmentCenter;
    self.loveL.font = [UIFont systemFontOfSize:15];
    self.loveL.textColor = HEX_COLOR(@"#666A76");
    self.loveL.text = @"2.2万获赞".lv_localized;
    [self.headView addSubview:self.loveL];
    
    
    
    [self.headImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headView).offset(18);
        make.top.equalTo(headBgView.mas_bottom).offset(-45);
        make.height.width.equalTo(@90);
    }];
    
    [self.nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImageV.mas_right).offset(15);
        make.top.equalTo(headBgView.mas_bottom).offset(15);
        make.right.equalTo(self.headView).offset(-15);
        make.height.equalTo(@20);
    }];
    
    [self.desL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameL.mas_left);
        make.top.equalTo(self.headImageV.mas_bottom).offset(5);
        make.height.equalTo(@40);
        make.right.equalTo(self.headView).offset(-15);
    }];
    
    [self.editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImageV.mas_left);
        make.right.equalTo(self.headImageV.mas_right);
        make.top.equalTo(self.headImageV.mas_bottom).offset(10);
        make.height.equalTo(@30);
    }];
    
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.headView);
        make.height.equalTo(@1);
        make.top.equalTo(self.editBtn.mas_bottom).offset(15);
    }];
    
    [self.activeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headView);
        make.top.equalTo(lineV.mas_bottom);
        make.width.equalTo(@(SCREEN_WIDTH/3));
        make.height.equalTo(@50);
    }];
    
    [lineOneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.activeL.mas_right);
        make.centerY.equalTo(self.activeL);
        make.height.equalTo(@15);
        make.width.equalTo(@1);
    }];
    
    [self.fansL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.activeL.mas_right);
        make.top.equalTo(lineV.mas_bottom);
        make.width.equalTo(@(SCREEN_WIDTH/3));
        make.height.equalTo(@50);
    }];
    
    [lineTwoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.fansL.mas_right);
        make.centerY.equalTo(self.fansL);
        make.height.equalTo(@15);
        make.width.equalTo(@1);
    }];
    
    [self.loveL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.fansL.mas_right);
        make.top.equalTo(lineV.mas_bottom);
        make.width.equalTo(@(SCREEN_WIDTH/3));
        make.height.equalTo(@50);
    }];
    
//    self.headImageV.backgroundColor = [UIColor greenColor];
    
//    self.headView.backgroundColor = [UIColor yellowColor];
}

-(void)buildCollectionView{
    CGFloat width = (SCREEN_WIDTH - 40) / 3;
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(width, width);
    layout.minimumInteritemSpacing = 0;
    
    self.collectionV = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionV.delegate = self;
    self.collectionV.dataSource = self;
    [self.collectionV registerClass:[CycleMainViewCell class] forCellWithReuseIdentifier:@"CycleMainViewCell"];
    self.collectionV.backgroundColor = HEX_COLOR(@"#E1E1E1");
    self.collectionV.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.collectionV];
    
    [self.collectionV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.top.equalTo(self.headView.mas_bottom).offset(10);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
    }];
}

-(void)backItemClick{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)msgItemClick{
    
}

#pragma mark CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArr.count;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CycleMainViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CycleMainViewCell" forIndexPath:indexPath];
    
    return cell;
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
