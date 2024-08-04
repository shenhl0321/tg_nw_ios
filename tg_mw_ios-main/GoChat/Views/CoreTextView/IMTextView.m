//
//  IMTextView.m
//

#import "IMTextView.h"
#import "TextUnit.h"
#import "IMMessagePasteboard.h"

const NSUInteger MessageMaxLength = 2000;

typedef NS_ENUM(NSUInteger, DYLanguageType) {
    DYLanguageTypeChinese = 0,//简体中文
    DYLanguageTypeEnglish,
    DYLanguageTypeJapanese,
    DYLanguageTypeChineseTraditional,//繁体中文
};

@interface IMTextView()
{
    NSMutableAttributedString *_attributedString;
}

//表情的字符对应的汉字描述
@property (nonatomic, strong) NSDictionary *chineseEmotionDic;

//表情的汉字字符对应的符号描述
@property (nonatomic, strong) NSDictionary *characterEmotionDic;

//向属性串指定位置插入一个textUnit
- (void)insertText:(NSString *)text toAttributedStringAtIndex:(NSUInteger)index withTextUnit:(TextUnit *)textUnit;

//属性串操作 ，如果属性串为空，则什么也不做
- (void)deleteAttributedStringInRange:(NSRange)range;

@end

@implementation IMTextView
@dynamic delegate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.selectedRange = NSMakeRange([self.text length], 0);
    if ([self respondsToSelector:@selector(layoutManager)])
    {
        self.layoutManager.allowsNonContiguousLayout = NO;
    }
    if ([self respondsToSelector:@selector(textContainer)])
    {
        self.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    }
}

- (void)paste:(id)sender
{
    //有特殊内容
    if ([[IMMessagePasteboard messagePasteboard] hasCustomContent])
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(textView:willPaste:)])
        {
            [self.delegate textView:self willPaste:[IMMessagePasteboard messagePasteboard].chatRecordDTO];
        }
        return;
    }
    
    [super paste:sender];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if ([[IMMessagePasteboard messagePasteboard] hasCustomContent])
    {
        if (action == @selector(paste:))
        {
            return YES;
        }
    }
    
    return [super canPerformAction:action withSender:sender];
}

//text表示中文表示的表情符
- (void)insertEmoji:(NSString *)text
{
    NSString *chineseEmotion = [self.chineseEmotionDic objectForKey:text];
    
    //直接调用TextView的方法
    TextUnit *unit = [[TextUnit alloc] init];
    unit.originalContent = chineseEmotion;  //输入框显示的串
    unit.transferredContent = text;         //发送时需要替换为的串
    unit.textUnitType = TextUnitTypeIMEmoji;
    unit.range = NSMakeRange(0, chineseEmotion.length);//范围为原始串范围即可
    
    //表情后面做强制遍历
    [self insertText:chineseEmotion withTextUnit:unit];
}

- (void)insertTopic:(NSString *)topicId topicName:(NSString *)topicName
{
    //直接调用TextView的方法
    TextUnit *unit = [[TextUnit alloc] init];
    unit.originalContent = topicName;  //输入框显示的串
    unit.transferredContent = [NSString stringWithFormat:@"{{%@|%@}}",topicName,topicId];         //发送时需要替换为的串
    unit.textUnitType = TextUnitTypeTopic;
    unit.range = NSMakeRange(0, topicName.length);//范围为原始串范围即可
    
    //表情后面做强制遍历
    [self insertText:topicName withTextUnit:unit];
}

//插入@体系,//{{@tx%@|%@}}
- (void)insertTx:(NSString *)snID systemName:(NSString *)systemName
{
    NSString *orginContent = [NSString stringWithFormat:@"@%@ ",systemName];
    //直接调用TextView的方法
    TextUnit *unit = [[TextUnit alloc] init];
    unit.originalContent = orginContent;  //输入框显示的串
    unit.transferredContent = [NSString stringWithFormat:@"{{@tx%@|%@}}",snID,systemName];         //发送时需要替换为的串
    unit.textUnitType = TextUnitTypeDepartment;
    unit.range = NSMakeRange(0, orginContent.length);//范围为原始串范围即可
    
    //表情后面做强制遍历
    [self insertText:orginContent withTextUnit:unit];

}

- (void)insertText:(NSString *)text withTextUnit:(TextUnit *)textUnit
{
    if (!_attributedString && textUnit)
    {
        _attributedString = [self attributedStringWithString:self.text];
    }

    NSUInteger index = self.selectedRange.location;
    
    [self insertText:text toAttributedStringAtIndex:index withTextUnit:textUnit];
    
    //同步更新输入框
    [super insertText:text];
}

