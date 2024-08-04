//
//  CreateTagsVC.m
//  GoChat
//
//  Created by Autumn on 2021/11/9.
//

#import "CreateTagsVC.h"
#import "SelectMemberVC.h"

#import "BlogGroupUserHelper.h"

#import "CreateTagsMemberCell.h"
#import "CreateTagsTitleCell.h"
#import "CreateTagsSectionHeaderView.h"

@interface CreateTagsVC ()

@end

@implementation CreateTagsVC

- (void)dy_initData {
    [super dy_initData];
    
    [self.customNavBar setTitle:@"保存为标签".lv_localized];
    
    [self dy_configureData];
}

- (void)dy_initUI {
    [super dy_initUI];
    
    [self setupNavigationItem];
    self.collectionLayout.minimumLineSpacing = 10;
    self.collectionLayout.minimumInteritemSpacing = 10;
    self.collectionView.backgroundColor = UIColor.xhq_section;
    [self.collectionView xhq_registerCell:CreateTagsTitleCell.class];
    [self.collectionView xhq_registerCell:CreateTagsMemberCell.class];
    [self.collectionView xhq_registerHeaderView:CreateTagsSectionHeaderView.class];
}

- (void)setupNavigationItem {
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 60, 35);
    [rightBtn setTitle:@"保存".lv_localized forState:UIControlStateNormal];
    [rightBtn xhq_cornerRadius:4];
    rightBtn.titleLabel.font = [UIFont helveticaFontOfSize:15];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBtn.backgroundColor = [UIColor colorMain];
    [rightBtn addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBar addSubview:rightBtn];
    
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.width.mas_equalTo(55);
        make.height.mas_equalTo(29);
        make.bottom.mas_equalTo(-8);
    }];
}

- (void)saveAction {
    CreateTagsTitleCellItem *item = self.sectionArray0.firstObject;
    if (![NSString xhq_notEmpty:item.title]) {
        [self.view makeToast:@"请输入标签名称".lv_localized];
        return;
    }
    if (self.selectedContacts.count == 0) {
        [self.view makeToast:@"请至少选择一个成员".lv_localized];
        return;
    }
    NSMutableArray *users = NSMutableArray.array;
    [self.selectedContacts enumerateObjectsUsingBlock:^(UserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [users addObject:@(obj._id)];
    }];

    if (self.type == CreateTagsTypeEdit) {
        [self.view makeToastActivity:CSToastPositionCenter];
        [BlogGroupUserHelper deleteGroup:self.tagId completion:^(BOOL success) {
            [self.view hideToastActivity];
            if (success) {
                [self createTag:item.title users:users];
            }
        }];
    } else {
        [self createTag:item.title users:users];
    }
}

- (void)createTag:(NSString *)title users:(NSArray *)users {
    [self.view makeToastActivity:CSToastPositionCenter];
    [TelegramManager.shareInstance BlogUserGroupCreate:title users:users result:^(NSDictionary *request, NSDictionary *response) {
        [self.view hideToastActivity];
        [self.navigationController popViewControllerAnimated:YES];
    } timeout:^(NSDictionary *request) {
        [self.view hideToastActivity];
    }];
}

#pragma mark - ConfigureData
- (void)dy_configureData {
    [self.dataArray makeObjectsPerformSelector:@selector(removeAllObjects)];
    [self.dataArray removeAllObjects];
    CreateTagsTitleCellItem *tItem = CreateTagsTitleCellItem.item;
    tItem.title = self.tagName;
    [self.sectionArray0 addObject:tItem];
    [self.dataArray addObject:self.sectionArray0];
    
    for (UserInfo *user in self.selectedContacts) {
        CreateTagsMemberCellItem *item = CreateTagsMemberCellItem.item;
        item.user = user;
        [self.sectionArray1 addObject:item];
    }
    CreateTagsMemberCellItem *mItem = CreateTagsMemberCellItem.item;
    [self.sectionArray1 addObject:mItem];
    [self.dataArray addObject:self.sectionArray1];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        return [super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    }
    CreateTagsSectionHeaderView *header = [collectionView xhq_dequeueHeaderView:CreateTagsSectionHeaderView.class indexPath:indexPath];
    header.titleLabel.text = @[@"标签名字".lv_localized, @"成员".lv_localized][indexPath.section];
    return header;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(kScreenWidth(), 40);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return UIEdgeInsetsZero;
    }
    return UIEdgeInsetsMake(0, 20, 0, 20);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DYCollectionViewCellItem *item = self.dataArray[indexPath.section][indexPath.row];
    if (![item isKindOfClass:CreateTagsMemberCellItem.class]) {
        return;
    }
    CreateTagsMemberCellItem *m = (CreateTagsMemberCellItem *)item;
    if (m.user) {
        return;
    }
    SelectMemberVC *VC = [[SelectMemberVC alloc] init];
    VC.selectedContacts = self.selectedContacts;
    VC.from = SelectMemberFromContact;
    [self.navigationController pushViewController:VC animated:YES];
    VC.contactBlock = ^(NSArray<UserInfo *> * _Nonnull contacts) {
        self.selectedContacts = contacts.mutableCopy;
        [self dy_configureData];
        [self.collectionView reloadData];
    };
}

- (void)dy_cellResponse:(__kindof DYCollectionViewCellItem *)item indexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CreateTagsTitleCellItem *m = (CreateTagsTitleCellItem *)item;
        self.tagName = m.title;
        return;
    }
    [self.selectedContacts removeObjectAtIndex:indexPath.row];
    [self dy_configureData];
    [self.collectionView reloadData];
}

@end
