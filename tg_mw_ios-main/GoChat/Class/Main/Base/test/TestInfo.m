//
//  TestInfo.m
//  GoChat
//
//  Created by wangyutao on 2021/2/25.
//

#import "TestInfo.h"

@implementation TestInfo

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.method forKey:@"method"];
    [aCoder encodeObject:self.body forKey:@"body"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    TestInfo *test = [[TestInfo alloc] init];
    test.name = [aDecoder decodeObjectForKey:@"name"];
    test.method = [aDecoder decodeObjectForKey:@"method"];
    test.body = [aDecoder decodeObjectForKey:@"body"];
    return test;
}

- (id)copyWithZone:(NSZone *)zone
{
    TestInfo *copy = [[[self class] allocWithZone:zone] init];
    if (copy)
    {
        copy.name = [self.name copy];
        copy.method = [self.method copy];
        copy.body = [self.body copy];
    }
    return copy;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@-%@", self.name, self.method];
}

#pragma mark - userdefault save or get
+ (NSArray *)getLastTestList
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"testList"];
    if(data)
    {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

+ (void)saveLastTestList:(NSArray *)list
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:list];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"testList"];
}

+ (void)saveTestInfo:(TestInfo *)test
{
    NSMutableArray *list = [NSMutableArray array];
    NSArray *lt = [self getLastTestList];
    if(lt.count>0)
    {
        [list addObjectsFromArray:lt];
    }
    
    TestInfo *prevTest = nil;
    if(list.count>0)
    {
        for(TestInfo *ti in list)
        {
            if([ti.name isEqualToString:test.name])
            {
                prevTest = ti;
                break;
            }
        }
    }
    if(prevTest)
    {
        prevTest.method = test.method;
        prevTest.body = test.body;
        [list removeObject:prevTest];
        [list insertObject:prevTest atIndex:0];
    }
    else
    {
        [list insertObject:test atIndex:0];
    }
    [self saveLastTestList:list];
}

@end
