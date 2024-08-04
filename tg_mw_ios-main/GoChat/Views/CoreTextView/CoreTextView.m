//
//  CoreTextView.m
//

#import "CoreTextView.h"
#import <CoreText/CoreText.h>
#import "FLAnimatedImage.h"
#import "FileCache.h"

NSString *const kCoreTextViewAttributedTextSize = @"kCoreTextViewAttributedTextSize";
CGFloat const CoreTextViewDefaultEmojiWidthAndHeight = 48.0;//默认表情大小
CGFloat const CoreTextViewDefaultImageWidthAndHeight = 125.0;//默认图片大小
CGFloat const CoreTextViewDefaultFontSize = 17.0;//默认字体大小（UILabel默认字体大小）
CGFloat const CoreTextViewDefaultLineSpacing = 4;

static NSDictionary *EmojisDic = nil;

#pragma mark - CTRun的回调
//这几个回调针对自定义表情、图片的绘制
//CTRun的回调，销毁内存的回调
void RunDelegateDeallocCallback(void *refObject)
{
    refObject = nil;
}

#pragma mark - 表情的CTRun的回调
//CTRun的回调，获取高度
CGFloat RunDelegateGetEmojiAscentCallback(void *refObject)
{
    CoreTextView *coreTextView = (__bridge CoreTextView *)refObject;
    
    CGFloat fontHeight = coreTextView.textFont.ascender + fabs(coreTextView.textFont.descender);
    
    return roundf(coreTextView.textFont.ascender / fontHeight * coreTextView.emojiWidthAndHeight);
}

CGFloat RunDelegateGetEmojiDescentCallback(void *refObject)
{
    CoreTextView *coreTextView = (__bridge CoreTextView *)refObject;
    
    CGFloat fontHeight = coreTextView.textFont.ascender + fabs(coreTextView.textFont.descender);
    
    return roundf(fabs(coreTextView.textFont.descender) / fontHeight * coreTextView.emojiWidthAndHeight);
}

//CTRun的回调，获取宽度
CGFloat RunDelegateGetEmojiWidthCallback(void *refObject)
{
    CoreTextView *coreTextView = (__bridge CoreTextView *)refObject;
    
    return coreTextView.emojiWidthAndHeight;
}

#pragma mark - 图片的CTRun的回调
//CTRun的回调，获取高度
CGFloat RunDelegateGetImageAscentCallback(void *refObject)
{
    CoreTextView *coreTextView = (__bridge CoreTextView *)refObject;
    
    CGFloat fontHeight = coreTextView.textFont.ascender + fabs(coreTextView.textFont.descender);
    
    return roundf(coreTextView.textFont.ascender / fontHeight * coreTextView.imageWidthAndHeight);
}

CGFloat RunDelegateGetImageDescentCallback(void *refObject)
{
    CoreTextView *coreTextView = (__bridge CoreTextView *)refObject;
    
    CGFloat fontHeight = coreTextView.textFont.ascender + fabs(coreTextView.textFont.descender);
    
    return roundf(fabs(coreTextView.textFont.descender) / fontHeight * coreTextView.imageWidthAndHeight);
}

//CTRun的回调，获取宽度
CGFloat RunDelegateGetImageWidthCallback(void *refObject)
{
    CoreTextView *coreTextView = (__bridge CoreTextView *)refObject;
    
    return coreTextView.imageWidthAndHeight;
}

/*----------------------------------------------------------------------------*/
#pragma mark - CoreTextView

@interface CoreTextView()

@property (nonatomic, strong) NSMutableArray *specialTextArray;//存储特殊含义字段

@property (nonatomic, strong) NSMutableAttributedString *attributedString;//待绘制文本
@property (nonatomic, strong) NSMutableString *originalText; //待显示的消息体的原始文本

@property (nonatomic, strong) NSMutableAttributedString *ellipsesAttributedString;//省略号

@property (nonatomic, assign) CGFloat lineSpacing;

@property (nonatomic, strong, readwrite) TextUnit *selectedTextUnit;

@property (nonatomic) CTFramesetterRef framesetterRef;

@property (nonatomic) BOOL need;

+ (void)initializeEmojisDic;

@end


@implementation CoreTextView

+ (void)initializeEmojisDic;
{
    if (EmojisDic == nil)
    {
        NSMutableDictionary *tmpEmojisDic = [NSMutableDictionary dictionaryWithCapacity:250];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Emotcion" ofType:@"plist"];
        NSArray * tmpEmojisArray = [NSArray arrayWithContentsOfFile:path];
        for (NSDictionary *singleEmojisDic in tmpEmojisArray) {
            [tmpEmojisDic addEntriesFromDictionary:singleEmojisDic];
        }
        EmojisDic = [tmpEmojisDic copy];
    }
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(touchesOver) object:nil];
    [self releaseCFType:_framesetterRef];
    //NSLog(@"CoreTextView Dealloc");
}

- (void)releaseCFType:(CFTypeRef)typeRef
{
    if (typeRef)
    {
        CFRelease(typeRef);
    }
}

- (id)initWithFrame:(CGRect)frame
{
    [CoreTextView initializeEmojisDic];

    self = [super initWithFrame:frame];
    if (self)
    {
        self.maxWidth = frame.size.width;
        self.text = nil;
        self.textColor = HEX_COLOR(@"#333333");
        self.numberOfLines = 0;
        _textFont = [UIFont systemFontOfSize:CoreTextViewDefaultFontSize];//
        self.analyzeType = AnalyzeTypeNone;
        self.specialTextArray = [NSMutableArray array];
        self.emojiWidthAndHeight = CoreTextViewDefaultEmojiWidthAndHeight;
        self.imageWidthAndHeight = CoreTextViewDefaultImageWidthAndHeight;
        self.lineSpacing = CoreTextViewDefaultLineSpacing;
        self.backgroundColor = [UIColor clearColor];
        self.linkColor = [UIColor colorMain];
    }
    return self;
}

- (void)setFramesetterRef:(CTFramesetterRef)framesetterRef
{
    if (_framesetterRef == framesetterRef)
    {
        return;
    }
    [self willChangeValueForKey:@"framesetterRef"];
    
    [self releaseCFType:_framesetterRef];
    
    if (framesetterRef)
    {
        _framesetterRef = CFRetain(framesetterRef);
    }
    [self didChangeValueForKey:@"framesetterRef"];
}

- (void)setTextFont:(UIFont *)textFont
{
    if (textFont == nil)
    {
        return;
    }
    if (textFont == _textFont)
    {
        return;
    }
    [self willChangeValueForKey:@"textFont"];
    _textFont = textFont;
    [self didChangeValueForKey:@"textFont"];
    //相应更新表情大小
    self.emojiWidthAndHeight = CoreTextViewDefaultEmojiWidthAndHeight/CoreTextViewDefaultFontSize*textFont.pointSize;
}

