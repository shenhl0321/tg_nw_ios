//
//  NSString+PinYin.h

#import <Foundation/Foundation.h>

@interface NSString (PinYin)

@property (nonatomic, strong,readonly) NSMutableString *originFullPY;
/**
 *  转换为全拼 例如： 汉字：hanzi
 */
@property (nonatomic, strong,readonly) NSMutableString *fullPY;

/**
 * 转换为大写短拼音 例如: 汉字 : HZ
 */
@property (nonatomic, strong,readonly) NSMutableString *shortPY;

/**
 *  字符串是否包含汉字
 *
 */
- (BOOL)containsChinese;

@end
