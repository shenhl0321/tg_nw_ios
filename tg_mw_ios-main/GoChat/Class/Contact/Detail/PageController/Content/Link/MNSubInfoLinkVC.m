//
//  MNSubInfoLinkVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/22.
//

#import "MNSubInfoLinkVC.h"
#import "MNSubInfoLinkCell.h"
#import "WebHtmlInfoRequest.h"

@interface MNSubInfoLinkVC ()
@property (nonatomic, strong) NSMutableArray *linkArr;
@end

@implementation MNSubInfoLinkVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _linkArr = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
}

-(void)initDataCompleteFunc{
    //遍历一下
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (MessageInfo *msg in self.dataArray) {
        WebpageModel *webmodel = msg.content.web_page;
        if (webmodel) {
            [tempArray addObject:msg];
        } else {
            __block MessageInfo *info = msg;
            NSArray<TextUnit *> *urls = [CZCommonTool parseURLWithContent:info.textTypeContent];
            if (urls.count < 1) {
                continue;
            }
            TextUnit *textUnit = urls.firstObject;
            NSString *url = textUnit.transferredContent;
            info.linkUrls = urls;
            [[WebHtmlInfoRequest shareInstance] getWebHtmlHeaderInfo:url success:^(id  _Nonnull response, NSDictionary * _Nonnull data) {
                info.headerInfo = data;
            } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                
            }];
            [tempArray addObject:info];
        }
        
    }
    self.linkArr = tempArray;
    
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
   
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 107;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"MNSubInfoLinkCell";
    MNSubInfoLinkCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[MNSubInfoLinkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    MessageInfo *obj = [self.dataArray objectAtIndex:indexPath.row];
    [cell fillDataWithMessageInfo:obj];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //链接
    MessageInfo *obj = [self.dataArray objectAtIndex:indexPath.row];
    WebpageModel *webmodel = obj.content.web_page;
    if (webmodel && webmodel.url && webmodel.url.length > 0) {
        BaseWebViewController *v = [BaseWebViewController new];
        v.hidesBottomBarWhenPushed = YES;
        v.titleString = @"";
        v.urlStr = webmodel.url;
        v.type = WEB_LOAD_TYPE_URL;
        [self.navigationController pushViewController:v animated:YES];
    }else{
        if ([CZCommonTool checkUrlWithString:obj.textTypeContent]) {
            NSString *urlstr = obj.textTypeContent;
            if(![urlstr hasPrefix:@"https://"] && ![urlstr hasPrefix:@"http://"])
            {
                urlstr = [NSString stringWithFormat:@"http://%@", urlstr];
            }
            BaseWebViewController *v = [BaseWebViewController new];
            v.hidesBottomBarWhenPushed = YES;
            v.titleString = @"";
            v.urlStr = urlstr;
            v.type = WEB_LOAD_TYPE_URL;
            [self.navigationController pushViewController:v animated:YES];
        }else{
            NSArray *arr = [CZCommonTool getURLFromStr:obj.textTypeContent];
            if (arr && arr.count > 0) {
                NSString *urlstr = [arr firstObject];
                if(![urlstr hasPrefix:@"https://"] && ![urlstr hasPrefix:@"http://"])
                {
                    urlstr = [NSString stringWithFormat:@"http://%@", urlstr];
                }
                BaseWebViewController *v = [BaseWebViewController new];
                v.hidesBottomBarWhenPushed = YES;
                v.titleString = @"";
                v.urlStr = urlstr;
                v.type = WEB_LOAD_TYPE_URL;
                [self.navigationController pushViewController:v animated:YES];
            }else{
                [UserInfo showTips:self.view des:@"数据异常".lv_localized];
            }
        }
    }
}
-(UITableViewStyle)style{
    return UITableViewStylePlain;
}


@end
