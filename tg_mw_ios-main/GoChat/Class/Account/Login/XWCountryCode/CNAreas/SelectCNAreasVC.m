//
//  SelectCNAreasVC.m
//  GoChat
//
//  Created by Autumn on 2022/3/12.
//

#import "SelectCNAreasVC.h"
#import "SelectCNAreasCell.h"
#import "CNAreasModel.h"

@interface SelectCNAreasVC ()

@property (nonatomic, strong) NSMutableArray *areas;

@end

@implementation SelectCNAreasVC

- (void)dy_initData {
    [super dy_initData];
    
    NSString *title = self.parentArea ? self.parentArea.name : @"中国".lv_localized;
    [self.customNavBar setTitle:title];
    
    [self.dataArray addObject:self.sectionArray0];
}

- (void)dy_initUI {
    [super dy_initUI];
    
    [self.tableView xhq_registerCell:SelectCNAreasCell.class];
}

- (void)dy_request {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.sectionArray0 removeAllObjects];
        NSMutableArray *areas = NSMutableArray.array;
        if (self.parentArea) {
            areas = self.parentArea.children.mutableCopy;
        } else {
            NSString *path = [NSBundle.mainBundle pathForResource:@"areas" ofType:@"json"];
            NSData *data = [NSData dataWithContentsOfFile:path];
            NSArray *lists = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            areas = [CNAreasModel mj_objectArrayWithKeyValuesArray:lists];
        }
        
        [areas enumerateObjectsUsingBlock:^(CNAreasModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SelectCNAreasCellItem *item = SelectCNAreasCellItem.item;
            item.cellModel = obj;
            [self.sectionArray0 addObject:item];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.sectionArray0 enumerateObjectsUsingBlock:^(SelectCNAreasCellItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selected = NO;
    }];
    SelectCNAreasCellItem *item = self.dataArray[indexPath.section][indexPath.row];
    item.selected = YES;
    [tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CNAreasModel *area = (CNAreasModel *)item.cellModel;
        if (area.children.count > 0) {
            SelectCNAreasVC *vc = [[SelectCNAreasVC alloc] init];
            vc.parentArea = area;
            vc.countryCode = self.countryCode;
            vc.country = self.country;
            vc.block = self.block;
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        !self.block ? : self.block(self.country, self.countryCode, self.parentArea.name, area.name, area.code);
        [self xhq_popToViewControllerWithIndex:4];
    });
}


@end