- (void)insertText:(NSString *)text toAttributedStringAtIndex:(NSUInteger)index withTextUnit:(TextUnit *)textUnit
{
    //清空之前的特别输入（反向遍历）
    [_attributedString enumerateAttribute:@"kTextUnit" inRange:NSMakeRange(0, [_attributedString length]) options:NSAttributedStringEnumerationReverse usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value && [value isKindOfClass:[TextUnit class]])
        {
            NSRange valueRange = range;
            //新加内容在所有特殊内容之后
            if (NSMaxRange(valueRange) <= index)
            {
                *stop = YES;
                return;
            }
            //新加的内容在特殊串里
            if (index > valueRange.location && index < valueRange.location + valueRange.length)
            {
                [_attributedString removeAttribute:@"kTextUnit" range:valueRange];
                *stop = YES;
                return;
            }
        }
    }];
    
    NSMutableAttributedString *tmp = [self attributedStringWithString:text];
    if (textUnit)
    {
        [tmp addAttribute:@"kTextUnit" value:textUnit range:NSMakeRange(0, [tmp length])];
    }
    
    [_attributedString insertAttributedString:tmp atIndex:index];
}

- (void)updateSelectedRange
{
    if ([_attributedString length] == 0)
    {
        return;
    }
    
    __block NSRange deletedRange = self.selectedRange;
    if (deletedRange.length == 0)//没有选择范围下的退格键
    {
        //获取实际应该删除的范围
        [_attributedString enumerateAttribute:@"kTextUnit" inRange:NSMakeRange(0, [_attributedString length]) options:NSAttributedStringEnumerationReverse usingBlock:^(id value, NSRange range, BOOL *stop) {
            if (value && [value isKindOfClass:[TextUnit class]])
            {
                NSRange valueRange = range;
                //操作范围在特殊串最后，则无需遍历
                if (NSMaxRange(valueRange) < deletedRange.location)
                {
                    *stop = YES;
                    return;
                }
                //退格键在@张三 后，那么将整个@张三 删掉，这里设置删除范围
                if (NSMaxRange(deletedRange) == NSMaxRange(valueRange))
                {
                    deletedRange = valueRange;//把删除的范围改为unit的range
                    *stop = YES;
                    return;
                }
            }
        }];
    }
    
    self.selectedRange = deletedRange;
}

- (void)deleteAttributedStringInRange:(NSRange)range
{
    if ([_attributedString length] == 0)
    {
        return;
    }
    
    NSRange deletedRange = range;
    __block NSUInteger special = 0;
    //清空之前的特别输入
    [_attributedString enumerateAttribute:@"kTextUnit" inRange:NSMakeRange(0, [_attributedString length]) options:NSAttributedStringEnumerationReverse usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value && [value isKindOfClass:[TextUnit class]])
        {
            ++special;
            
            NSRange valueRange = range;
            //操作范围在特殊串最后，则无需遍历特殊属性
            if (NSMaxRange(valueRange) < deletedRange.location)
            {
                *stop = YES;
                return;
            }
            if (NSLocationInRange(deletedRange.location, valueRange) || NSLocationInRange(valueRange.location , deletedRange))
            {
                [_attributedString removeAttribute:@"kTextUnit" range:valueRange];
                --special;
            }
        }
    }];
    if (special == 0)
    {
        _attributedString = nil;//无需保留特殊串
    }
    else//清空实际部分
    {
        [_attributedString deleteCharactersInRange:deletedRange];
    }
}

//将属性串向普通字符串做匹配
- (void)makeAttributedStringToFitText
{
    NSString *oldText = [self attributedString];
    
    if ([oldText length] == 0 || [oldText isEqualToString:self.text])
    {
        return;
    }
    NSString *newText = self.text;
    //NSLog(@"%@--%@", [self.textView attributedString], self.textView.text);
    
    //编辑之前和之后，光标后面的内容一定不会改变，包括光标在最后的场景
    //取出光标后的共同串
    //取出共同的尾串
    NSString *suffixCommon = [newText substringFromIndex:self.selectedRange.location];
    
    //取出旧串的前串
    NSString *preOldText = [oldText substringToIndex:([oldText length] - [suffixCommon length])];
    //取出新串的前串
    NSString *preNewText = [newText substringToIndex:([newText length]-[suffixCommon length])];
    
    //获取上面2个前串的共同前串
    NSString *prefixCommon = [preNewText commonPrefixWithString:preOldText options:0];
    NSUInteger prefixCommonLength = [prefixCommon length];
    if ([preOldText length] > prefixCommonLength)
    {
        //删除旧串的中间部分
        [self deleteAttributedStringInRange:NSMakeRange(prefixCommonLength, [preOldText length] - prefixCommonLength)];
    }
    
    //将新串的中间部分插入到旧串
    if ([preNewText length] > prefixCommonLength)
    {
        [self insertText:[preNewText substringFromIndex:prefixCommonLength] toAttributedStringAtIndex:prefixCommonLength withTextUnit:nil];
    }
    
    //NSLog(@"%@--%@", [self.textView attributedString], self.textView.text);
}