#pragma mark - 分析
//真正分析过程
- (void)startAnalyze
{
    self.need = NO;
    if ([self.text length] == 0)
    {
        return;
    }
    self.originalText = [self.text mutableCopy];//msginfo  中解析出需要显示的字符串
    self.attributedString = [[NSMutableAttributedString alloc] initWithString:self.originalText];
    self.ellipsesAttributedString = [[NSMutableAttributedString alloc] initWithString:@"\u2026"];//...ellipsis character (U+2026)
    
    //根据实际情况analyzeType，进行分析
    if ((self.analyzeType&AnalyzeTypeImage))
    {
        [self parseImage];
    }
    if ((self.analyzeType&AnalyzeTypeEmoji))
    {
        [self parseEmoji];
    }
    if ((self.analyzeType&AnalyzeTypeURL))
    {
        [self parseURLWithSample:NO];
    }
    if (self.analyzeType&AnalyzeTypeEmail)
    {
        [self parseEmail];
    }
    if ((self.analyzeType&AnalyzeTypePhoneNumber))
    {
        [self parsePhoneNumber];
    }
    if ((self.analyzeType&AnalyzeTypeSomeone))
    {
        [self parseSomeone];
    }
    if ((self.analyzeType&AnalyzeTypeTopic))
    {
        [self parseTopic];
    }
    if ((self.analyzeType&AnalyzeTypeDepartment))
    {
        [self parseDepartment];
    }
    if ((self.analyzeType&AnalyzeTypeRetryInvite))
    {
        [self parseRetryInvite];
    }
    if ((self.analyzeType&AnalyzeTypeAutoReply))
    {
        [self parseRejectAutoReply];
    }
    if ((self.analyzeType&AnalyzeTypeName))
    {
        [self parseName];
    }
    if ((self.analyzeType&AnalyzeTypeURLSample)) {
        [self parseURLWithSample:YES];
    }
    if ((self.analyzeType&AnalyzeTypekKfcQuitQueue))
    {
        [self parseKfcQuitQueue];
    }
    if ((self.analyzeType&AnalyzeTypekKfcAppraise))
    {
        [self parseKfcKfcAppraise];
    }
    if ((self.analyzeType&AnalyzeTypeRPPrompt))
    {
        [self parseRPPrompt];
    }
    if ((self.analyzeType&AnalyzeTypeTransferRemind)) {
        [self parseTransfer];
    }
    //根据需要增设其他解析
    
    self.originalText = nil;//解析完后，置空，释放内存
    //构建
    [self buildAttribute];
    
    //调整
    [self adjustAttributedString];
    
}

#pragma mark
#pragma mark 解析
//解析表情，需要优化
/* EmojisArray数据结构:
    @[
        @{@"/:w", @"snim_small_a001_smile@2x.gif", nil},
        @{@"", @"", nil},
        ...
    ]
 */
//250种表情
- (void)parseEmoji
{
    //如果消息没有表情代码,则跳过
    if ([self.originalText rangeOfString:@"/:"].location == NSNotFound) {
        return;
    }
    
    NSArray *keys = [EmojisDic allKeys];
    for (NSUInteger i = 0; i < keys.count; i++) {
        NSString *emoji = keys[i];
        NSRange range = [self.originalText rangeOfString:emoji];
        
        if (range.location != NSNotFound)
        {
            //处理多个相同的表情
            i--;
            
            TextUnit *unit = [[TextUnit alloc] init];
            unit.originalContent = emoji;//表情串
            unit.transferredContent = EmojisDic[emoji];//图片名称
            unit.textUnitType = TextUnitTypeIMEmoji;
            unit.range = range;
            unit.textColor = self.backgroundColor;
            [self.specialTextArray addObject:unit];
            unit = nil;
            
            //添加占位符
            char spaces[range.length+1];
            memset(spaces, ' ', range.length);
            spaces[range.length] = '\0';
            
            NSString *replaceString = [NSString stringWithFormat:@"%s", spaces];
            [self.originalText replaceCharactersInRange:range withString:replaceString];
            replaceString = nil;
            
            NSString *name = [unit.transferredContent stringByDeletingPathExtension];
            //提前异步缓存gif表情
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
                FLAnimatedImage * gifImage = [[FileCache sharedCache] fileFromMemoryCacheForKey:name];
                if (!gifImage && path) {
                    NSData *data = [NSData dataWithContentsOfFile:path];
                    gifImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
                    [[FileCache sharedCache] storeFile:gifImage forKey:name];
                }
            });
        }
    }
}

//解析链接地址
- (void)parseURLWithSample:(BOOL)isSample
{
    NSError *error = nil;
    
    NSString *urlHead = @"(http[s]{0,1})://";
    NSString *url = @"[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?";

    //NSString *ip = @"(((\\d{1,2})|(1\\d{2,2})|(2[0-4][0-9])|(25[0-5]))\\.){3,3}((\\d{1,2})|(1\\d{2,2})|(2[0-4][0-9])|(25[0-5]))";
    
    NSString *regularStr = [NSString stringWithFormat:@"%@%@|%@", urlHead, url, url];
    
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regularStr options:NSRegularExpressionCaseInsensitive error:&error];
    if (error)
    {
        return;
    }
    NSArray *arrayOfAllMatches = [regular matchesInString:self.originalText options:0 range:NSMakeRange(0, [self.originalText length])];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        NSString* substringForMatch = [self.originalText substringWithRange:match.range];
        NSURL *testURL = [NSURL URLWithString:substringForMatch];
        BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:testURL];
        if (NO == canOpen)
        {
            testURL = [NSURL URLWithString:[@"http://" stringByAppendingString:substringForMatch]];
            canOpen = [[UIApplication sharedApplication] canOpenURL:testURL];
        }
        if (NO == canOpen)
        {
            testURL = [NSURL URLWithString:[@"https://" stringByAppendingString:substringForMatch]];
        }
        //如果是系统浏览器无法打开的，则不认为是有效的url
        if (NO == canOpen)
        {
            continue;
        }
        
        TextUnit *unit = [[TextUnit alloc] init];
        unit.range = match.range;
        
        unit.originalContent = [self.originalText substringWithRange:match.range];
        if (isSample) {
            unit.transferredContent = @"网页链接".lv_localized;
            unit.textUnitType = TextUnitTypeURLSample;
        }else{
            unit.transferredContent = testURL.absoluteString;
            unit.textUnitType = TextUnitTypeURL;
        }
        unit.textColor = self.linkColor;
        unit.underline = NO;
        [self.specialTextArray addObject:unit];
        unit = nil;
    }
}

