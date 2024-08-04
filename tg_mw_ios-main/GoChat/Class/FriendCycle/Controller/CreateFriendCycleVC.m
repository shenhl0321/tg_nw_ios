//
//  CreateFriendCycleVC.m
//  GoChat
//
//  Created by 吴亮 on 2021/10/2.
//

#import "CreateFriendCycleVC.h"
#import "CustomTextView.h"
#import "SelectImageCell.h"
#import "SelectRemindCell.h"

#define img_ItemW (SCREEN_WIDTH-50-19)/3
#define remind_ItemW (SCREEN_WIDTH-50-40)/5
@interface CreateFriendCycleVC ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UITextViewDelegate>
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) CustomTextView * textView;
@property (nonatomic, strong) UICollectionView * imageCView;
@property (nonatomic, strong) NSMutableArray * imageArr;
@property (nonatomic, strong) UICollectionView * remindCView;
@property (nonatomic, strong) NSMutableArray * remindArr;
@property (nonatomic, strong) UIView * headerView;
@property (nonatomic, strong) UIView * footerView;
@property (nonatomic, strong) UILabel * titleL;
@end

@implementation CreateFriendCycleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageArr = @[@""].mutableCopy;
    self.remindArr = @[@""].mutableCopy;
    
    self.title = @"朋友圈".lv_localized;
    self.nav

    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 60, 40);
    [rightBtn setTitle:@"发布".lv_localized forState:UIControlStateNormal];
    rightBtn.layer.masksToBounds = YES;
    rightBtn.layer.cornerRadius = 5;
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBtn.backgroundColor = HEX_COLOR(@"#00BF92");
    [rightBtn addTarget:self action:@selector(rightItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    
    
    [self buildHeaderView];
    [self buildFooterView];
    [self buildUI];

}

-(void)buildUI{
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
}

-(void)buildHeaderView{
//    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, img_ItemW+50+80+25)];
    self.headerView = [[UIView alloc] initWithFrame:CGRectZero];

    self.textView = [[CustomTextView alloc] init];
    self.textView.placeholder = @"说点什么...".lv_localized;
    self.textView.delegate = self;
    self.textView.usePadding = YES;
    self.textView.paddingtop = 10;
    self.textView.paddingLeft = 0;
    [self.headerView addSubview:self.textView];
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(img_ItemW, img_ItemW);
    self.imageCView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.imageCView.delegate = self;
    self.imageCView.dataSource = self;
    self.imageCView.backgroundColor = [UIColor whiteColor];
    [self.imageCView registerClass:[SelectImageCell class] forCellWithReuseIdentifier:@"SelectImageCell"];

    [self.headerView addSubview:self.imageCView];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.headerView).offset(25);
        make.right.equalTo(self.headerView).offset(-25);
        make.height.equalTo(@80);
    }];
    
    [self.imageCView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerView).offset(25);
        make.top.equalTo(self.textView.mas_bottom).offset(10);
        make.height.equalTo(@(img_ItemW));
        make.right.equalTo(self.headerView).offset(-25);
//        make.bottom.equalTo(self.headerView).offset(-25);
    }];
    
    
}

-(void)buildFooterView{
    
    self.footerView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.titleL = [[UILabel alloc] init];
    self.titleL.text = @"提醒谁看".lv_localized;
    self.titleL.font = [UIFont boldSystemFontOfSize:17];
    self.titleL.textColor = HEX_COLOR(@"#04020C");
    [self.footerView addSubview:self.titleL];
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(remind_ItemW, remind_ItemW);
    
    self.remindCView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.remindCView registerClass:[SelectRemindCell class] forCellWithReuseIdentifier:@"SelectRemindCell"];
    self.remindCView.delegate = self;
    self.remindCView.dataSource = self;
    self.remindCView.backgroundColor = [UIColor whiteColor];
    [self.footerView addSubview:self.remindCView];
    
    [self.titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.footerView).offset(25);
        make.height.equalTo(@20);
        make.right.equalTo(self.footerView).offset(-25);
    }];
    [self.remindCView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.footerView).offset(25);
        make.top.equalTo(self.titleL.mas_bottom).offset(10);
        make.height.equalTo(@(remind_ItemW));
        make.right.equalTo(self.footerView).offset(-25);
        
    }];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }else{
        return 2;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CELL"];
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"谁可以看".lv_localized;
            cell.detailTextLabel.text = @"公开".lv_localized;
        }else{
            cell.textLabel.text = @"所在位置".lv_localized;
            cell.detailTextLabel.text = @"点击选择".lv_localized;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return img_ItemW+50+80;
    }else{
        return 0.01;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return self.headerView;
    }else{
        return [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.01f)];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return remind_ItemW+50+20;
    }else{
        return 0.01;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return self.footerView;
    }else{
        return [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.01f)];
    }
}


#pragma mark CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == self.imageCView) {
        return self.imageArr.count;
    }else{
        return self.remindArr.count;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.imageCView) {
        SelectImageCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectImageCell" forIndexPath:indexPath];
        return cell;
    }else{
        SelectRemindCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectRemindCell" forIndexPath:indexPath];
        return cell;
    }
}


- (void)textViewDidChange:(UITextView *)textView
{
    if (textView == self.textView) {
        if (self.textView.hasText) { // textView.text.length
            self.textView.placeholder = @"";
        } else {
            self.textView.placeholder = @"说点什么...".lv_localized;
        }
    }
}
#pragma mark
-(void)rightItemClick{
    
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
