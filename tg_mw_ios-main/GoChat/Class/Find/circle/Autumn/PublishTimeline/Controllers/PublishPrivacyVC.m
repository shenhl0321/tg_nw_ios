//
//  PublishPrivacyVC.m
//  GoChat
//
//  Created by Autumn on 2021/11/5.
//

#import "PublishPrivacyVC.h"
#import "SelectMemberVC.h"

#import "BlogGroupUserHelper.h"

#import "PublishPrivacyListCell.h"
#import "PublishPrivacyPartCell.h"
#import "PublishPrivacyTagsCell.h"

@interface PublishPrivacyVC ()

@property (nonatomic, strong) PublishTimelineVisible *visible;

@property (nonatomic, strong) NSMutableArray<BlogUserGroup *> *groups;

@end

@implementation PublishPrivacyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchGroupUsers];
}

- (void)dy_initData {
    [super dy_initData];
    
    _visible = [[PublishTimelineVisible alloc] init];
    _visible.visibleType = self.timeline.visible.visibleType;
    _visible.users = self.timeline.visible.users;
    _visible.groups = self.timeline.visible.groups;
    _visible.tags = self.timeline.visible.tags;
    
}

- (void)dy_initUI {
    [super dy_initUI];
    [self.customNavBar setTitle:@"谁可以看".lv_localized];
    [self setupNavigationItem];
    [self.tableView xhq_registerCell:PublishPrivacyListCell.class];
    [self.tableView xhq_registerCell:PublishPrivacyPartCell.class];
    [self.tableView xhq_registerCell:PublishPrivacyTagsCell.class];
}

- (void)setupNavigationItem {
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 60, 35);
    [rightBtn setTitle:@"完成".lv_localized forState:UIControlStateNormal];
   
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


- (void)fetchGroupUsers {
    [BlogGroupUserHelper queryGroupsCompletion:^(NSArray<BlogUserGroup *> * _Nonnull groups) {
        self.groups = [groups mutableCopy];
        /// 获取到的数据指针，跟传过来的不同。需要处理一下
        NSMutableArray *tags = NSMutableArray.array;
        [self.visible.tags enumerateObjectsUsingBlock:^(BlogUserGroup * _Nonnull tag, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.groups enumerateObjectsUsingBlock:^(BlogUserGroup * _Nonnull group, NSUInteger idx, BOOL * _Nonnull stop) {
                if (tag.ids == group.ids) {
                    [tags addObject:group];
                    return;
                }
            }];
        }];
        self.visible.tags = tags.mutableCopy;
        
        [self dy_configureData];
        [self.tableView reloadData];
    }];
}

- (void)dy_configureData {
    [self.dataArray removeAllObjects];
    NSArray *types = @[@(VisibleTypePublic), @(VisibleTypePrivate), @(VisibleTypeAllow), @(VisibleTypeNotAllow)];
    for (NSNumber *type in types) {
        NSMutableArray *items = NSMutableArray.array;
        PublishPrivacyListCellItem *item = PublishPrivacyListCellItem.item;
        item.type = (VisibleType)[type integerValue];
        BOOL isSelected = item.type == _visible.visibleType;
        item.selected = isSelected;
        [items addObject:item];
        if (isSelected) {
            [self addSubListCellItemIfNeededWithType:item.type inItems:items];
        }
        [self.dataArray addObject:items];
    }
}

- (void)confirmAction {
    /// 编辑标签接口繁琐，故选择直接先删除，再添加。
    /// 此方法会导致 tag id 变更。
    /// 所以提交之前，循环查询下选中的 tag id 是否存在与后台接口中
    NSMutableArray *tags = NSMutableArray.array;
    [self.groups enumerateObjectsUsingBlock:^(BlogUserGroup * _Nonnull group, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.visible.tags enumerateObjectsUsingBlock:^(BlogUserGroup * _Nonnull tag, NSUInteger idx, BOOL * _Nonnull stop) {
            if (tag.ids == group.ids) {
                [tags addObject:tag];
                return;
            }
        }];
    }];
    self.visible.tags = tags.mutableCopy;
    if (self.visible.visibleType == VisibleTypeAllow || self.visible.visibleType == VisibleTypeNotAllow) {
        if (self.visible.users.count == 0 && self.visible.groups.count == 0 && self.visible.tags.count == 0) {
            [self.view makeToast:@"请至少选择一个标签".lv_localized];
            return;
        }
    }
    self.timeline.visible = self.visible;
    !self.confirmBlock ? : self.confirmBlock();
    [self.navigationController popViewControllerAnimated:true];
}


