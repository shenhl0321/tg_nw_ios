//
//  MsgLocationInfo.h
//  GoChat
//
//  Created by wangyutao on 2021/6/2.
//

#import <Foundation/Foundation.h>

@interface MsgLocationInfo : NSObject
//@location
@property (nonatomic, copy) NSString *type;
//latitude
@property (nonatomic) double latitude;
//longitude
@property (nonatomic) double longitude;
@end