//解析email(该方法暂时不对)
//FIXME:无法解析出Email地址
- (void)parseEmail
{
    NSError *error = nil;
    NSString *regularStr = @"\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*";
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regularStr options:NSRegularExpressionCaseInsensitive error:&error];
    if (error)
    {
        return;
    }
    NSArray *arrayOfAllMatches = [regular matchesInString:self.originalText options:0 range:NSMakeRange(0, [self.originalText length])];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        TextUnit *unit = [[TextUnit alloc] init];
        unit.range = match.range;
        unit.textUnitType = TextUnitTypeEmail;
        unit.originalContent = [self.originalText substringWithRange:match.range];
        unit.transferredContent = unit.originalContent;
        unit.textColor = self.linkColor;
        unit.underline = NO;
        [self.specialTextArray addObject:unit];
        unit = nil;
    }
}
//解析电话号码
- (void)parsePhoneNumber
{
    NSError *error = nil;
    NSString *regularStr = @"[+]{0,1}[0-9]{7,23}";
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regularStr options:NSRegularExpressionCaseInsensitive error:&error];
    if (error)
    {
        return;
    }
    NSArray *arrayOfAllMatches = [regular matchesInString:self.originalText options:0 range:NSMakeRange(0, [self.originalText length])];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        TextUnit *unit = [[TextUnit alloc] init];
        unit.range = match.range;
        unit.textUnitType = TextUnitTypePhoneNumber;
        unit.originalContent = [self.originalText substringWithRange:match.range];
        unit.transferredContent = unit.originalContent;
        unit.textColor = self.linkColor;
        unit.underline = NO;
        [self.specialTextArray addObject:unit];
        unit = nil;
    }
}
//解析@某人
//{{@sn13080550|吉长安}}或者管理员{{@6005626532|管理员}}或者{{@all|全体成员}}
- (void)parseSomeone
{
    NSArray *entitiesArr = [self.msginfo.content.text objectForKey:@"entities"];
    if (entitiesArr && entitiesArr.count > 0) {
        for (NSDictionary *itemdic in entitiesArr) {
            NSDictionary *dicLim = [itemdic objectForKey:@"type"];
            if (dicLim) {
                long idlin = [[dicLim objectForKey:@"user_id"] longValue];
                UserInfo *user = [[TelegramManager shareInstance] contactInfo:idlin];
                if (user) {
//                    NSRange range = [CZCommonTool getRangeFromString:self.originalText withString:user.displayName];
//                    NSRange range = NSMakeRange([[itemdic objectForKey:@"offset"] integerValue], [[itemdic objectForKey:@"length"] integerValue]);
                    NSInteger offset = [[itemdic objectForKey:@"offset"] integerValue];
                    NSInteger length = [[itemdic objectForKey:@"length"] integerValue];
                    if (offset > 1) {
                        NSString *originalText = [self.msginfo.content.text objectForKey:@"text"];
                        NSString *sub = [originalText substringWithRange:NSMakeRange(offset - 2, 2)];
                        if ([sub caseInsensitiveCompare:@"dm"] == NSOrderedSame) {
                            offset -= 2;
                            length += 2;
                        }
                    }
                    
                    
                    NSRange range = NSMakeRange(offset, length);
                    TextUnit *unit = [[TextUnit alloc] init];
                    unit.range = range;
                    unit.textUnitType = TextUnitTypeSomeone;
                    unit.originalContent = [self.originalText substringWithRange:range];
                    unit.transferredContent = unit.originalContent;
                    
                    //实际名称
                    if ([unit.transferredContent length] > 0)
                    {
                        [unit.userInfo setObject:unit.transferredContent forKey:TextUnitUserInfoSomeoneName];
                    }
                    unit.selUserInfo = user;
                    unit.textColor = self.linkColor;
                    [self.specialTextArray addObject:unit];
                    unit = nil;
                }
            }
        }
    }
}

//解析图片{@img}，实现图文混排
- (void)parseImage
{
    //如果消息没有图片,则跳过
    if ([self.originalText rangeOfString:@"{@img}"].location == NSNotFound) {
        return;
    }
    
    NSError *error = nil;
    NSString *regularStr = IM_IMG_FORMAT;
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regularStr options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        return;
    }
    
    NSArray *allMatches = [regular matchesInString:self.originalText options:0 range:NSMakeRange(0, [self.originalText length])];
    
    [allMatches enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop)
    {
        TextUnit *unit = [[TextUnit alloc] init];
        unit.range = match.range;
        unit.textUnitType = TextUnitTypeImage;
        unit.originalContent = [self.originalText substringWithRange:match.range];
        
        NSString *imageId = idx < self.imageIds.count ? self.imageIds[idx] : nil;
        NSString *imagePath = idx < self.imagePaths.count ? self.imagePaths[idx] : nil;
        unit.transferredImageId = imageId;
        unit.transferredImagePath = imagePath;
        
        unit.textColor = self.backgroundColor;
        [self.specialTextArray addObject:unit];
        unit = nil;
        
        //添加占位符
        char spaces[match.range.length+1];
        memset(spaces, ' ', match.range.length);
        spaces[match.range.length] = '\0';
        
        NSString *replaceString = [NSString stringWithFormat:@"%s", spaces];
        [self.originalText replaceCharactersInRange:match.range withString:replaceString];
        replaceString = nil;
    }];
}

//解析好友动态相关的@体系
//{{@tx体系号|名称}}
- (void)parseDepartment
{
    NSError *error = nil;
    NSString *regularStr = TX_AT_FORMAT;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularStr options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *arrayOfAllMatches = [regex matchesInString:self.originalText options:0 range:NSMakeRange(0, [self.originalText length])];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        TextUnit *unit = [[TextUnit alloc] init];
        unit.range = match.range;
        unit.textUnitType = TextUnitTypeDepartment;
        unit.originalContent = [self.originalText substringWithRange:match.range];
        NSUInteger left = [unit.originalContent rangeOfString:@"|"].location;
        NSUInteger right = [unit.originalContent rangeOfString:@"}"].location;
        //如果没有名称则拿部门号
        if (right == NSNotFound || left == NSNotFound || right - left <= 1)
        {
            left = [unit.originalContent rangeOfString:@"tx"].location;
            right = [unit.originalContent rangeOfString:@"|"].location;
        }
        unit.transferredContent = [unit.originalContent substringWithRange:NSMakeRange(left+1, right - (left+1))];
        //实际名称
        if ([unit.transferredContent length] > 0)
        {
            [unit.userInfo setObject:unit.transferredContent forKey:TextUnitUserInfoDepartmentName];
        }
        //@名字
        unit.transferredContent = [@"@" stringByAppendingString:unit.transferredContent];
        //取出工号
        left = [unit.originalContent rangeOfString:@"tx"].location;
        right = [unit.originalContent rangeOfString:@"|"].location;
        NSString *snID = [unit.originalContent substringWithRange:NSMakeRange(left, right - left)];
        [unit.userInfo setObject:snID forKey:TextUnitUserInfoDepartmentID];
        unit.textColor = self.linkColor;
        [self.specialTextArray addObject:unit];
        unit = nil;
    }
}