- (void)listCellSelectedIndexPath:(NSIndexPath *)indexPath {
    PublishPrivacyListCellItem *item = self.dataArray[indexPath.section][indexPath.row];
    if (item.isSelected) {
        return;
    }
    for (NSMutableArray *items in self.dataArray) {
        PublishPrivacyListCellItem *item = items.firstObject;
        item.selected = NO;
        /// 删除多余的子列表
        if (items.count > 1) {
            [items removeAllObjects];
            [items addObject:item];
        }
    }
    item.selected = YES;
    _visible.visibleType = item.type;
    [self addSubListCellItemIfNeededWithType:item.type inItems:self.dataArray[indexPath.section]];
    [self.tableView reloadData];
}

- (void)partCellSelectedIndexPath:(NSIndexPath *)indexPath {
    PublishPrivacyPartCellItem *item = self.dataArray[indexPath.section][indexPath.row];
    SelectMemberFrom from = item.type == PublishPrivacyPartTypeContact ? SelectMemberFromContact : SelectMemberFromGroup;
    SelectMemberVC *select = [[SelectMemberVC alloc] init];
    select.from = from;
    select.showSaveToTagAlert = YES;
    select.selectedGroups = _visible.groups.mutableCopy;
    select.selectedContacts = _visible.users.mutableCopy;
    select.groupBlock = ^(NSArray<ChatInfo *> * _Nonnull groups) {
        self.visible.groups = groups;
        [self dy_configureData];
        [self.tableView reloadData];
    };
    select.contactBlock = ^(NSArray<UserInfo *> * _Nonnull contacts) {
        self.visible.users = contacts;
        [self dy_configureData];
        [self.tableView reloadData];
    };
    [self.navigationController pushViewController:select animated:YES];
}

- (void)TagsCellSelectedIndexPath:(NSIndexPath *)indexPath {
    PublishPrivacyTagsCellItem *item = self.dataArray[indexPath.section][indexPath.row];
    BlogUserGroup *tag = (BlogUserGroup *)item.cellModel;
    item.selected = !item.isSelected;
    if (item.isSelected) {
        [_visible.tags addObject:tag];
    } else {
        [_visible.tags removeObject:tag];
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

/// 添加子选项（仅支持部分可见/部分不可见）
- (void)addSubListCellItemIfNeededWithType:(VisibleType)type inItems:(NSMutableArray *)items {
    if (type == VisibleTypePublic || type == VisibleTypePrivate) {
        return;
    }
    PublishPrivacyPartCellItem *item = PublishPrivacyPartCellItem.item;
    item.type = PublishPrivacyPartTypeGroup;
    item.names = self.visible.groupNames;
    [items addObject:item];
    
    item = PublishPrivacyPartCellItem.item;
    item.type = PublishPrivacyPartTypeContact;
    item.names = self.visible.userNames;
    [items addObject:item];
    
    for (BlogUserGroup *group in self.groups) {
        PublishPrivacyTagsCellItem *item = PublishPrivacyTagsCellItem.item;
        item.cellModel = group;
        item.selected = [_visible.tagIds containsObject:@(group.ids)];
        [items addObject:item];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    DYTableViewCellItem *item = self.dataArray[indexPath.section][indexPath.row];
    return [item isKindOfClass:PublishPrivacyTagsCellItem.class];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除".lv_localized handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSMutableArray *items = self.dataArray[indexPath.section];
        PublishPrivacyTagsCellItem *item = items[indexPath.row];
        BlogUserGroup *tag = (BlogUserGroup *)item.cellModel;
        [self.view makeToastActivity:CSToastPositionCenter];
        [BlogGroupUserHelper deleteGroup:tag.ids completion:^(BOOL success) {
            [self.view hideToastActivity];
            if (success) {
                if ([self.timeline.visible.tags containsObject:tag]) {
                    [self.timeline.visible.tags removeObject:tag];
                }
                [items removeObject:item];
                [self.tableView reloadData];
            }
        }];
    }];
    return @[action];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DYTableViewCellItem *item = self.dataArray[indexPath.section][indexPath.row];
    if ([item isKindOfClass:PublishPrivacyListCellItem.class]) {
        [self listCellSelectedIndexPath:indexPath];
        return;
    }
    if ([item isKindOfClass:PublishPrivacyPartCellItem.class]) {
        [self partCellSelectedIndexPath:indexPath];
        return;
    }
    if ([item isKindOfClass:PublishPrivacyTagsCellItem.class]) {
        [self TagsCellSelectedIndexPath:indexPath];
        return;
    }
}


@end