- (NSString *)convertAttributedStringToNormalString
{
    if ([_attributedString length] == 0)
    {
        return nil;
    }
    //清空之前的特别输入
    [_attributedString enumerateAttribute:@"kTextUnit" inRange:NSMakeRange(0, [_attributedString length]) options:NSAttributedStringEnumerationReverse usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value && [value isKindOfClass:[TextUnit class]])
        {
            //表情无需特别转
            if ([(TextUnit *)value textUnitType] == TextUnitTypeSomeone || [(TextUnit *)value textUnitType] == TextUnitTypeTopic || [(TextUnit *)value textUnitType] == TextUnitTypeDepartment)
            {
                NSRange valueRange = range;
                
                //移除属性
                [_attributedString removeAttribute:@"kTextUnit" range:valueRange];
                //将原串替换
                [_attributedString replaceCharactersInRange:valueRange withString:[(TextUnit*)value transferredContent]];
            }
           
        }
    }];
    return [_attributedString string];
}

//将表情中文字符转换为符号
- (NSString *)convertToEmoji:(NSString *)sourceText
{
    NSMutableString *dest = [NSMutableString stringWithFormat:@"%@", sourceText];
    
    NSArray *emotionKeysArray = [self.characterEmotionDic allKeys];
    
    for (NSUInteger i = 0; i < [emotionKeysArray count]; i++)
    {
        NSString *emotionKeyStr = [emotionKeysArray objectAtIndex:i];
        
        NSRange range = [dest rangeOfString:emotionKeyStr];
        while (range.location != NSNotFound)//替换所有出现的此表情中文符
        {
            [dest replaceCharactersInRange:range withString:[self.characterEmotionDic objectForKey:emotionKeyStr]];
            range = [dest rangeOfString:emotionKeyStr];
        }
    }
    return dest;
}

//分割
- (NSArray *)componentsSeparatedByVery2000:(NSString *)sourceText
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
    if ([sourceText length] <= MessageMaxLength)
    {
        [array addObject:sourceText];
        return array;
    }
    
    //按规则截取
    NSRegularExpression *regular = nil;
    if ([[self attributedString] length] > 0)
    {
        NSError *error = nil;
        
        NSString *regularStr = IM_AT_FORMAT;
        regular = [NSRegularExpression regularExpressionWithPattern:regularStr options:NSRegularExpressionCaseInsensitive error:&error];
        if (error)
        {
            regular = nil;
        }
    }
    
    NSUInteger specialMaxLength = 10;//表情串最大长度
    if (regular)
    {
        specialMaxLength = 50;//暂定如此，@串最大长度
    }
    //匹配表情
    NSArray *allEmojis = nil;
    
    __block NSRange borderRange;
    NSString *borderString = nil;
    //长度大于最大限制，继续切割
    while ([sourceText length] > MessageMaxLength)
    {
        if ([sourceText length] > MessageMaxLength+specialMaxLength)
        {
            borderRange = NSMakeRange(MessageMaxLength-specialMaxLength, specialMaxLength + specialMaxLength);
        }
        else
        {
            borderRange = NSMakeRange(MessageMaxLength-specialMaxLength, specialMaxLength + [sourceText length]-MessageMaxLength);
        }
        borderString = [sourceText substringWithRange:borderRange];
        __block BOOL foundSpecail = NO;
        if (regular)
        {
            [regular enumerateMatchesInString:borderString options:0 range:NSMakeRange(0, [borderString length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop){
                
                //找出临界点
                if (result.range.location < specialMaxLength && NSMaxRange(result.range) >= specialMaxLength)
                {
                    borderRange = NSMakeRange(0, MessageMaxLength-specialMaxLength+NSMaxRange(result.range));
                    foundSpecail = YES;
                    *stop = YES;
                }
            }];
        }
        if (foundSpecail)
        {
            [array addObject:[sourceText substringToIndex:borderRange.length]];
            sourceText = [sourceText substringFromIndex:borderRange.length];
            continue;
        }
        if (!allEmojis)
        {
            allEmojis = [self.chineseEmotionDic allKeys];
        }
        
        for (NSString *emoji in allEmojis)
        {
            NSRange emojiRange = [borderString rangeOfString:emoji];
            if (emojiRange.length == 0)
            {
                continue;
            }
            //已经遍历到了临界后的位置
            if (emojiRange.location >= specialMaxLength)
            {
                break;
            }
            //找出临界点
            if (emojiRange.location < specialMaxLength && NSMaxRange(emojiRange) >= specialMaxLength)
            {
                borderRange = NSMakeRange(0, MessageMaxLength-specialMaxLength+NSMaxRange(emojiRange));
                foundSpecail = YES;
                break;
            }
        }
        if (!foundSpecail)
        {
            //边界处理
            NSRange checkRange = [sourceText rangeOfComposedCharacterSequenceAtIndex:MessageMaxLength];
            if (checkRange.length > 1)
            {
                borderRange = NSMakeRange(0, NSMaxRange(checkRange));
            }
            else
            {
                borderRange = NSMakeRange(0, MessageMaxLength);
            }
        }
        [array addObject:[sourceText substringToIndex:borderRange.length]];
        sourceText = [sourceText substringFromIndex:borderRange.length];
    }
    if ([sourceText length] > 0)
    {
        [array addObject:sourceText];
    }
    return array;
}

