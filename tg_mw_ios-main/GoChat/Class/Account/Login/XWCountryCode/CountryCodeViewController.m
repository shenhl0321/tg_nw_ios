//
//  CountryCodeViewController.m
//  GoChat
//
//  Created by 李标 on 2021/6/10.
//

#import "CountryCodeViewController.h"
#import "SerchTf.h"
#import "MNCountryCodeCell.h"

#import "SelectCNAreasVC.h"

@interface CountryCodeViewController ()
<SearchTfDelegate>

@property (nonatomic, strong) UITextField *searchTf;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) SerchTf *searchBar;

//@property (nonatomic, strong) UITextField *searchTf;
@property (nonatomic, strong) NSArray *indexArray;
@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) NSString *searchKeywords; // 搜索的关键词
@end

@implementation CountryCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.title = @"请选择国家";
    [self.customNavBar setTitle:LocalString(localPlsChooseCountry)];
    [self initData];
    [self initUI];
}

//刷新一下UI
- (void)refreshUI{
    if (self.searchBar.isSearching) {
        self.contentView.frame = CGRectMake(0, APP_STATUS_BAR_HEIGHT, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-APP_STATUS_BAR_HEIGHT-kBottom34());
    }else{
        self.contentView.frame = CGRectMake(0, APP_TOP_BAR_HEIGHT, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-APP_TOP_BAR_HEIGHT-kBottom34());
    }
}

- (void)initUI{
    [self.contentView addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(42);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(47);
        make.left.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self refreshUI];
}

- (SerchTf *)searchBar{
    if (!_searchBar) {
        _searchBar = [[SerchTf alloc] init];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (void)initData
{
//    self.searchTf.delegate = self;
//    [self.searchTf addTarget:self action:@selector(textContentChanged:) forControlEvents:UIControlEventEditingChanged];
    // 排序
    self.tableView.sectionIndexColor = [UIColor blueColor];
    self.indexArray = [[NSArray alloc] initWithArray:[[self.sortedNameDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }]];
    
    self.tableView.sectionIndexColor = [UIColor colorTextForA9B0BF];
    // 初始化
    self.results = [NSMutableArray arrayWithCapacity:1];
}

// 搜索
- (void)doSearch:(NSString *)keyword
{
    self.searchKeywords = keyword;
    
    if (_results.count > 0)
    {
        [_results removeAllObjects];
    }
    NSString *inputText = keyword;
    __weak __typeof(self)weakSelf = self;
    [_sortedNameDict.allValues enumerateObjectsUsingBlock:^(NSArray * obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        [obj enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop)
        {
            if ([obj containsString:inputText])
            {
                [weakSelf.results addObject:obj];
            }
        }];
    }];
    [self.tableView reloadData];
}

- (NSString *)showCodeStringIndex:(NSIndexPath *)indexPath
{
    NSString *showCodeSting;
    if (!IsStrEmpty(self.searchKeywords))
    {
        if (_results.count > indexPath.row)
        {
            showCodeSting = [_results objectAtIndex:indexPath.row];
        }
    }
    else
    {
        if (_indexArray.count > indexPath.section)
        {
            NSArray *sectionArray = [_sortedNameDict valueForKey:[_indexArray objectAtIndex:indexPath.section]];
            if (sectionArray.count > indexPath.row)
            {
                showCodeSting = [sectionArray objectAtIndex:indexPath.row];
            }
        }
    }
    return showCodeSting;
}

- (void)selectCodeIndex:(NSIndexPath *)indexPath
{
    NSString *originText = [self showCodeStringIndex:indexPath];
    NSArray  *array = [originText componentsSeparatedByString:@"+"];
    NSString *countryName = [array.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *code = array.lastObject;
    
    /// 用户修改地区信息，选择中国
    if ([code isEqualToString:@"86"] && self.isModifyAreas) {
        SelectCNAreasVC *area = [[SelectCNAreasVC alloc] init];
        area.countryCode = code;
        area.country = countryName;
        area.block = self.areaBlock;
        [self.navigationController pushViewController:area animated:YES];
        return;
    }
    
    if (self.deleagete && [self.deleagete respondsToSelector:@selector(returnCountryName:code:)])
    {
        [self.deleagete returnCountryName:countryName code:code];
    }
    
    if (self.returnCountryCodeBlock != nil)
    {
        self.returnCountryCodeBlock(countryName,code);
    }
    
    if (self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITextFieldDelegate
- (void)searchTf:(SerchTf *)tfView didEndSearchWithText:(NSString *)text{
    
}//结束搜索
- (void)searchTf_didCancelSearch:(SerchTf *)tfView{
    
}//取消搜索
- (void)searchTf_valueChanged:(SerchTf *)tfView{
    [self doSearch:tfView.searchTf.text];
}
- (void)searchTf_textFieldDidBeginEditing:(SerchTf *)tfView{
    
}

-(void)searchTf_searchStateChanged:(BOOL)isSearching{
    [self refreshUI];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (IsStrEmpty(self.searchKeywords))
    {
        if ([self.sortedNameDict allKeys].count > 0)
        {
            return [self.sortedNameDict allKeys].count;
        }
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!IsStrEmpty(self.searchKeywords))
    {
        return [_results count];
    }
    else
    {
        if (_indexArray.count > section)
        {
            NSArray *array = [_sortedNameDict objectForKey:[_indexArray objectAtIndex:section]];
            return array.count;
        }
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"MNCountryCodeCell";
    
    MNCountryCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[MNCountryCodeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    [cell fillDataWithText: [self showCodeStringIndex:indexPath]];
    return cell;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.tableView)
    {
        return _indexArray;
    }
    else
    {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.tableView)
    {
        return index;
    }
    else
    {
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView)
    {
        if (section == 0 && !IsStrEmpty(self.searchKeywords))
        {
            return 0;
        }
        return 30;
    }
    else
    {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_indexArray.count && _indexArray.count > section)
    {
        return [_indexArray objectAtIndex:section];
    }
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (_indexArray.count && _indexArray.count > section)
    {
        NSString *title = [_indexArray objectAtIndex:section];
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *aLabel = [[UILabel alloc] init];
        aLabel.font = fontRegular(15);
        aLabel.textColor = [UIColor colorTextFor878D9A];
        aLabel.text = title;
        [view addSubview:aLabel];
        [aLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(left_margin());
            make.centerY.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
        return view;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectCodeIndex:indexPath];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(MNCountryCodeCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger count = [tableView numberOfRowsInSection:indexPath.section];
    if (count-1 == indexPath.row) {
        cell.needLine = YES;
    }else{
        cell.needLine = NO;
    }
}

-(UITableViewStyle)style{
    return UITableViewStylePlain;
}

@end
