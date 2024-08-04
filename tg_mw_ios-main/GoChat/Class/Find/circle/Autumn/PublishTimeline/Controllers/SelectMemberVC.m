//
//  SelectMemberVC.m
//  GoChat
//
//  Created by Autumn on 2021/11/7.
//

#import "SelectMemberVC.h"
#import "CreateTagsVC.h"

#import "SelectMemberSearchView.h"
#import "SelectMemberCell.h"

@interface SelectMemberVC ()

@property (nonatomic, assign, readonly, getter=isFromGroup) BOOL fromGroup;

@property (nonatomic, strong) NSMutableArray *contactList;
@property (nonatomic, strong) NSMutableArray *sectionContactList;

@property (nonatomic, strong) NSMutableArray *groupList;
@property (nonatomic, strong) NSMutableArray *sectionGroupList;

@property (nonatomic, strong) SelectMemberSearchView *searchView;

@property (nonatomic, strong) NSString *keyword;


@end

@implementation SelectMemberVC

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(0);
        make.top.mas_equalTo(_searchView.mas_bottom);
    }];
}

- (void)dy_initData {
    [super dy_initData];
    
    self.navigationItem.title = self.navigationTitle;
    if (self.isFromGroup) {
        _groupList = NSMutableArray.array;
        _sectionGroupList = NSMutableArray.array;
        [self reloadGroups];
    } else {
        _contactList = NSMutableArray.array;
        _sectionContactList = NSMutableArray.array;
        [self reloadContacts];
    }
}

- (void)dy_initUI {
    [super dy_initUI];
    [self setupNavigationItem];
    [self.view addSubview:self.searchView];
    self.tableView.sectionIndexColor = COLOR_CG1;
    [self.tableView xhq_registerCell:SelectMemberCell.class];
}

- (void)setupNavigationItem {
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 60, 35);
    [rightBtn setTitle:@"确定".lv_localized forState:UIControlStateNormal];
    [rightBtn xhq_cornerRadius:4];
    rightBtn.titleLabel.font = [UIFont helveticaFontOfSize:15];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBtn.backgroundColor = [UIColor colorMain];
    [rightBtn addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBar addSubview:rightBtn];
    
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.width.mas_equalTo(55);
        make.height.mas_equalTo(29);
        make.bottom.mas_equalTo(-8);
    }];
}

#pragma mark - ConfigureData

- (void)reloadContacts {
    if (self.isFromGroup) {
        return;
    }
    [self.contactList removeAllObjects];
    [self.sectionContactList removeAllObjects];
    
    NSArray *list = [[TelegramManager shareInstance] getContacts];
    if(list.count > 0) {
        if (self.keyword || self.keyword.length > 0) {
            for (UserInfo *user in list) {
                if ([user isMatch:self.keyword]) {
                    [self.contactList addObject:user];
                }
            }
        } else {
            [self.contactList addObjectsFromArray:list];
        }
    }
    
    NSInteger sectionCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:sectionCount];
    for (int i = 0; i < sectionCount; i++) {
        NSMutableArray *sectionArray = [NSMutableArray array];
        [sectionArrays addObject:sectionArray];
    }
    
    //将user添加到对应section的array下
    for (UserInfo *user in self.contactList) {
        [(NSMutableArray *)[sectionArrays objectAtIndex:user.sectionNum] addObject:user];
    }
    
    //排序
    for (int i = 0; i < [sectionArrays count]; ++i) {
        NSArray *sectionArray = [[sectionArrays objectAtIndex:i] copy];
        sectionArray = [sectionArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            UserInfo *user1 = (UserInfo *)obj1;
            UserInfo *user2 = (UserInfo *)obj2;
            return [user1.displayName_full_py compare:user2.displayName_full_py];
        }];
        
        [self.sectionContactList addObject:sectionArray];
    }
    [self dy_configureData];
    [self.tableView reloadData];
}

- (void)reloadGroups {
    if (!self.isFromGroup) {
        return;
    }
    [self.groupList removeAllObjects];
    [self.sectionGroupList removeAllObjects];
    
    NSArray *list = [[TelegramManager shareInstance] getGroups];
    if(list.count > 0) {
        if (self.keyword && self.keyword.length > 0) {
            for (ChatInfo *group in list) {
                if ([group isMatch:self.keyword]) {
                    [self.groupList addObject:group];
                }
            }
        } else {
            [self.groupList addObjectsFromArray:list];
        }
    }
    
    NSInteger sectionCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:sectionCount];
    for (int i = 0; i < sectionCount; i++) {
        NSMutableArray *sectionArray = [NSMutableArray array];
        [sectionArrays addObject:sectionArray];
    }
    
    //将user添加到对应section的array下
    for (ChatInfo *chat in self.groupList) {
        [(NSMutableArray *)[sectionArrays objectAtIndex:chat.sectionNum] addObject:chat];
    }
    
    //排序
    for (int i = 0; i < [sectionArrays count]; ++i) {
        NSArray *sectionArray = [[sectionArrays objectAtIndex:i] copy];
        sectionArray = [sectionArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            ChatInfo *chat1 = (ChatInfo *)obj1;
            ChatInfo *chat2 = (ChatInfo *)obj2;
            return [chat1.title_full_py compare:chat2.title_full_py];
        }];
        
        [self.sectionGroupList addObject:sectionArray];
    }
    [self dy_configureData];
    [self.tableView reloadData];
}