//解析话题
//{{#轻松一刻#|3104}}
- (void)parseTopic
{
    NSError *error = nil;
    NSString *regularStr = TOPIC_FORMAT;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularStr options:NSRegularExpressionCaseInsensitive error:&error];
    if (error)
    {
        return;
    }
    NSArray *arrayOfAllMatches = [regex matchesInString:self.originalText options:0 range:NSMakeRange(0, [self.originalText length])];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        TextUnit *unit = [[TextUnit alloc] init];
        unit.range = match.range;
        unit.textUnitType = TextUnitTypeTopic;
        unit.originalContent = [self.originalText substringWithRange:match.range];
        NSUInteger left = [unit.originalContent rangeOfString:@"#"].location;
        NSUInteger right = [unit.originalContent rangeOfString:@"#" options:NSBackwardsSearch].location;
        //话题名称##样式
        unit.transferredContent = [unit.originalContent substringWithRange:NSMakeRange(left, right - left + 1)];
        //实际名称
        NSString *subjectName = [unit.transferredContent substringWithRange:NSMakeRange(1, [unit.transferredContent length] - 2)];
        if ([subjectName length] > 0)
        {
            [unit.userInfo setObject:subjectName forKey:TextUnitUserInfoTopicName];
        }
        //话题id
        left = [unit.originalContent rangeOfString:@"|"].location;
        right = [unit.originalContent rangeOfString:@"}"].location;
        NSString *subjectID = [unit.originalContent substringWithRange:NSMakeRange(left+1, right - (left+1))];
        if ([subjectID length] > 0)
        {
            [unit.userInfo setObject:subjectID forKey:TextUnitUserInfoTopicID];
        }
        
        unit.textColor = self.linkColor;
        [self.specialTextArray addObject:unit];
        unit = nil;
    }
}

//解析讨论组邀请失败的点击重试
- (void)parseRetryInvite
{
    NSRange range = [self.originalText rangeOfString:@"点击重试".lv_localized];
    if (range.length>0)
    {
        TextUnit *unit = [[TextUnit alloc] init];
        unit.originalContent = @"点击重试".lv_localized;
        unit.transferredContent = @"点击重试".lv_localized;
        unit.textUnitType = TextUnitTypeRetryInvite;
        unit.textColor = self.linkColor;
        unit.range = range;
        [self.specialTextArray addObject:unit];
    }
}

//解析自动回复的报文
- (void)parseRejectAutoReply
{
    /*
    NSString *keyword = @"##RejectAutoReply##";
    
    NSUInteger length = [keyword length];
    
    NSRange range = [self.originalText rangeOfString:keyword options:NSBackwardsSearch range:NSMakeRange([self.originalText length] - length, length)];
    if (range.length>0)
    {
        TextUnit *unit = [[TextUnit alloc] init];
        unit.originalContent = keyword;
        unit.transferredContent = @"[点击此处,不再提醒]";
        unit.textUnitType = TextUnitTypeAutoReply;
        unit.textColor = self.linkColor;
        unit.range = range;
        [self.specialTextArray addObject:unit];
    }
     */
}
//{{#sn13080550|张三}}或者管理员{{#6005626532|管理员}}
- (void)parseName
{
    NSError *error = nil;
    //FIXME:UID以后的格式可能不固定
    NSString *regularStr = CLUB_AT_FORMAT;

    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regularStr options:NSRegularExpressionCaseInsensitive error:&error];
    if (error)
    {
        return;
    }
    NSArray *arrayOfAllMatches = [regular matchesInString:self.originalText options:0 range:NSMakeRange(0, [self.originalText length])];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        TextUnit *unit = [[TextUnit alloc] init];
        unit.range = match.range;
        unit.textUnitType = TextUnitTypeName;
        unit.originalContent = [self.originalText substringWithRange:match.range];
        
        //获取名字
        NSUInteger left = [unit.originalContent rangeOfString:@"|"].location;
        NSUInteger right = [unit.originalContent rangeOfString:@"}"].location;
        //如果没有名字则#后部分
        if (right - left <= 1)
        {
            right = left;
            left = [unit.originalContent rangeOfString:@"#"].location;
            left += [@"#" length];
        }
        else
        {
            left += [@"|" length];
        }
        unit.transferredContent = [unit.originalContent substringWithRange:NSMakeRange(left, right - left)];
        
        //实际名称
        if ([unit.transferredContent length] > 0)
        {
            [unit.userInfo setObject:unit.transferredContent forKey:TextUnitUserInfoSomeoneName];
        }
        
        
        //取出sn工号
        left = [unit.originalContent rangeOfString:@"#"].location;
        left += [@"#" length];//右移一位
        
        right = [unit.originalContent rangeOfString:@"|"].location;
        NSString *realID = [unit.originalContent substringWithRange:NSMakeRange(left, right - left)];
        [unit.userInfo setObject:realID forKey:TextUnitUserInfoSomeoneID];
        unit.textColor = self.linkColor;
        [self.specialTextArray addObject:unit];
        unit = nil;
    }
}

//解析讨论组邀请失败的点击重试
- (void)parseKfcQuitQueue
{
    NSRange range = [self.originalText rangeOfString:@"结束排队".lv_localized];
    if (range.length>0)
    {
        TextUnit *unit = [[TextUnit alloc] init];
        unit.originalContent = @"结束排队".lv_localized;
        unit.transferredContent = @"结束排队".lv_localized;
        unit.textUnitType = TextUnitTypeKfcQuitQueue;
        unit.textColor = self.linkColor;
        unit.range = range;
        [self.specialTextArray addObject:unit];
    }
}

//解析讨论组邀请失败的点击重试
- (void)parseKfcKfcAppraise
{
    NSRange range = [self.originalText rangeOfString:@"进行评价".lv_localized];
    if (range.length>0)
    {
        TextUnit *unit = [[TextUnit alloc] init];
        unit.originalContent = @"进行评价".lv_localized;
        unit.transferredContent = @"进行评价".lv_localized;
        unit.textUnitType = TextUnitTypeKfcAppraise;
        unit.textColor = self.linkColor;
        unit.range = range;
        [self.specialTextArray addObject:unit];
    }
}

//解析RP领取消息
- (void)parseRPPrompt
{
    NSRange range = [self.originalText rangeOfString:@"红包".lv_localized];
    if (range.length>0)
    {
        TextUnit *unit = [[TextUnit alloc] init];
        unit.originalContent = @"红包".lv_localized;
        unit.transferredContent = @"红包".lv_localized;
        unit.textUnitType = TextUnitTypeRPPrompt;
        unit.textColor = RGBA(235, 81, 72, 1);
        unit.range = range;
        [self.specialTextArray addObject:unit];
    }
}


- (void)parseTransfer {
    NSRange range = [self.originalText rangeOfString:@"转账".lv_localized];
    if (range.length>0 && self.msginfo.transferInfo.remittanceId)
    {
        TextUnit *unit = [[TextUnit alloc] init];
        unit.originalContent = @"转账".lv_localized;
        unit.transferredContent = @"转账".lv_localized;
        unit.textUnitType = TextUnitTypeTransferRemind;
        unit.textColor = UIColor.colorMain;
        unit.range = range;
        [self.specialTextArray addObject:unit];
    }
}

