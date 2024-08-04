//
//  AssetsChatBgViewController.m
//  GoChat
//
//  Created by 李标 on 2021/5/15.
//

#import "AssetsChatBgViewController.h"
#import "ChatExCacheManager.h"
#import "TelegramManager.h"
#import "AssetsBgCollectionViewCell.h"
#import "MNChatViewController.h"

@interface AssetsChatBgViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSInteger selectedIndex;  // 选中的Item index
    NSString *currBgName;  // 当前会话背景图名称
}

@property (nonatomic, strong) NSArray *bgList;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) UIEdgeInsets collectionViewSpace;
@property (nonatomic) CGSize itemSize;
@property (nonatomic, strong) UIButton *okBtn;  // 完成按钮
@end

@implementation AssetsChatBgViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"选择背景图".lv_localized;
    
    // 添加完成按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.okBtn];
    
    // 获取背景列表
    self.bgList = [ChatExCacheManager localChatBgList];
    
    //init size
    self.collectionViewSpace = UIEdgeInsetsMake(10, 10, 10, 10);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    // 计算cell大小
    CGFloat itemWidth = (SCREEN_WIDTH -  10*8) /4;
    CGFloat itemHeight = itemWidth;
    self.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    // 默认完成按钮不可点击
//    [self setOKBtnStatus:NO];
    
    if ([[ChatExCacheManager shareInstance] chatBgIsFromAssets:self.currentChatId])
    {// 获取当前会话背景
        currBgName = [[ChatExCacheManager shareInstance] chatBg:self.currentChatId];
        selectedIndex = [[ChatExCacheManager localChatBgList] indexOfObject:currBgName];
    }
    else
    {// 添加默认
        currBgName = @"";
        selectedIndex = 0;
    }
}

//// 更新完成按钮状态
//- (void)setOKBtnStatus:(BOOL)status
//{
//    if (status)
//    {// 可点击
//        [self.okBtn setUserInteractionEnabled:YES];
//        self.okBtn.alpha = 1.0f;
//        return;
//    }
//    [self.okBtn setUserInteractionEnabled:NO];
//    self.okBtn.alpha = 0.5f;
//}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}
// 完成按钮事件
- (void)click_ok
{
    if (selectedIndex == 0)
    {// 空白，清空缓存
        [[ChatExCacheManager shareInstance] cleanChatBgWithChatId:self.currentChatId];
    }
    else
    {
        NSString *strName = [self.bgList objectAtIndex:selectedIndex];
        [[ChatExCacheManager shareInstance] setChatBgWithChatId:self.currentChatId chatBg:strName];
    }
    // 退出视图到聊天界面
    [self popToChatView];
}

// 退出视图到聊天界面
- (void)popToChatView {
    
    if (self.currentChatId == CHAT_GLOBAL_ID)
    {// 全局
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
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

#pragma mark - collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.bgList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strImgName = [self.bgList objectAtIndex:indexPath.row];
    // 选中的名字
    NSString *selectedName = [self.bgList objectAtIndex:selectedIndex];
    
    AssetsBgCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    // 设置当前背景缩略图
    [cell setBgImageWithName:strImgName imageSize:self.itemSize];
    // 当前的图 跟选中的 图的名字做比对
    if ([strImgName isEqualToString:selectedName]) {
        cell.imgChoose.image = [UIImage imageNamed:@"icon_choose_sel"];
    }
    else
    {
        cell.imgChoose.image = [UIImage imageNamed:@"icon_choose"];
    }
    
    return cell;
}

// 该方法是设置一个section的上左下右边距  设置一个section在CollectionView中的内边距；
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return self.collectionViewSpace;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return self.itemSize;
//}

// 两个cell之间的最小间距，是由API自动计算的，只有当间距小于该值时，cell会进行换行
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}

// 两行之间的最小间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 记录选中索引
    selectedIndex = indexPath.row;
//    NSString *selectedName = [self.bgList objectAtIndex:indexPath.row];
//    if (![currBgName isEqualToString:selectedName])
//    {// 选中的背景图跟当前使用的对比，如果不一样就显示可点击
//        [self setOKBtnStatus:YES];
//    }
//    else
//    {
//        [self setOKBtnStatus:NO];
//    }
    [self.collectionView reloadData];
}

#pragma mark - 懒加载
- (UIButton *)okBtn
{
    if (!_okBtn)
    {
        _okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _okBtn.frame = CGRectMake(0, 0, 55, 29);
        [_okBtn setTitle:@"保存".lv_localized forState:UIControlStateNormal];
        if(Is_Special_Theme)
        {
            [_okBtn setBackgroundColor:COLOR_NAV_TINT_COLOR];
            [_okBtn setTitleColor:COLOR_CG1 forState:UIControlStateNormal];
        }
        else
        {
            [_okBtn setBackgroundColor:COLOR_CG1];
            [_okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        [_okBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        _okBtn.layer.masksToBounds = YES;
        _okBtn.layer.cornerRadius = 4;
        [_okBtn addTarget:self action:@selector(click_ok) forControlEvents:UIControlEventTouchUpInside];
    }
    return _okBtn;
}

@end