- (void)dy_configureData {
    [self.dataArray removeAllObjects];
    if (self.isFromGroup) {
        for (NSArray *sections in self.sectionGroupList) {
            NSMutableArray *items = NSMutableArray.array;
            for (ChatInfo *group in sections) {
                SelectMemberCellItem *item = SelectMemberCellItem.item;
                item.group = group;
                item.selected = [self.selectedGroups containsObject:group];
                [items addObject:item];
            }
            [self.dataArray addObject:items];
        }
    } else {
        for (NSArray *sections in self.sectionContactList) {
            NSMutableArray *items = NSMutableArray.array;
            for (UserInfo *member in sections) {
                SelectMemberCellItem *item = SelectMemberCellItem.item;
                item.member = member;
                item.selected = [self.selectedContacts containsObject:member];
                [items addObject:item];
            }
            [self.dataArray addObject:items];
        }
    }
}

- (void)confirmAction {
//    if (self.selectedGroups.count == 0 && self.isFromGroup) {
//        [self.view makeToast:@"请最少选择一个群组"];
//        return;
//    }
    
//    if (self.selectedContacts.count == 0 && !self.isFromGroup) {
//        [self.view makeToast:@"请最少选择一个联系人"];
//        return;
//    }
    
    
    if (self.isFromGroup) {
        !self.groupBlock ? : self.groupBlock(self.selectedGroups);
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    /// 只选择联系人
    if (!self.isShowSaveToTagAlert || self.selectedContacts.count == 0) {
        !self.contactBlock ? : self.contactBlock(self.selectedContacts);
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    @weakify(self);
    MMPopupItemHandler block = ^(NSInteger index) {
        @strongify(self);
        if (index == 0) {
            !self.contactBlock ? : self.contactBlock(self.selectedContacts);
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self saveToLabels];
        }
    };
    NSArray *items = @[MMItemMake(@"取消".lv_localized, MMItemTypeNormal, block),
                       MMItemMake(@"存为标签".lv_localized, MMItemTypeHighlight, block)];
    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示".lv_localized detail:@"保存为标签，下次可直接而使用？".lv_localized items:items];
    [view show];
        
}

- (void)saveToLabels {
    CreateTagsVC *tags = [[CreateTagsVC alloc] init];
    tags.type = CreateTagsTypeAdd;
    tags.selectedContacts = self.selectedContacts;
    [self.navigationController pushViewController:tags animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *controllers = self.navigationController.viewControllers.mutableCopy;
        for (UIViewController *vc in controllers) {
            if ([vc isKindOfClass:self.class]) {
                [controllers removeObject:vc];
                break;
            }
        }
        self.navigationController.viewControllers = controllers.copy;
    });
}


#pragma mark - UITableViewDataSource

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectMemberCellItem *item = self.dataArray[indexPath.section][indexPath.row];
    item.selected = !item.isSelected;
    [self.tableView reloadData];
    
    if (self.isFromGroup) {
        if (item.isSelected) {
            [self.selectedGroups addObject:item.group];
        } else {
            [self.selectedGroups removeObject:item.group];
        }
        self.searchView.groups = self.selectedGroups;
    } else {
        if (item.isSelected) {
            [self.selectedContacts addObject:item.member];
        } else {
            [self.selectedContacts removeObject:item.member];
        }
        self.searchView.contacts = self.selectedContacts;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *sections = self.isFromGroup ? self.sectionGroupList : self.sectionContactList;
    if (section < sections.count) {
        NSArray *sectionArr = sections[section];
        if (sectionArr.count == 0) {
            return nil;
        }
        UIView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"AzSectionHeaderView" owner:nil options:nil] objectAtIndex:0];
        headerView.backgroundColor = tableView.backgroundColor;
        UILabel *titleLabel = (UILabel *)[headerView viewWithTag:101];
        NSArray *sectionTitlesArr = [[UILocalizedIndexedCollation currentCollation] sectionTitles];
        if (section < sectionTitlesArr.count) {
            titleLabel.text = sectionTitlesArr[section];
        } else {
            titleLabel.text = nil;
        }
        return headerView;
    }
    return nil;
}

//约束section header高度 当section下没有联系人时置为0
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSArray *sections = self.isFromGroup ? self.sectionGroupList : self.sectionContactList;
    if (section < sections.count) {
        NSArray *sectionArr = sections[section];
        if (sectionArr.count == 0) {
            return 0.01;
        }
    }
    return 20;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    //点击索引的响应
    NSInteger section = [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
    return section;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    //右侧索引
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

#pragma mark - getter
- (BOOL)isFromGroup {
    return self.from == SelectMemberFromGroup;
}

- (NSString *)navigationTitle {
    return self.isFromGroup ? @"群组".lv_localized : @"联系人".lv_localized;
}

- (SelectMemberSearchView *)searchView {
    if (!_searchView) {
        _searchView = [[SelectMemberSearchView alloc] init];
        _searchView.fromGroup = self.isFromGroup;
        if (self.isFromGroup) {
            _searchView.groups = self.selectedGroups;
        } else {
            _searchView.contacts = self.selectedContacts;
        }
        @weakify(self);
        _searchView.searchBlock = ^{
            @strongify(self);
            self.keyword = self.searchView.keyword;
            [self reloadGroups];
            [self reloadContacts];
        };
    }
    return _searchView;
}

@end
