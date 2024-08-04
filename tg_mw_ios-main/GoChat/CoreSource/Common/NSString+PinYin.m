//
//  NSString+PinYin.m

#import "NSString+PinYin.h"
#import <objc/runtime.h>

static char originFullPYKey;
static char  fullPYKey;
static char  shortPYKey;

@implementation NSString (PinYin)

- (BOOL)containsChinese
{
    for (int i = 0; i < self.length; i++)
    {
        int ch = [self characterAtIndex:i];
        if ( ch > 0x4e00 && ch < 0x9fff) {
            return YES;
        }
    }
    return NO;
}

- (void)refreshInfo
{
    NSMutableString *fullPY = [[NSMutableString alloc] initWithString:self];
    CFStringTransform((__bridge CFMutableStringRef)fullPY, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)fullPY, NULL, kCFStringTransformStripDiacritics, NO);
    
    objc_setAssociatedObject(self, &originFullPYKey, fullPY,OBJC_ASSOCIATION_COPY);
    
    NSArray *pys = [fullPY componentsSeparatedByString:@" "];
    NSMutableString *shortPY = [[NSMutableString alloc] init];
    for (NSString *py in pys)
    {
        if (py.length > 0) {
            [shortPY appendString:[[py substringToIndex:1]uppercaseString]];
        }
    }
    objc_setAssociatedObject(self, &shortPYKey, shortPY,OBJC_ASSOCIATION_COPY);
    

    fullPY = [[fullPY stringByReplacingOccurrencesOfString:@" " withString:@""] mutableCopy];
    objc_setAssociatedObject(self, &fullPYKey, fullPY,OBJC_ASSOCIATION_COPY);
    

}

- (NSMutableString *)originFullPY
{
    NSMutableString * py= objc_getAssociatedObject(self, &originFullPYKey);
    if (py.length == 0) {
        [self refreshInfo];
        py= objc_getAssociatedObject(self, &originFullPYKey);
    }
    return py;
}

- (NSMutableString *)fullPY
{
    NSMutableString * py= objc_getAssociatedObject(self, &fullPYKey);
    if (py.length == 0) {
        [self refreshInfo];
        py= objc_getAssociatedObject(self, &fullPYKey);
    }
    return py;
}

- (NSMutableString *)shortPY
{
    NSMutableString * py= objc_getAssociatedObject(self, &shortPYKey);
    if (py.length == 0) {
        [self refreshInfo];
        py= objc_getAssociatedObject(self, &shortPYKey);
    }
    return py;
}

@end
