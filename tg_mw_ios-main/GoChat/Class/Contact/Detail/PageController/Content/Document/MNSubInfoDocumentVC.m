//
//  MNSubInfoDocumentVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/22.
//

#import "MNSubInfoDocumentVC.h"
#import "MNSubInfoDocumentCell.h"
#import "PhotoAVideoPreviewPagesViewController.h"
#import "FilePreviewViewController.h"

@interface MNSubInfoDocumentVC ()

@end

@implementation MNSubInfoDocumentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)initDataCompleteFunc{
    [super initDataCompleteFunc];
    [self.tableView reloadData];
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 15;
    }
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"MNSubInfoDocumentCell";
    MNSubInfoDocumentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[MNSubInfoDocumentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    MessageInfo *msg = [self.dataArray objectAtIndex:indexPath.row];
    [cell fillDataWithMessageInfo:msg];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 文件
    MessageInfo *info = [self.dataArray objectAtIndex:indexPath.row];
    NSString *fileName = info.content.document.file_name;
    if([DocumentInfo isImageFile:fileName])
    {//图片文件
        PhotoAVideoPreviewPagesViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoAVideoPreviewPagesViewController"];
        v.previewList = @[info];
        v.curIndex = 0;
        v.hidesBottomBarWhenPushed = YES;
        [tp_topMostViewController()
             .navigationController pushViewController:v animated:YES];
    }
    else if([DocumentInfo isVideoFile:fileName])
    {//视频文件
        PhotoAVideoPreviewPagesViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoAVideoPreviewPagesViewController"];
        v.previewList = @[info];
        v.curIndex = 0;
        v.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:v animated:YES];
    }
    else
    {//文件浏览器
        FilePreviewViewController *vc = [[FilePreviewViewController alloc] initWithNibName:@"FilePreviewViewController" bundle:nil];
        vc.previewMessage = info;
        [tp_topMostViewController().navigationController pushViewController:vc animated:YES];
    }
}
-(UITableViewStyle)style{
    return UITableViewStylePlain;
}

@end
