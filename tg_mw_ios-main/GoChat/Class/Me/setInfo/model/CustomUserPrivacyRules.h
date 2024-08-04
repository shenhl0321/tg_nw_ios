//
//  CustomUserPrivacyRules.h
//  GoChat
//
//  Created by apple on 2022/2/7.
//

#import <Foundation/Foundation.h>

@interface CustomUserPrivacyRules : NSObject
/// 1 - 允许所有 2 - 受限的用户 3 - 设定的日期 4 - 设定的数量
@property (nonatomic,assign) NSInteger rule;
/// 用户id
@property (nonatomic,strong) NSArray *users;
/// 朋友查看范围（最近3天/最近一个月/最近半年/最近一年）
@property (nonatomic,assign) NSInteger days;
/// 陌生人查看范围 （3条/10条/所有）
@property (nonatomic,assign) NSInteger counts;

/// 时间提示
@property (nonatomic,copy) NSString *timeTip;
/// 范围提示
@property (nonatomic,copy) NSString *rangeTip;
@end


@interface CustomUserPrivacy : NSObject
/// 1 - 不让谁看 2 - 不看谁 3 - 朋友查看范围（最近3天/最近一个月/最近半年/最近一年） 4 - 陌生人查看范围 （3条/10条/所有）
@property (nonatomic,assign) NSInteger key;
/// <#code#>
@property (nonatomic,strong) NSArray<CustomUserPrivacyRules *> *rules;
@end