#pragma mark
#pragma mark 解析完后，根据类别构建属性串
//构建属性传
- (void)buildAttribute
{
    //先设置文本一些基础属性
    [self setAttributedStringAttribute];
    
    //排序按range.location从小到大，便于后面反向遍历
    [self.specialTextArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if (((TextUnit*)obj1).range.location > ((TextUnit*)obj2).range.location)
        {
            return NSOrderedDescending;
        }
        else if (((TextUnit*)obj1).range.location < ((TextUnit*)obj2).range.location)
        {
            return NSOrderedAscending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];
    
    //倒序遍历
    for (NSUInteger i = [self.specialTextArray count]; i > 0; --i)
    {
        TextUnit *unit = [self.specialTextArray objectAtIndex:i-1];
        switch (unit.textUnitType)
        {
            case TextUnitTypeImage:
            {
                [self setImageUnitAttribute:unit];
                break;
            }
            case TextUnitTypeIMEmoji:
            {
                [self setEmojiUnitAttribute:unit];
                break;
            }
            case TextUnitTypeURL:
            {
                [self setURLUnitAttribute:unit];
                break;
            }
            case TextUnitTypeURLSample:
            {
                [self setURLUnitAttribute:unit];
                break;
            }
            case TextUnitTypeEmail:
            {
                [self setEmailUnitAttribute:unit];
                break;
            }
            case TextUnitTypePhoneNumber:
            {
                [self setPhoneNumberUnitAttribute:unit];
                break;
            }
            case TextUnitTypeSomeone:
            {
                [self setSomeoneUnitAttribute:unit];
                break;
            }
            case TextUnitTypeTopic:
            {
                [self setTopicUnitAttribute:unit];
                break;
            }
            case TextUnitTypeDepartment:
            {
                [self setDepartmentUnitAttribute:unit];
                break;
            }
            case TextUnitTypeRetryInvite:
            {
                [self setRetryInviteUnitAttribute:unit];
                break;
            }
            case TextUnitTypeAutoReply:
            {
                [self setAutoReplyUnitAttribute:unit];
                break;
            }
            case TextUnitTypeName:
            {
                [self setNameUnitAttribute:unit];
                break;
            }
            case TextUnitTypeKfcQuitQueue:
            {
                [self setKfcQuitQueueUnitAttribute:unit];
                break;
            }
            case TextUnitTypeKfcAppraise:
            {
                [self setKfcAppraiseUnitAttribute:unit];
                break;
            }
            case TextUnitTypeRPPrompt:
            {
                [self setRPPromptUnitAttribute:unit];
                break;
            }
            case TextUnitTypeTransferRemind:
            {
                [self setSpecialUnitAttribute:unit];
                break;
            }
            default:
                break;
        }
    }
    
    //设置一下段落相关属性
    [self setAttributedStringParagraphStyle:self.attributedString lineBreakMode:kCTLineBreakByWordWrapping range:NSMakeRange(0, [self.attributedString length])];
}

#pragma mark - 属性设置
//主要因为在限制行的条件下最后一行需要特殊处理
- (void)setAttributedStringParagraphStyle:(NSMutableAttributedString *)attributedString lineBreakMode:(CTLineBreakMode)lineBreakMode range:(NSRange)range
{
    //段落属性
    //换行模式
    CTParagraphStyleSetting lineBreakModeStyle;
    lineBreakModeStyle.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakModeStyle.value = &lineBreakMode;
    lineBreakModeStyle.valueSize = sizeof(CTLineBreakMode);
    //最小行间距
    CTParagraphStyleSetting minimumLineSpacingStyle;
    minimumLineSpacingStyle.spec = kCTParagraphStyleSpecifierMinimumLineSpacing;
    minimumLineSpacingStyle.value = &_lineSpacing;
    minimumLineSpacingStyle.valueSize = sizeof(CGFloat);
    //最大行间距
    CTParagraphStyleSetting maximumLineSpacingStyle;
    maximumLineSpacingStyle.spec = kCTParagraphStyleSpecifierMaximumLineSpacing;
    maximumLineSpacingStyle.value = &_lineSpacing;
    maximumLineSpacingStyle.valueSize = sizeof(CGFloat);
    
    CTParagraphStyleSetting settings[] = {lineBreakModeStyle,minimumLineSpacingStyle, maximumLineSpacingStyle};
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings, sizeof(settings)/sizeof(CTParagraphStyleSetting));
    
    [attributedString addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)(style) range:range];
    
    [self releaseCFType:style];
}

//属性串的一些参数
- (void)setAttributedStringAttribute
{
    //属性
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:2];
    
    //字体属性
    [attributes setObject:self.textFont forKey:(id)kCTFontAttributeName];
    
    //颜色属性
    [attributes setObject:self.textColor forKey:(id)kCTForegroundColorAttributeName];
    
    //整体属性串
    [self.attributedString addAttributes:attributes range:NSMakeRange(0, [self.attributedString length])];
    
    //...
    //设置一下省略号属性
    [self.ellipsesAttributedString addAttributes:attributes range:NSMakeRange(0, [self.ellipsesAttributedString length])];
}

//添加图片属性
//告诉Core Text 有一个地方需要占多大的位置，这样系统就会在指定的地方把空间腾出来，不绘制文字上去。
- (void)setImageUnitAttribute:(TextUnit *)unit
{
    //设置CTRun的回调，用于针对需要被替换成图片的位置的字符，可以动态设置图片预留位置的宽高
    CTRunDelegateCallbacks imImageCallbacks;
    imImageCallbacks.version = kCTRunDelegateCurrentVersion;
    imImageCallbacks.dealloc = RunDelegateDeallocCallback;
    //字形宽度、向上高度和向下高度
    imImageCallbacks.getWidth = RunDelegateGetImageWidthCallback;
    imImageCallbacks.getAscent = RunDelegateGetImageAscentCallback;
    imImageCallbacks.getDescent = RunDelegateGetImageDescentCallback;
    //创建CTRun回调
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imImageCallbacks, (__bridge void *)(self));
    
    //对需要显示图片的位置，用中文替换，中文默认相当于一个word，不会导致表情显示部分的问题
    NSMutableAttributedString *tmpAttributedString = [[NSMutableAttributedString alloc] initWithString:@"蛤"];
    
    NSRange tmpRange = NSMakeRange(0, [tmpAttributedString length]);
    
    [tmpAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:unit.textColor range:tmpRange];
    
    //设置图片预留字符使用CTRun回调
    [tmpAttributedString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:tmpRange];
    
    [self releaseCFType:runDelegate];
    
    //设置图片预留字符使用一个kTextUnit的属性，区别于其他字符
    [tmpAttributedString addAttribute:@"kTextUnit" value:unit range:tmpRange];
    
    //替换寻找表情时遗留的空格占位符
    [self.attributedString replaceCharactersInRange:unit.range withAttributedString:tmpAttributedString];
    tmpAttributedString = nil;
}

