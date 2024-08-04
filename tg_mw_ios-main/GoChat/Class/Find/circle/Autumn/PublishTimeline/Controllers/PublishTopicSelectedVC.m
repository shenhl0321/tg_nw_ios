//
//  PublishTopicSelectedVC.m
//  GoChat
//
//  Created by Autumn on 2022/3/1.
//

#import "PublishTopicSelectedVC.h"
#import "PublishTopicListCell.h"

@interface PublishTopicSelectedVC ()

@end

@implementation PublishTopicSelectedVC

- (void)dy_initData {
    [super dy_initData];
    
    [self.dataArray addObject:self.sectionArray0];
    
    self.emptyTitle = @"暂无#话题".lv_localized;
    self.emptyImageName = @"icon_cicle_topic_empty";
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

- (void)dy_initUI {
    [super dy_initUI];
    
    self.customNavBar.hidden = YES;
    self.tableView.backgroundColor = UIColor.whiteColor;
    [self.tableView xhq_registerCell:PublishTopicListCell.class];
}


- (void)fetchTopics {
//    if ([NSString xhq_notEmpty:self.keyword]) {
//        [self.sectionArray0 removeAllObjects];
//        BlogTopic *first = [BlogTopic topicWithKeyword:self.keyword];
//        [self dy_configureDataWithModel:first];
//        [self.tableView reloadData];
//        return;
//    }
    NSDictionary *parameters;
    if ([NSString xhq_notEmpty:self.keyword]) {
        parameters = @{@"@type": @"searchTopic", @"keyword": self.keyword};
    } else {
        parameters = @{@"@type": @"getHotTopic", @"limit": @(20)};
    }
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        [self.sectionArray0 removeAllObjects];
        if (![TelegramManager isResultError:response]) {
            NSArray *lists = response[@"topics"];
            NSMutableArray *topics = [BlogTopic mj_objectArrayWithKeyValuesArray:lists];
            if ([NSString xhq_notEmpty:self.keyword]) {
                BlogTopic *first = BlogTopic.model;
                first.name = self.keyword;
                [topics insertObject:first atIndex:0];
            }
            for (BlogTopic *b in topics) {
                [self dy_configureDataWithModel:b];
            }
        }
        [self.tableView reloadData];
    } timeout:^(NSDictionary *request) {
        [self.sectionArray0 removeAllObjects];
        [self.tableView reloadData];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PublishTopicListCellItem *item = self.dataArray[indexPath.section][indexPath.row];
    BlogTopic *topic = (BlogTopic *)item.cellModel;
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedTopic:)]) {
        [self.delegate selectedTopic:topic];
    }
}

#pragma mark - ConfigureData
- (void)dy_configureDataWithModel:(DYModel *)model {
    PublishTopicListCellItem *item = PublishTopicListCellItem.item;
    item.cellModel = model;
    [self.sectionArray0 addObject:item];
}


#pragma mark - Public
- (void)hide {
    [self.sectionArray0 removeAllObjects];
    [self.tableView reloadData];
    self.view.hidden = YES;
    _keyword = @"";
}

- (void)setKeyword:(NSString *)keyword {
    _keyword = keyword;
    self.view.hidden = NO;
    [self fetchTopics];
}

@end
