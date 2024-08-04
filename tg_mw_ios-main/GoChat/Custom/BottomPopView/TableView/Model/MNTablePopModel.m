//
//  MNTablePopModel.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/5.
//

#import "MNTablePopModel.h"

@implementation MNTablePopModel

- (instancetype)initWithId:(NSString *)aId title:(NSString *)title iconName:(NSString *)iconName{
    self = [super init];
    if (self) {
        _title = title;
        _iconName = iconName;
        _aId = aId;
    }
    return self;
}
- (instancetype)initWithTitle:(NSString *)title iconName:(NSString *)iconName
{
    return [self initWithId:nil title:title iconName:iconName];
}
@end
