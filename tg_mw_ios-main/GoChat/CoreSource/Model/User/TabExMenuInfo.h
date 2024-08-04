//
//  TabExMenuInfo.h
//  GoChat
//
//  Created by wangyutao on 2021/6/17.
//

#import <Foundation/Foundation.h>

@interface TabExMenuInfo : NSObject
////菜单标题
//@property (nonatomic, copy) NSString *title;
////菜单URL
//@property (nonatomic, copy) NSString *url;

@property (assign, nonatomic) BOOL status;
@property (assign, nonatomic) NSInteger id;
@property (strong, nonatomic) NSString *site_url;
@property (strong, nonatomic) NSString *site_name;
@property (strong, nonatomic) NSString *site_logo;
@property (strong, nonatomic) NSString *created_at;
@property (strong, nonatomic) NSString *updated_at;

- (BOOL)isValid;
+ (TabExMenuInfo *)getTabExMenuInfo;
+ (void)saveTabExMenuInfo:(TabExMenuInfo *)info;
@end
