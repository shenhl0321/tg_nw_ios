//
//  MNTablePopModel.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNTablePopModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, copy) NSString *aId;
- (instancetype)initWithTitle:(NSString *)title iconName:(NSString *)iconName;
- (instancetype)initWithId:(NSString *)aId title:(NSString *)title iconName:(NSString *)iconName;
@end

NS_ASSUME_NONNULL_END
