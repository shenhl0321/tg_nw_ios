//
//  TextUnit.m
//
//

#import "TextUnit.h"

//某人id
NSString *const TextUnitUserInfoSomeoneID = @"TextUnitUserInfoSomeoneID";
//某人名称
NSString *const TextUnitUserInfoSomeoneName = @"TextUnitUserInfoSomeoneName";

//话题id
NSString *const TextUnitUserInfoTopicID = @"TextUnitUserInfoTopicID";
//话题名称
NSString *const TextUnitUserInfoTopicName = @"TextUnitUserInfoTopicName";

//部门id tx+部门号
NSString *const TextUnitUserInfoDepartmentID = @"TextUnitUserInfoDepartmentID";
//部门名称
NSString *const TextUnitUserInfoDepartmentName = @"TextUnitUserInfoDepartmentName";

@implementation TextUnit

- (id)init
{
    self = [super init];
    if (self)
    {
        self.range = NSMakeRange(0, 0);
    }
    return self;
}

- (NSMutableArray *)rects
{
    if (_rects == nil)
    {
        _rects = [NSMutableArray array];
    }
    return _rects;
}

- (NSMutableDictionary *)userInfo
{
    if (_userInfo == nil)
    {
        _userInfo = [NSMutableDictionary dictionary];
    }
    return _userInfo;
}

- (UIColor *)textColor
{
    if (_textColor == nil)
    {
        _textColor = [UIColor blueColor];
    }
    return _textColor;
}

//返回是否是一种连接类型（如email url @某人等都属于连接类型）
- (BOOL)isLinkType
{
    if (self.textUnitType > TextUnitTypeLinkBegin && self.textUnitType < TextUnitTypeLinkEnd)
    {
        return YES;
    }
    return NO;
}

@end
