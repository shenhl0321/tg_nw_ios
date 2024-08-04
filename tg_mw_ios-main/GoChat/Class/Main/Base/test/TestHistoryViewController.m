//
//  TestHistoryViewController.m
//  GoChat
//
//  Created by wangyutao on 2021/2/25.
//

#import "TestHistoryViewController.h"
#import "TestInfo.h"

@interface TestHistoryViewController ()
@property (nonatomic, strong) NSArray *testList;
@end

@implementation TestHistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"测试历史".lv_localized;
    self.testList = [TestInfo getLastTestList];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.testList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UILabel *textLabel = [cell viewWithTag:1];
    TestInfo *test = [self.testList objectAtIndex:indexPath.row];
    textLabel.text = [test description];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TestInfo *test = [self.testList objectAtIndex:indexPath.row];
    if([self.delegate respondsToSelector:@selector(TestHistoryViewController_Choose:)])
    {
        [self.delegate TestHistoryViewController_Choose:test];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