//添加表情属性
//告诉Core Text 有一个地方需要占多大的位置，这样系统就会在指定的地方把空间腾出来，不绘制文字上去。
- (void)setEmojiUnitAttribute:(TextUnit *)unit
{
    //设置CTRun的回调，用于针对需要被替换成图片的位置的字符，可以动态设置图片预留位置的宽高
    CTRunDelegateCallbacks imEmojiCallbacks;
    imEmojiCallbacks.version = kCTRunDelegateCurrentVersion;
    imEmojiCallbacks.dealloc = RunDelegateDeallocCallback;
    //字形宽度、向上高度和向下高度
    imEmojiCallbacks.getWidth = RunDelegateGetEmojiWidthCallback;
    imEmojiCallbacks.getAscent = RunDelegateGetEmojiAscentCallback;
    imEmojiCallbacks.getDescent = RunDelegateGetEmojiDescentCallback;
    //创建CTRun回调
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imEmojiCallbacks, (__bridge void *)(self));
    
    //对需要显示图片的位置，用中文替换，中文默认相当于一个word，不会导致表情显示部分的问题
    NSMutableAttributedString *tmpAttributedString = [[NSMutableAttributedString alloc] initWithString:@"我"];
    
    NSRange tmpRange = NSMakeRange(0, [tmpAttributedString length]);
    
    [tmpAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:unit.textColor range:tmpRange];
    
    //设置图片预留字符使用CTRun回调
    [tmpAttributedString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:tmpRange];
    
    [self releaseCFType:runDelegate];
    
    //设置图片预留字符使用一个kTextUnit的属性，区别于其他字符
    [tmpAttributedString addAttribute:@"kTextUnit" value:unit range:tmpRange];
    
    //替换寻找表情时遗留的空格占位符
    [self.attributedString replaceCharactersInRange:unit.range withAttributedString:tmpAttributedString];
    tmpAttributedString = nil;
}

//设置网址属性
- (void)setURLUnitAttribute:(TextUnit *)unit{
    [self setSpecialUnitAttribute:unit];
}

//设置邮件属性
- (void)setEmailUnitAttribute:(TextUnit *)unit{
    [self setSpecialUnitAttribute:unit];
}

//设置电话号码属性
- (void)setPhoneNumberUnitAttribute:(TextUnit *)unit{
    [self setSpecialUnitAttribute:unit];
}
//@某人
- (void)setSomeoneUnitAttribute:(TextUnit *)unit{
    [self setSpecialUnitAttribute:unit];
}

//@话题
- (void)setTopicUnitAttribute:(TextUnit *)unit{
    [self setSpecialUnitAttribute:unit];
}

//@部门
- (void)setDepartmentUnitAttribute:(TextUnit *)unit{
    [self setSpecialUnitAttribute:unit];
}

//点击重试
- (void)setRetryInviteUnitAttribute:(TextUnit *)unit{
    [self setSpecialUnitAttribute:unit];
}

//点击不再提醒
- (void)setAutoReplyUnitAttribute:(TextUnit *)unit{
    [self setSpecialUnitAttribute:unit];
}

- (void)setNameUnitAttribute:(TextUnit *)unit{
    [self setSpecialUnitAttribute:unit];
}

- (void)setKfcQuitQueueUnitAttribute:(TextUnit *)unit{
    [self setSpecialUnitAttribute:unit];
}

- (void)setKfcAppraiseUnitAttribute:(TextUnit *)unit{
    [self setSpecialUnitAttribute:unit];
}

- (void)setRPPromptUnitAttribute:(TextUnit *)unit{
    [self setSpecialUnitAttribute:unit];
}

//设置除了表情以外的字符
- (void)setSpecialUnitAttribute:(TextUnit *)unit
{
    NSMutableAttributedString *tmpAttributedString = [[NSMutableAttributedString alloc] initWithString:unit.transferredContent];
    
    if (unit.textUnitType == TextUnitTypeURL)
    {
        tmpAttributedString = [[NSMutableAttributedString alloc] initWithString:unit.originalContent];
    }
    NSRange tmpRange = NSMakeRange(0, [tmpAttributedString length]);
    
    //设置 预留字符使用一个kTextUnit的属性，区别于其他字符
    [tmpAttributedString addAttribute:@"kTextUnit" value:unit range:tmpRange];
    
    //颜色
    [tmpAttributedString addAttribute:(id)kCTForegroundColorAttributeName value:unit.textColor range:tmpRange];
    
    //字体
    [tmpAttributedString addAttribute:(id)kCTFontAttributeName value:self.textFont range:tmpRange];
    
    //下滑线
    if (unit.underline)
    {
        [tmpAttributedString addAttribute:(id)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:kCTUnderlineStyleSingle] range:tmpRange];
    }
    //
    if(unit.range.location+unit.range.length <= self.attributedString.length)
        [self.attributedString replaceCharactersInRange:unit.range withAttributedString:tmpAttributedString];
    tmpAttributedString = nil;
}

