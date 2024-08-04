//
//  RedPacketDetailViewController.m
//  GoChat
//
//  Created by wangyutao on 2021/4/8.
//

#import "RedPacketDetailViewController.h"
#import "RpDetailTopCell.h"
#import "RpDetailUserCell.h"

@interface RedPacketDetailViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) float bestPrice;
@property (nonatomic) RedPacketPickUser *gotUser;
@end

@implementation RedPacketDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.customNavBar.backgroundColor = [UIColor clearColor];
    [self.customNavBar setLeftBtnWithImageName:@"NavBackWhite" title:nil highlightedImageName:nil];
    [self.contentView removeFromSuperview];
    self.bestPrice = [self.rpInfo bestPrice];
    self.gotUser = [self.rpInfo curUserRp];
    
    //HEX_COLOR(@"#d94e4a");
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

-(void)navigationBar:(MNNavigationBar *)navationBar didClickLeftBtn:(UIButton *)btn{
    [self back];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 3;
    }
    return self.rpInfo.users.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        if(self.gotUser == nil)
        {
            return 120.0f;
        }
        else
        {
            return 240.0f;
        }
    }
    if(indexPath.section == 0 && indexPath.row == 1)
    {
        if(self.gotUser == nil)
        {
            return 0.0f;
        }
        else
        {
            return 20.0f;
        }
    }
    if(indexPath.section == 0 && indexPath.row == 2)
    {
        return 50;
    }
    return 72.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            if(self.gotUser == nil)
            {
                RpDetailTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"top" forIndexPath:indexPath];
                [cell resetRpInfo:self.rpInfo];
                return cell;
            }
            else
            {
                RpDetailTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"topWithPrice" forIndexPath:indexPath];
                [cell resetRpInfo:self.rpInfo];
                return cell;
            }
        }
        else if(indexPath.row == 1)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"space" forIndexPath:indexPath];
            return cell;
        }
        else
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"des" forIndexPath:indexPath];
            UILabel *desLabel = [cell viewWithTag:1];
            desLabel.text = [self.rpInfo detailDes];
            return cell;
        }
    }
    else
    {
        RpDetailUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"user" forIndexPath:indexPath];
        RedPacketPickUser *user = [self.rpInfo.users objectAtIndex:indexPath.row];
        [cell resetUserInfo:user isBest:self.rpInfo.type==2&&self.rpInfo.users.count>=self.rpInfo.count&&user.price>=self.bestPrice];
        return cell;
    }
}

@end
