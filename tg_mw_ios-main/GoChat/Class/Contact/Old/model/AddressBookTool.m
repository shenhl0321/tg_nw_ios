//
//  AddressBookTool.m
//  GoChat
//
//  Created by mac on 2021/9/6.
//

#import "AddressBookTool.h"
#import "AddressItemModel.h"

@interface AddressBookTool ()


@end
@implementation AddressBookTool

//请求通讯录权限
#pragma mark 获取通讯录权限状态
+ (CNAuthorizationStatus)requestAddressBookPermissionsStatus{
    
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusNotDetermined) {
        NSLog(@"未授权过");
    }
    else if(status == CNAuthorizationStatusRestricted)
    {
        NSLog(@"用户拒绝");
    }
    else if (status == CNAuthorizationStatusDenied)
    {
        NSLog(@"用户拒绝");
    }
    else if (status == CNAuthorizationStatusAuthorized)//已经授权
    {
        NSLog(@"已经授权");
    }
    return status;
    
}
#pragma mark 请求通信录授权
+ (void)requestAddressBookPermissionsAuthorized:(void (^)(BOOL))completionHandler{
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError*  _Nullable error) {
        if (error) {
            NSLog(@"授权失败");
            completionHandler(NO);
        }else {
            NSLog(@"成功授权");
            completionHandler(YES);
        }
    }];
}

#pragma mark 通讯录列表

//contacts = @[
//        @{@"first_name":@"龙",@"last_name":"默默",@"phone_number":@"14766666666",@"user_id":0},
//        @{@"first_name":@"王",@"last_name":"宝强",@"phone_number":@"14768888888",@"user_id":0},
//    ];

+ (NSMutableArray *)requestAddressBookList{
    
    NSMutableArray *phoneArray = [[NSMutableArray array] init];
    
    NSArray *keysToFetch = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    
    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        NSLog(@"-------------------------------------------------------");
        
        NSString *givenName = contact.givenName;
        NSString *familyName = contact.familyName;
          NSLog(@"givenName=%@, familyName=%@", givenName, familyName);
        //拼接姓名
        NSString *nameStr = [NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName];
        
        NSArray *phoneNumbers = contact.phoneNumbers;
        
        for (CNLabeledValue *labelValue in phoneNumbers) {
            
        //遍历一个人名下的多个电话号码
            CNPhoneNumber *phoneNumber = labelValue.value;
            
            NSString * string = phoneNumber.stringValue ;
            
            //去掉电话中的特殊字符
            string = [string stringByReplacingOccurrencesOfString:@"+" withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            if ([NSString xhq_phoneFormatCheck:string]) {
                string = [@"86" stringByAppendingString:string];
            }
            
        NSLog(@"姓名=%@, 电话号码是=%@", nameStr, string);
//            contacts = @[
            //        @{@"first_name":@"龙",@"last_name":"默默",@"phone_number":@"14766666666",@"user_id":0},
            //        @{@"first_name":@"王",@"last_name":"宝强",@"phone_number":@"14768888888",@"user_id":0},
            //    ];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:givenName forKey:@"first_name"];
            [dic setObject:familyName forKey:@"last_name"];
            [dic setObject:string forKey:@"phone_number"];
            [dic setObject:@(0) forKey:@"user_id"];
            [phoneArray addObject:dic];
        }
    }];
    return phoneArray;
}

//中文转英文
+ (NSString *)transformToPinyin:(NSString *)str
{
    // 空值判断
    if (IsStrEmpty(str)) {
        return @"";
    }
    // 将字符串转为NSMutableString类型
    NSMutableString *string = [str mutableCopy];
    // 将字符串转换为拼音音调格式
    CFStringTransform((__bridge CFMutableStringRef)string, NULL, kCFStringTransformMandarinLatin, NO);
    // 去掉音调符号
    CFStringTransform((__bridge CFMutableStringRef)string, NULL, kCFStringTransformStripDiacritics, NO);
    // 返回不带声调拼音字符串
    return string;
}

// 按首字母分组排序数组
+(NSMutableArray *)sortObjectsAccordingToInitialWith:(NSArray *)phoneArray{
 
    // 初始化UILocalizedIndexedCollation
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
 
    //得出collation索引的数量，这里是27个（26个字母和1个#）
    NSInteger sectionTitlesCount = [[collation sectionTitles] count];
    //初始化一个数组newSectionsArray用来存放最终的数据，我们最终要得到的数据模型应该形如@[@[以A开头的数据数组], @[以B开头的数据数组], @[以C开头的数据数组], ... @[以#(其它)开头的数据数组]]
    NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
 
    //初始化27个空数组加入newSectionsArray
    for (NSInteger index = 0; index < sectionTitlesCount; index++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [newSectionsArray addObject:array];
    }
 
    //将每个名字分到某个section下
    for (AddressItemModel *model in phoneArray) {
        NSString *nameStr = [NSString stringWithFormat:@"%@%@",model.first_name,model.last_name];
        model.pinyin = [self transformToPinyin:nameStr];
        model.name = nameStr;
        //获取name属性的值所在的位置，比如"林丹"，首字母是L，在A~Z中排第11（第一位是0），sectionNumber就为11
        NSInteger sectionNumber = [collation sectionForObject:model collationStringSelector:@selector(pinyin)];
        //把name为“林丹”的p加入newSectionsArray中的第11个数组中去
        NSMutableArray *sectionNames = newSectionsArray[sectionNumber];
        [sectionNames addObject:model];
    }
 
    //对每个section中的数组按照name属性排序
    for (NSInteger index = 0; index < sectionTitlesCount; index++) {
        NSMutableArray *personArrayForSection = newSectionsArray[index];
        NSArray *sortedPersonArrayForSection = [collation sortedArrayFromArray:personArrayForSection collationStringSelector:@selector(name)];
        newSectionsArray[index] = sortedPersonArrayForSection;
    }
    
    return newSectionsArray;
}

@end
