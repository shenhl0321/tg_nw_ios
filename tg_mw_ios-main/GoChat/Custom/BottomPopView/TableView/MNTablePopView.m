//
//  MNTablePopView.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/5.
//

#import "MNTablePopView.h"
#import "MNPopBaseCell.h"
#import "YCShadowView.h"

@interface MNTablePopView ()
<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, assign) CGFloat topMargin;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (strong, nonatomic) YCShadowView *backview;
@property (nonatomic, strong) UITableView *tableView;
@property (strong, nonatomic) UIImageView *topImageV;
@property (nonatomic, assign) CGFloat heightForSectionHeader;
@property (nonatomic, copy) PopViewChooseBlock chooseIndexBlock;
@end
@implementation MNTablePopView


+ (MNTablePopView *)showTablePopViewWithType:(MNTablePopViewType)type
                          dataArray:(NSArray *)dataArray
                chooseIndexBlock:(PopViewChooseBlock)chooseIndexBlock{
   MNTablePopView *popView = [[MNTablePopView alloc]init];
    [popView showTablePopViewWithType:type dataArray:dataArray chooseIndexBlock:chooseIndexBlock];
    [popView show];
    return popView;
}

- (void)showTablePopViewWithType:(MNTablePopViewType)type dataArray:(NSArray *)dataArray chooseIndexBlock:(PopViewChooseBlock)chooseIndexBlock{
   _type = type;
   _chooseIndexBlock = chooseIndexBlock;
   if (type == MNTablePopViewTypeMsgAdd) {
       self.bottomView.frame = CGRectMake(APP_SCREEN_WIDTH-160-10, 70-20+APP_STATUS_BAR_HEIGHT+5 + 10, 180, 205 + 30 - 2*self.heightForSectionHeader);
   }
   _dataArray = [[NSMutableArray alloc] initWithArray:dataArray];
    [self initUI];
}

+ (MNTablePopView *)showTablePopViewWithType:(MNTablePopViewType)type chooseIndexBlock:(PopViewChooseBlock)chooseIndexBlock{
    MNTablePopView *popView = [[MNTablePopView alloc]init];
    [popView showTablePopViewWithType:type chooseIndexBlock:chooseIndexBlock];
    [popView show];
    return popView;
}

- (void)showTablePopViewWithType:(MNTablePopViewType)type chooseIndexBlock:(PopViewChooseBlock)chooseIndexBlock{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    MNTablePopModel *model0 = [[MNTablePopModel alloc] initWithId:@"AddContact" title:@"添加联系人".lv_localized iconName:@"PopAddContact"];
    [dataArray addObject:model0];
    MNTablePopModel *model1 = [[MNTablePopModel alloc] initWithId:@"NewGroup" title:@"新建群组".lv_localized iconName:@"PopNewGroup"];
    [dataArray addObject:model1];
    MNTablePopModel *model2 = [[MNTablePopModel alloc] initWithId:@"NewPrivateChat" title:@"开启私密聊天".lv_localized iconName:@"PopNewPrivateChat"];
    [dataArray addObject:model2];
    MNTablePopModel *model3 = [[MNTablePopModel alloc] initWithId:@"Scan" title:@"扫一扫".lv_localized iconName:@"PopScan"];
    [dataArray addObject:model3];
    [self showTablePopViewWithType:type dataArray:dataArray chooseIndexBlock:chooseIndexBlock];

   
}
- (void)initUI{
    self.backgroundView.backgroundColor = [UIColor clearColor];
    [self.bottomView addSubview:self.backview];
    self.bottomView.backgroundColor = [UIColor clearColor];
    [self.backview mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.equalTo(self.bottomView).offset(10);
        make.right.equalTo(self.bottomView).offset(-20);
        make.bottom.equalTo(self.bottomView).offset(-10);
        make.top.equalTo(self.bottomView.mas_top).offset(20);
    }];
    
    [self.backview addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.bottomView addSubview:self.topImageV];
    [self.topImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.bottom.equalTo(self.backview.mas_top).offset(6);
        make.right.equalTo(self.backview).offset(-15);
        make.width.mas_offset(20);
        make.height.mas_offset(20);
    }];
}

-(CGFloat)heightForSectionHeader{
    if (self.type == MNTablePopViewTypeMsgAdd) {
        return 12.5;;
    }
    return 0;
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, APP_SCREEN_WIDTH, 100)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.type == MNTablePopViewTypeMsgAdd) {
        return 45;;
    }
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (self.cellType == BottomTopBarTableViewCellTypeOnlyTitle) {
//
//    }
    static NSString *cellId = @"MNPopBaseCell";
    MNPopBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[MNPopBaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        if (self.type == MNTablePopViewTypeMsgAdd) {
            [cell styleMessageAdd];
        }
    }
    MNTablePopModel *model = self.dataArray[indexPath.row];
    if (self.type == MNTablePopViewTypeMsgAdd) {
        if (model.iconName) {
            [cell.iconImgV setImage:[UIImage imageNamed:model.iconName]];
        }
        cell.titleLabel.text = [Util objToStr:model.title];
    }
    cell.lineV.hidden = self.dataArray.count==(indexPath.row+1);
    return cell;
//    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MNTablePopModel *model = self.dataArray[indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(popView:selectIndex:)]) {
        [self.delegate popView:self selectIndex:indexPath.row];
    }
    if (self.chooseIndexBlock) {
        self.chooseIndexBlock(self,indexPath.row,model);
    }
}

- (YCShadowView *)backview{
    if (!_backview){
        _backview = [[YCShadowView alloc] init];
        _backview.backgroundColor = [UIColor whiteColor];
        [_backview yc_cornerRadius:10];
        [_backview yc_shaodw];
    }
    return _backview;
}
- (UIImageView *)topImageV{
    if (!_topImageV){
        _topImageV = [[UIImageView alloc] init];
        _topImageV.image = [UIImage imageNamed:@"icon_top"];
    }
    return _topImageV;
}

@end
