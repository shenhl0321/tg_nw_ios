//
//  RedPacketInfo.h
//  GoChat
//
//  Created by wangyutao on 2021/4/6.
//

#import <Foundation/Foundation.h>

//状态定义
typedef enum {
    RpState_Expire = 1, //已过期
    RpState_To_Get,     //未领取
    RpState_Got,        //已领取
    RpState_GotADone,   //已领取并且被抢光
    RpState_Done,       //已被抢光
} RpState;

@interface RedPacketPickUser : NSObject
@property (nonatomic) long userId;
@property (nonatomic) float price;
@property (nonatomic) long gotAt;
@end

@interface RedPacketInfo : NSObject
//通话标识
@property (nonatomic) long redPacketId;
//归属chat
@property (nonatomic) long chatId;
//1.单聊 2.拼手气 3.普通
@property (nonatomic) int type;
//标题
@property (nonatomic, copy) NSString *title;
//单个金额
@property (nonatomic) double price;//改成双精度，防止精度丢失
//总金额
@property (nonatomic) double total_price;////改成双精度，防止精度丢失
//数量
@property (nonatomic) int count;
//创建人
@property (nonatomic) long from;
//创建时间
@property (nonatomic) long createAt;
//是否过期
@property (nonatomic) BOOL isExpire;
//领取列表-RedPacketPickUser
@property (nonatomic, strong) NSArray *users;

//支付密码-仅创建时有效
//钱包密码(MD5)
@property (nonatomic, copy) NSString *password;

- (RpState)getRpState;
- (float)bestPrice;
- (RedPacketPickUser *)curUserRp;
- (NSString *)detailDes;
@end

@interface RP_Msg : NSObject
//通话标识
@property (nonatomic) long redPacketId;
//创建人
@property (nonatomic) long from;
//标题
@property (nonatomic, copy) NSString *title;
@end

@interface RP_Pick_Msg : NSObject
//通话标识
@property (nonatomic) long redPacketId;
//创建人
@property (nonatomic) long from;
//1.单聊 2.拼手气 3.普通
@property (nonatomic) int type;
//单个金额
@property (nonatomic) float price;
//是否最后一个
@property (nonatomic) BOOL isLast;

- (NSString *)description:(long)whoGot;
@end
