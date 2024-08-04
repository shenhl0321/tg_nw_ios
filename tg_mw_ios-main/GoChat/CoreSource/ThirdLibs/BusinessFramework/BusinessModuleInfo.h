#import <Foundation/Foundation.h>

@class BusinessFramework;

@interface BusinessModuleInfo : NSObject

@property(nonatomic, assign) int businessModuleId;
@property(nonatomic, assign) BusinessFramework* businessFramework;

@end