#pragma mark - 调整
//根据实际调整用于绘制的属性串，并得出实际绘制所需空间大小
- (void)adjustAttributedString
{
    BOOL hasAdjust = NO;
    CTFramesetterRef framesetterRef = NULL;
    //设置CTTypesetterRef
check:framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)(self.attributedString));
    if (framesetterRef == NULL)
    {
        return;
    }

    self.framesetterRef = framesetterRef;
    //不限制行数(一般到这里结束，例如聊天页不限制行数)
    if (self.numberOfLines == 0)
    {
        //获取实际需要大小
        CGSize size = [self sizeWith:framesetterRef];
        //添加上自定义的属性，即绘制时候所需size的大小，以便后面调整框框
        [self.attributedString addAttribute:kCoreTextViewAttributedTextSize value:[NSValue valueWithCGSize:size] range:NSMakeRange(0, [self.attributedString length])];
        
        [self releaseCFType:framesetterRef];
        
        return;
    }
    //以下是限制行数的计算方法
    //否则，计算实际行数
    CGMutablePathRef pathRef = CGPathCreateMutable();
    if (pathRef == NULL)
    {
        [self releaseCFType:framesetterRef];
        return;
    }
    
    CGRect bounds = CGRectMake(0.0, 0.0, floorf(self.maxWidth), CGFLOAT_MAX);
    CGPathAddRect(pathRef, NULL, bounds);
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, [self.attributedString length]), pathRef, NULL);
    if (frameRef == NULL)
    {
        [self releaseCFType:pathRef];
        [self releaseCFType:framesetterRef];
        return;
    }
    CFArrayRef lines = CTFrameGetLines(frameRef);
    //绘制行数不大于限制行，则可以直接用于绘制
    if (CFArrayGetCount(lines) <= self.numberOfLines)
    {
        //获取实际需要大小
        CGSize size = [self sizeWith:framesetterRef];
        
        //添加上自定义的属性，即绘制时候所需size的大小
        [self.attributedString addAttribute:kCoreTextViewAttributedTextSize value:[NSValue valueWithCGSize:size] range:NSMakeRange(0, [self.attributedString length])];
    
        [self releaseCFType:frameRef];
        [self releaseCFType:pathRef];
        [self releaseCFType:framesetterRef];
        return;
    }
    
    CTLineRef lastLineRef = CFArrayGetValueAtIndex(lines, self.numberOfLines-1);
    CFRange lastLineStringRange = CTLineGetStringRange(lastLineRef);
    
    if (hasAdjust == NO)//重设边界行及其以后串的换行模式为字符换行
    {
        [self setAttributedStringParagraphStyle:self.attributedString lineBreakMode:kCTLineBreakByCharWrapping range:NSMakeRange(lastLineStringRange.location, [self.attributedString length] - lastLineStringRange.location)];
        
        hasAdjust = YES;
        
        [self releaseCFType:frameRef];
        [self releaseCFType:pathRef];
        [self releaseCFType:framesetterRef];
        
        goto check;
    }
    else//如果已经尝试过调整边界行的换行属性，那么截断补...
    {
        _hasBreak = YES;
        //用省略号替换掉多余串
        NSRange replaceRange = NSMakeRange(lastLineStringRange.location + lastLineStringRange.length - 1, [self.attributedString length] - lastLineStringRange.location - lastLineStringRange.length+1);
        
        for (TextUnit *unit in self.specialTextArray) {
            if (unit.textUnitType == TextUnitTypeURLSample) {
                if ((unit.range.location<replaceRange.location)&&((unit.range.location+unit.range.length)>replaceRange.location)) {
                    replaceRange.length += (replaceRange.location-unit.range.location);
                    replaceRange.location = unit.range.location;
                }
            }
        }
        
        [self.attributedString replaceCharactersInRange:replaceRange withAttributedString:self.ellipsesAttributedString];
        
        [self setAttributedStringParagraphStyle:self.ellipsesAttributedString lineBreakMode:kCTLineBreakByCharWrapping range:NSMakeRange(0, [self.ellipsesAttributedString length])];
        
        [self releaseCFType:frameRef];
        [self releaseCFType:pathRef];
        [self releaseCFType:framesetterRef];
        
        //不符合指定行继续调整
        goto check;
    }
}

//
- (CGSize)sizeWith:(CTFramesetterRef)framesetterRef
{
    //获取实际需要大小
    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, 0), NULL, CGSizeMake(floorf(self.maxWidth), CGFLOAT_MAX), NULL);
    
    if (floorf(size.width) < size.width)
    {
        size.width = fminf(size.width+1, floorf(self.maxWidth));
    }
    if (floorf(size.height) < size.height)
    {
        size.height += 1;
    }
    return size;
}

- (void)adjustFrame
{
    NSRange effectiveRange = NSMakeRange(0, [self.attributedString length]);
    NSDictionary *attributes = [self.attributedString attributesAtIndex:0 effectiveRange:&effectiveRange];
    id object = [attributes objectForKey:kCoreTextViewAttributedTextSize];
    if (object && [object isKindOfClass:[NSValue class]])
    {
        CGRect frame = self.frame;
        frame.size = [object CGSizeValue];
        self.frame = frame;
    }
}

//绘制
- (void)drawRect:(CGRect)rect
{
    if (self.need) {
        [self startAnalyze];
    }
    self.attributedString = nil;//释放掉内存
    [self clearTextUnitRects];//清空掉以前记录的特殊字符串的位置
    [self draw:rect];
}

