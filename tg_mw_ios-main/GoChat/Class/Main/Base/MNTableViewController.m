//
//  MNTableViewController.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/12.
//

#import "MNTableViewController.h"

@interface MNTableViewController ()

@end

@implementation MNTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:self.customNavBar];
    [self.view bringSubviewToFront:self.customNavBar];
    [self.customNavBar style_title_LeftBtn_RightBtn];
    self.customNavBar.delegate = self;
    self.tableView.frame = CGRectMake(0, APP_TOP_BAR_HEIGHT, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-APP_TOP_BAR_HEIGHT-kBottom34());
//    self.customNavBar.backgroundColor = [UIColor whiteColor];
    if (self.navigationController.viewControllers.count > 1) {
       self.backBtn = [self.customNavBar setLeftBtnWithImageName:@"NavBack" title:nil highlightedImageName:nil];
    }else{
        if ([self isKindOfClass:NSClassFromString(@"CameraViewController")]) {
            self.backBtn = [self.customNavBar setLeftBtnWithImageName:@"NavBack" title:nil highlightedImageName:nil];
        }
    }

//    self.navigationController.navigationBar.hidden = YES;
//    self.navigationController.navigationBar.hidden = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(MNNavigationBar *)customNavBar{
    if (!_customNavBar) {
        _customNavBar = [[MNNavigationBar alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_TOP_BAR_HEIGHT)];
        
       
    }
    return _customNavBar;
}

- (void)refreshCustonNavBarFrame:(CGRect)frame{
    self.customNavBar.frame = frame;
    self.contentView.frame = CGRectMake(0, CGRectGetMaxY(self.customNavBar.frame), APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-CGRectGetMaxY(self.customNavBar.frame)-kBottom34());
//    [self.customNavBar addRoundedCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight radius:36];
}

-(void)navigationBar:(MNNavigationBar *)navationBar didClickLeftBtn:(UIButton *)btn{
    [self back];
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

-(UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, APP_TOP_BAR_HEIGHT, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-APP_TOP_BAR_HEIGHT-kBottom34())];

    }
    return _contentView;
}
#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