- (NSString *)attributedString
{
    return [_attributedString string];
}

- (void)clearAttributedString
{
    _attributedString = nil;
}

+ (DYLanguageType)systemLanguage;
{
    /*得到本机现在用的语言
     en:英文
     zh-Hans:简体中文
     zh-Hant:繁体中文
     zh-HK:繁体中文-香港
     zh-HK:繁体中文-台湾
     ja:日本
     */
    NSArray* languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages firstObject];
    
    if ([preferredLang hasPrefix:@"zh-Hans"]) {
        return DYLanguageTypeChinese;
    } else if ([preferredLang hasPrefix:@"en"]) {
        return DYLanguageTypeEnglish;

    } else if ([preferredLang hasPrefix:@"ja"]) {
        return DYLanguageTypeJapanese;

    } else if ([preferredLang hasPrefix:@"zh-Hant"] ||
               [preferredLang hasPrefix:@"zh-HK"] ||
               [preferredLang hasPrefix:@"zh-TW"]) {
        return DYLanguageTypeChineseTraditional;

    } else {
        return DYLanguageTypeChinese;
    }
}

- (NSDictionary *)chineseEmotionDic
{
    if (!_chineseEmotionDic)
    {
        NSString *fileNameWithoutType = @"Emtion1";
        DYLanguageType sysLanguage = [IMTextView systemLanguage];
        switch (sysLanguage) {
            case DYLanguageTypeChinese:
                fileNameWithoutType = @"Emtion1";
                break;
            case DYLanguageTypeEnglish:
                fileNameWithoutType = @"Emtion1";//Emtion1_en
                break;
            case DYLanguageTypeJapanese:
                fileNameWithoutType = @"Emtion1";//Emtion1_ja
                break;
            case DYLanguageTypeChineseTraditional:
                fileNameWithoutType = @"Emtion1_cnt";
                break;
        }
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileNameWithoutType ofType:@"plist"];
        _chineseEmotionDic = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    }
    return _chineseEmotionDic;
}

- (NSDictionary *)characterEmotionDic
{
    if (!_characterEmotionDic)
    {
        NSString *fileNameWithoutType = @"Emtion2";
        DYLanguageType sysLanguage = [IMTextView systemLanguage];
        switch (sysLanguage) {
            case DYLanguageTypeChinese:
                fileNameWithoutType = @"Emtion2";
                break;
            case DYLanguageTypeEnglish:
                fileNameWithoutType = @"Emtion2";//Emtion2_en
                break;
            case DYLanguageTypeJapanese:
                fileNameWithoutType = @"Emtion2";//Emtion2_ja
                break;
            case DYLanguageTypeChineseTraditional:
                fileNameWithoutType = @"Emtion2_cnt";
                break;
        }
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileNameWithoutType ofType:@"plist"];
        _characterEmotionDic = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    }
    return _characterEmotionDic;
}

//产生一个普通的属性串
- (NSMutableAttributedString *)attributedStringWithString:(NSString *)str
{
    return [[NSMutableAttributedString alloc] initWithString:str];
}

@end