- (void)draw:(CGRect)rect
{
    //Quartz 2D绘画环境,一张画布
    CGContextRef context = UIGraphicsGetCurrentContext();
    //将画笔上下文入栈,记录状态,并不更改上下文
    CGContextSaveGState(context);
    
    //设置context的ctm，用于适应core text的坐标体系
    //为了之后的坐标系描述按 UIKit 来做，在这里做一个坐标系的上下翻转操作
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, 1, -1);
    transform = CGAffineTransformTranslate(transform, 0, -rect.size.height);
    CGContextConcatCTM(context, transform);

    if (self.framesetterRef == NULL) {
        return;
    }
    //设置框架排版器,负责文本框架
    CTFramesetterRef framesetterRef = CFRetain(self.framesetterRef);
    if (framesetterRef == NULL) {
        return;
    }
    
    //创建绘制的区域，将 UIView 的rect作为排版的区域
    CGMutablePathRef pathRef = CGPathCreateMutable();
    if (pathRef == NULL) {
        [self releaseCFType:framesetterRef];
        return;
    }
    CGRect bounds = CGRectMake(0.0, 0.0, rect.size.width, rect.size.height);
    //添加一个矩形,在矩形内绘制
    CGPathAddRect(pathRef, NULL, bounds);
    
    //CTFrame是被CGPath包围的一块区域,包含一行或多行文本
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, 0), pathRef, NULL);
    if (frameRef == NULL) {
        [self releaseCFType:pathRef];
        [self releaseCFType:framesetterRef];
        return;
    }
    //绘制文本框架绘制到图形上下文
    CTFrameDraw(frameRef, context);
    
    CFArrayRef lines = CTFrameGetLines(frameRef);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    //得到每行的起始位置
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), lineOrigins);
    
    //真正绘图需要的是相对origin的坐标值，所以在循环CTLine和CTRun的时候，要记录下line和run的origin，并累加起来才是真正相对于坐标原点的偏移量
    
    //记录上一行Y
    CGFloat preLineY = 0;
    //存储循环中行高
    CGFloat lineHeight = 0;
    //存储循环中行Y
    CGFloat lineY = 0;
    //向下高度
    CGFloat lineDescent = 0;
    //获得行数
    CFIndex linesCount = CFArrayGetCount(lines);
    //按行CTLine循环
    for (CFIndex i = 0; i < linesCount; ++i)
    {
        CTLineRef lineRef = CFArrayGetValueAtIndex(lines, i);
        //计算一行的排版边界
        CTLineGetTypographicBounds(lineRef, NULL, &lineDescent, NULL);

        //坐标系中Y值越小越靠上,lineDescent是正数
        //最后一行
        if (i == linesCount - 1) {
            lineY = lineOrigins[i].y - lineDescent;
        } else {
            //行Y与高度，高度计算为当前y与上一个y差值，以实现无缝
            lineY = lineOrigins[i].y - lineDescent - self.lineSpacing/2;
        }
        //第一行
        if (i == 0) {
            lineHeight = rect.size.height - lineY;
        } else {
            lineHeight = fabs(preLineY - lineY);
        }
        preLineY = lineY;
        
        //每行分成多个CTRun绘制区
        CFArrayRef runs = CTLineGetGlyphRuns(lineRef);
        CFIndex runsCount = CFArrayGetCount(runs);
        //按CTRun循环
        for (CFIndex j = 0; j < runsCount; ++j)
        {
            //获取到run
            CTRunRef runRef = CFArrayGetValueAtIndex(runs, j);
            //获取到属性
            NSDictionary *attributes = (NSDictionary*)CTRunGetAttributes(runRef);
            TextUnit *unit = [attributes objectForKey:@"kTextUnit"];
            if (unit)
            {
                CGFloat runAscent = 0;
                CGFloat runDescent = 0;
                //获取一个CTRun的排版边界
                //后面3个参数ascent/descent/leading都是输出项
                CGFloat runWidth = CTRunGetTypographicBounds(runRef, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
                CGFloat runHeight = runAscent + runDescent;
                CGFloat runPointX = lineOrigins[i].x + CTLineGetOffsetForStringIndex(lineRef, CTRunGetStringRange(runRef).location, NULL);

                CGFloat runPointY = lineOrigins[i].y - runDescent;
                CGRect runRect = CGRectMake(runPointX, runPointY, runWidth, runHeight);
               
                //表情
                if (unit.textUnitType == TextUnitTypeIMEmoji)
                {
                    //表情图片图文混排时图片倒序...手动调整显示顺序
                    //TODO:应该是有方法可以自动调整顺序的
                    CGFloat imgRunPoiotY = rect.size.height - lineY - self.emojiWidthAndHeight;

                    CGRect imgRect = CGRectMake(runPointX, imgRunPoiotY, runWidth, runHeight);
                    NSString *name = [unit.transferredContent stringByDeletingPathExtension];
                    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
                    
                    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] initWithFrame:imgRect];
                    if (path) {
                        //自带gif动态表情
                        FLAnimatedImage * gifImage = [[FileCache sharedCache] fileFromMemoryCacheForKey:name];
                        if (!gifImage) {
                            NSData *data = [NSData dataWithContentsOfFile:path];
                            gifImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
                            [[FileCache sharedCache] storeFile:gifImage forKey:name];
                        }
                        imageView.animatedImage = gifImage;
                    } else {
                        //自带png静态表情
                        UIImage *image = [UIImage imageNamed:name];
                        imageView.image = image;
                    }
                    [self addSubview:imageView];
                }
                else if (unit.textUnitType == TextUnitTypeImage)
                {
                    //图文混排时图片倒序...手动调整显示顺序
                    //TODO:应该是有方法可以自动调整顺序的
                    CGFloat imgRunPoiotY = rect.size.height - lineY - self.imageWidthAndHeight;
                    
                    CGRect imgRect = CGRectMake(runPointX, imgRunPoiotY, runWidth, runHeight);
                    NSString *path = unit.transferredImagePath;
                    
                    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] initWithFrame:imgRect];
                    imageView.contentMode = UIViewContentModeScaleAspectFill;
                    imageView.clipsToBounds = YES;
                    if (path) {
                        //内存 -> 磁盘 -> 默认图片
                        //TODO: 网络图片需要下载
                        FLAnimatedImage *tImage = [[FileCache sharedCache] fileFromMemoryCacheForKey:unit.transferredImageId];
                        if (!tImage) {
                            NSData *data = [NSData dataWithContentsOfFile:path];
                            tImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
                            [[FileCache sharedCache] storeFile:tImage forKey:unit.transferredImageId];
                            imageView.animatedImage = tImage;
                        }
                        UIImage *ttImage = nil;
                        if (!tImage) {
                            ttImage = [UIImage imageWithContentsOfFile:path];
                            imageView.image = ttImage;
                        }
                        if (!ttImage) {
                            UIImage *image = [UIImage imageNamed:@"Icon_Chat_Image_Default"];
                            imageView.image = image;
                            
                            //[FavorCell putWebImageById:unit.transferredImageId forImageView:imageView];
                        }
                    }
                    [self addSubview:imageView];
                    //绘制在界面上时，对应的区域，当需要响应点击时候需要
                    [unit.rects addObject:[NSValue valueWithCGRect:runRect]];
                }
                else if ([unit isLinkType])
                {
                    runRect.origin.y = lineY;//设置为行的Y坐标
                    runRect.size.height = lineHeight;//设置为行的高度
                    //绘制在界面上时，对应的区域，当需要响应点击时候需要
                    [unit.rects addObject:[NSValue valueWithCGRect:runRect]];
                    if (unit.isSelected) {
                        //背景色
                        CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.5 alpha:0.5].CGColor);
                        CGContextFillRect(context, runRect);
                    }
                }
            }//if (unit)
        }//for (CFIndex j = 0; j < runsCount; ++j)
    }//for (CFIndex i = 0; i < linesCount; ++i)
    
    [self releaseCFType:frameRef];
    [self releaseCFType:pathRef];
    [self releaseCFType:framesetterRef];
    //将画笔上下文出栈
    CGContextRestoreGState(context);
}

- (void)clearTextUnitRects
{
    for (TextUnit *one in self.specialTextArray)
    {
        one.rects = nil;
    }
}

#pragma mark - touch事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    BOOL needsDisplay = NO;
    //之前有选中的
    if (self.selectedTextUnit.isSelected)
    {
        needsDisplay = YES;
        self.selectedTextUnit.selected = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(touchesOver) object:nil];
    }
    
    //获取UITouch对象
    UITouch *touch = [touches anyObject];
    //获取触摸点击当前view的坐标位置
    CGPoint location = [touch locationInView:self];
    //注意之前存储的坐标是反转的
    CGPoint runLocation = CGPointMake(location.x, self.bounds.size.height - location.y);

    TextUnit *tmp = nil;
    for (TextUnit *one in self.specialTextArray)
    {
        if ([one isLinkType]||
            one.textUnitType == TextUnitTypeImage)
        {
            for (NSValue *rectVaule in one.rects)
            {
                CGRect rect = [rectVaule CGRectValue];
                if (CGRectContainsPoint(rect, runLocation))
                {
                    tmp = one;
                    break;//里层循环
                }
            }
            if (tmp)
            {
                break;//外层循环
            }
        }
    }
    if (tmp)
    {
        tmp.selected = YES;
        needsDisplay = YES;
    }
    self.selectedTextUnit = tmp;
    if (needsDisplay)
    {
        [self setNeedsDisplay];
    }
    //有被选中的
    if (self.selectedTextUnit)
    {
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(CoreTextViewDelegate)] && [self.delegate respondsToSelector:@selector(coreTextView:didSelected:)])
        {
            TextUnit *textUnit = self.selectedTextUnit;
            [self.delegate coreTextView:self didSelected:textUnit];
        }
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //使按下效果持续一段时间
    if (self.selectedTextUnit)
    {
        [self performSelector:@selector(touchesOver) withObject:nil afterDelay:0.2];
    }
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //使按下效果持续一段时间
    if (self.selectedTextUnit)
    {
        [self performSelector:@selector(touchesOver) withObject:nil afterDelay:0.2];
    }
    [super touchesEnded:touches withEvent:event];
}

//触摸结束
- (void)touchesOver
{
    self.selectedTextUnit.selected = NO;
    self.selectedTextUnit = nil;
    [self setNeedsDisplay];
}

@end
