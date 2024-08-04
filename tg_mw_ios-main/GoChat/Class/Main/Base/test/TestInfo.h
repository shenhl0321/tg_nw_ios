//
//  TestInfo.h
//  GoChat
//
//  Created by wangyutao on 2021/2/25.
//

#import <Foundation/Foundation.h>

@interface TestInfo : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSString *body;

+ (NSArray *)getLastTestList;
+ (void)saveTestInfo:(TestInfo *)test;
@end
