//
//  CZCommonTool.m
//  GoChat
//
//  Created by mac on 2021/7/1.
//

#import "CZCommonTool.h"
#import <Photos/PhotosTypes.h>
#import <CoreText/CoreText.h>

@implementation CZCommonTool

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;

    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@".lv_localized,err);
        return nil;
    }

    return dic;
}

+(NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

//  判断是否以字母开头
+ (BOOL)isEnglishFirst:(NSString *)str {
    NSString *regular = @"^[A-Za-z].+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
    
    if ([predicate evaluateWithObject:str] == YES){
        return YES;
    }else{
        return NO;
    }
}
//  判断是否以汉字开头
+ (BOOL)isChineseFirst:(NSString *)str {
    int utfCode = 0;
    void *buffer = &utfCode;
    NSRange range = NSMakeRange(0, 1);
    BOOL b = [str getBytes:buffer maxLength:2 usedLength:NULL encoding:NSUTF16LittleEndianStringEncoding options:NSStringEncodingConversionExternalRepresentation range:range remainingRange:NULL];
    if (b && (utfCode >= 0x4e00 && utfCode <= 0x9fa5)){
        return YES;
    }else{
        return NO;
    }
}

//判断是否是群管理
+ (BOOL)isGroupManager:(SuperGroupInfo *)superGroupInfo{
    GroupMemberState curStatu = [superGroupInfo.status getMemberState];
    if (curStatu == GroupMemberState_Administrator || curStatu == GroupMemberState_Creator) {//创建者可能无权限 待定
        return YES;
    }else{
        return NO;
    }
}

+ (UIImage *)createQRCodeWithTargetString:(NSString *)targetString logoImage:(UIImage *)logoImage {
    // 1.创建一个二维码滤镜实例
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    // 2.给滤镜添加数据
    NSString *targetStr = targetString;
    NSData *targetData = [targetStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    [filter setValue:targetData forKey:@"inputMessage"];
    
    // 3.生成二维码
    CIImage *image = [filter outputImage];
    
    // 4.高清处理: size 要大于等于视图显示的尺寸
    UIImage *img = [self createNonInterpolatedUIImageFromCIImage:image size:[UIScreen mainScreen].bounds.size.width];
    
    //5.嵌入LOGO
    //5.1开启图形上下文
    UIGraphicsBeginImageContext(img.size);
    //5.2将二维码的LOGO画入
    [img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
    
    UIImage *centerImg = logoImage;
    CGFloat centerW=img.size.width*0.25;
    CGFloat centerH=centerW;
    CGFloat centerX=(img.size.width-centerW)*0.5;
    CGFloat centerY=(img.size.height -centerH)*0.5;
    [centerImg drawInRect:CGRectMake(centerX, centerY, centerW, centerH)];
    //5.3获取绘制好的图片
    UIImage *finalImg=UIGraphicsGetImageFromCurrentImageContext();
    //5.4关闭图像上下文
    UIGraphicsEndImageContext();

    //6.生成最终二维码
    return finalImg;
}

+ (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image size:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap
    size_t width = CGRectGetWidth(extent)*scale;
    size_t height = CGRectGetHeight(extent)*scale;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    //2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
}

/**
 *  截屏
 *
 *  @param view 需要截屏的视图
 *
 *  @return 截屏后的图片
 */
+ (UIImage *)captureImageInView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions (view. bounds . size , YES , 0);
    [view. layer renderInContext : UIGraphicsGetCurrentContext ()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext ();
    UIGraphicsEndImageContext ();
    CGImageRef imageRef = viewImage. CGImage ;
    CGRect rect = view. bounds ;  // 在 view 上的截图的区域
    CGImageRef imageRefRect = CGImageCreateWithImageInRect (imageRef, rect);
    UIImage *sendImage = [[ UIImage alloc ] initWithCGImage :imageRefRect];
    NSData *imageViewData = UIImagePNGRepresentation (sendImage);
   
    NSArray *paths = NSSearchPathForDirectoriesInDomains ( NSDocumentDirectory , NSUserDomainMask , YES );
    NSString *documentsDirectory = [paths objectAtIndex :0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent : @"result.png" ];
    NSLog ( @"%@" , savedImagePath);
    [imageViewData writeToFile :savedImagePath atomically : YES ];
    CGImageRelease (imageRefRect);
   
    return viewImage;
}

#pragma mark - 获取当前视图
//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    return currentVC;
}

+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    if ([rootVC presentedViewController])
    {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]])
    {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    }
    else if ([rootVC isKindOfClass:[UINavigationController class]])
    {
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    }
    else
    {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}



/*业务工具*/


+ (NSDictionary *)getGreyRedPagListwithPkid:(long)rId{
    NSString *userid = [NSString stringWithFormat:@"%ld",[[AuthUserManager shareInstance] currentAuthUser].userId];
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr = [defs objectForKey:userid];
    if (!arr) {
        arr = [NSMutableArray array];
    }
    for (NSDictionary *itemdic in arr) {
        if ([[itemdic objectForKey:@"rId"] longValue] == rId) {
            return itemdic;
        }
    }
    return nil;
}
//存储
//{

//    "expire"
//    "get"
//    "getdone"
//}
+(void)saveGreyRedpadID:(NSDictionary *)msgDic{
    NSString *userid = [NSString stringWithFormat:@"%ld",[[AuthUserManager shareInstance] currentAuthUser].userId];
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr = [[defs objectForKey:userid] mutableCopy];
    if (!arr) {
        arr = [NSMutableArray array];
    }
    for (NSDictionary *itemdic in arr) {
        if ([[itemdic objectForKey:@"rId"] longValue] == [[msgDic objectForKey:@"rId"] longValue]) {
            //已存储
            return;
        }
    }
    [arr addObject:msgDic];
    [defs setObject:arr forKey:userid];
    [defs synchronize];
}

#pragma mark- 时间戳计算
+ (NSString *)labelFinallyTime:(NSString *)yetTime{
    
    NSDate * nowDate = [NSDate date];
    
    NSTimeInterval now = [nowDate timeIntervalSince1970];
    NSTimeInterval yet = [yetTime doubleValue];
    
    //    NSLog(@"yet = %.f",yet);
    //    NSLog(@"now = %.f",now);
    
    
    NSTimeInterval newTime = now - yet;
    //    NSLog(@"new = %.f",newTime);
    
    NSString * mm = [NSString stringWithFormat:@"%.2f",newTime/60];
    NSString * hh = [NSString stringWithFormat:@"%.2f",newTime/60/60];
    NSString * dd = [NSString stringWithFormat:@"%.2f",newTime/60/60/24];
    NSString * MM = [NSString stringWithFormat:@"%.2f",newTime/60/60/24/30];
    
    
    //    NSLog(@"mm =%@",mm);
    //    NSLog(@"hh =%@",hh);
    //    NSLog(@"dd =%@",dd);
    //    NSLog(@"MM =%@",MM);
    
    NSString * date;
    
    if ([MM floatValue] >= 1) {
        
        date = [NSString stringWithFormat:@"%.f个月前上线".lv_localized,[MM floatValue]];
        
    }else if ([dd floatValue] >= 1) {
        
        date = [NSString stringWithFormat:@"%.f天前上线".lv_localized,[dd floatValue]];
        
    }else if ([hh floatValue] >= 1) {
        
        date = [NSString stringWithFormat:@"%.f小时前上线".lv_localized,[hh floatValue]];
        
    }else if ([mm floatValue] >= 1) {
        
        date = [NSString stringWithFormat:@"%.f分钟前上线".lv_localized,[mm floatValue]];
        
    }else {
        
        date = [NSString stringWithFormat:@"%.f秒前上线".lv_localized,newTime];
    }
    
    //    NSLog(@"%@",date);
    
    return date;
}

//写gif到沙盒
+ (void)saveGifImage:(PHAssetResource *)resource withImage:(UIImage *)gifimage withblock:(customBlock)block{
    NSLog(@"resource : %@",resource);
    
    NSString *localPath = [NSString stringWithFormat:@"%@/%@.gif", UserImagePath([UserInfo shareInstance]._id), [Common generateGuid]];
    PHAssetResourceRequestOptions *option = [[PHAssetResourceRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource toFile:[NSURL fileURLWithPath:localPath] options:option completionHandler:^(NSError * _Nullable error) {
        if (error) {
            if (error.code == -1) {
                //文件已经存在
            }
            block(nil);
        }else{
            block(localPath);
        }
    }];
}

//计算文本高度
+ (CGSize)boundingRectWithString:(NSString *)str withFont:(float)fontsize withWidth:(float)width{
    NSDictionary *dic = @{NSFontAttributeName : [UIFont systemFontOfSize:fontsize]};
       //默认的
     CGRect infoRect =   [str boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil];
       // 参数1: 自适应尺寸,提供一个宽度,去自适应高度
       // 参数2:自适应设置 (以行为矩形区域自适应,以字体字形自适应)
       // 参数3:文字属性,通常这里面需要知道是字体大小
       // 参数4:绘制文本上下文,做底层排版时使用,填nil即可
        //上面方法在计算文字高度的时候可能得到的是带小数的值,如果用来做视图尺寸的适应的话,需要使用更大一点的整数值.取整的方法使用ceil函数
    return infoRect.size;
}

//提取url
+ (NSArray*)getURLFromStr:(NSString *)string {
    if (IsStrEmpty(string)) {
        return nil;
    }
    NSError *error;
    //可以识别url的正则表达式
    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
    options:NSRegularExpressionCaseInsensitive
    error:&error];

    NSArray *arrayOfAllMatches = [regex matchesInString:string
    options:0
    range:NSMakeRange(0, [string length])];

    //NSString *subStr;
    NSMutableArray *arr=[[NSMutableArray alloc] init];

    for (NSTextCheckingResult *match in arrayOfAllMatches){
        NSString* substringForMatch;
        substringForMatch = [string substringWithRange:match.range];
        [arr addObject:substringForMatch];
    }
    return arr;
}

+ (BOOL)checkUrlWithString:(NSString *)url {
    if(url.length < 1)
        return NO;
    if (url.length>4 && [[url substringToIndex:4] isEqualToString:@"www."]) {
        url = [NSString stringWithFormat:@"http://%@",url];
    } else {
        url = url;
    }
    NSString *urlRegex = @"(https|http|ftp|rtsp|igmp|file|rtspt|rtspu)://((((25[0-5]|2[0-4]\\d|1?\\d?\\d)\\.){3}(25[0-5]|2[0-4]\\d|1?\\d?\\d))|([0-9a-z_!~*'()-]*\\.?))([0-9a-z][0-9a-z-]{0,61})?[0-9a-z]\\.([a-z]{2,6})(:[0-9]{1,4})?([a-zA-Z/?_=]*)\\.\\w{1,5}";

    NSPredicate* urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];

    return [urlTest evaluateWithObject:url];
}

// 解析链接地址
+ (NSArray<TextUnit *> *)parseURLWithContent:(NSString *)urlStr
{
    NSMutableArray *arr = [NSMutableArray array];
    if (IsStrEmpty(urlStr)) {
        return arr;
    }
    NSError *error = nil;
    
    NSString *urlHead = @"(http[s]{0,1})://";
    NSString *url = @"[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?";

    NSString *regularStr = [NSString stringWithFormat:@"%@%@|%@", urlHead, url, url];
    
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regularStr options:NSRegularExpressionCaseInsensitive error:&error];
    if (error)
    {
        return arr;
    }
    NSArray *arrayOfAllMatches = [regular matchesInString:urlStr options:0 range:NSMakeRange(0, [urlStr length])];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        NSString* substringForMatch = [urlStr substringWithRange:match.range];
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
            canOpen = [[UIApplication sharedApplication] canOpenURL:testURL];
        }
        //如果是系统浏览器无法打开的，则不认为是有效的url
        if (NO == canOpen)
        {
            continue;
        }
        
        TextUnit *unit = [[TextUnit alloc] init];
        unit.range = match.range;
        unit.originalContent = [urlStr substringWithRange:match.range];
        unit.transferredContent = testURL.absoluteString;
        unit.textUnitType = TextUnitTypeURL;
        unit.underline = NO;
        [arr addObject:unit];
    }
    return arr;
}


//是否为二维码
+ (BOOL)isQRcodeImage:(UIImage *)image{
    UIImage *pickedImage = image;
    CIImage *detectImage = [CIImage imageWithData:UIImagePNGRepresentation(pickedImage)];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    CIQRCodeFeature *feature = (CIQRCodeFeature *)[detector featuresInImage:detectImage options:nil].firstObject;
    if (feature.messageString) {
        return YES;
    }else{
        return NO;
    }
}

//聊天信息是否包含敏感词
+ (BOOL)chatMessageContainsKeys:(NSArray *)keywords withmsg:(NSString *)msgstr{
    if (!keywords || keywords.count < 1) {
        return NO;
    }
    for (NSString *itemstr in keywords) {
        if ([msgstr containsString:itemstr]) {
            return YES;
        }
    }
    return NO;
}

//存储会话的草稿  chatid   message
+(void)savedraftchatid:(long)chatid saveString:(NSString *)contentstr{
    NSString *userid = [NSString stringWithFormat:@"chat_%ld",[[AuthUserManager shareInstance] currentAuthUser].userId];
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr = [[defs objectForKey:userid] mutableCopy];
    if (!arr) {
        arr = [NSMutableArray array];
    }
    NSDictionary *savedic = @{
        @"chatid" : [NSNumber numberWithLong:chatid],
        @"message" : contentstr
    };
    for (NSDictionary *itemdic in [arr copy]) {
        if ([[itemdic objectForKey:@"chatid"] longValue] == chatid) {
            //已存储
            [arr removeObject:itemdic];
        }
    }
    [arr addObject:savedic];
    [defs setObject:arr forKey:userid];
    [defs synchronize];
}

//存储会话的草稿  chatid   message  草稿中@的对象
+(void)saveUserMsgdraftchatid:(long)chatid saveArray:(NSArray *)userinfoArr{
    NSString *inder = [NSString stringWithFormat:@"GOChat_SaveUserMsg_%ld",[[AuthUserManager shareInstance] currentAuthUser].userId];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userinfoArr requiringSecureCoding:YES error:nil];
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *diclin = [[defs objectForKey:inder] mutableCopy];
    if (!diclin) {
        diclin = [NSMutableDictionary dictionary];
    }
    [diclin setObject:data forKey:[NSString stringWithFormat:@"%ld",chatid]];
    [defs setObject:diclin forKey:inder];
    [defs synchronize];
}

//获取草稿  提醒的用户数组
+ (NSArray *)getUserMsgdraftchatid:(long)chatid{
    NSString *inder = [NSString stringWithFormat:@"GOChat_SaveUserMsg_%ld",[[AuthUserManager shareInstance] currentAuthUser].userId];
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *diclin = [defs objectForKey:inder];
    if (!diclin) {
        diclin = [NSMutableDictionary dictionary];
    }
    NSData *data = [diclin objectForKey:[NSString stringWithFormat:@"%ld",chatid]];
    NSSet *set = [[NSSet alloc] initWithArray:@[[UserInfo class],[NSArray class],[NSDictionary class]]];
    NSArray *array  = [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:data error:nil];//UserInfo
    return array;
}

//获取草稿
+ (NSString *)getdraftchatid:(long)chatid{
    NSString *userid = [NSString stringWithFormat:@"chat_%ld",[[AuthUserManager shareInstance] currentAuthUser].userId];
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arr = [defs objectForKey:userid];
    if (!arr) {
        arr = [NSMutableArray array];
    }
    for (NSDictionary *itemdic in arr) {
        if ([[itemdic objectForKey:@"chatid"] longValue] == chatid) {
            return [itemdic objectForKey:@"message"];
        }
    }
    return @"";
}

//正则  是否为数字
+ (BOOL)deptNumInputShouldNumber:(NSString *)str
{
   if (!str ||  str.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

//根据文字内容、字体大小和宽度限制计算文本控件的行数
+ (NSArray *)rowsOfString:(NSString *)text withFont:(UIFont *)font withWidth:(CGFloat)width {
    if (!text || text.length == 0) {
        return 0;
    }
    CTFontRef myFont = CTFontCreateWithName(( CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge  id)myFont range:NSMakeRange(0, attStr.length)];
    CFRelease(myFont);
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(( CFAttributedStringRef)attStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,width,MAXFLOAT));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = ( NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    for (id line in lines) {
        CTLineRef lineRef = (__bridge  CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [text substringWithRange:range];
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr,
                                       lineRange,
                                       kCTKernAttributeName,
                                       (CFTypeRef)([NSNumber numberWithFloat:0.0]));
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr,
                                       lineRange,
                                       kCTKernAttributeName,
                                       (CFTypeRef)([NSNumber numberWithInt:0.0]));
        [linesArray addObject:lineString];
    }
    return linesArray;
}

// 获取cell高度
+ (CGFloat)getCellHeightWithStr:(NSString *)str withbool:(BOOL)showAll{
    float height = 51+15;
    NSArray *textArr = [CZCommonTool rowsOfString:str withFont:[UIFont systemFontOfSize:14] withWidth:SCREEN_WIDTH-30];
    if (showAll || (textArr && textArr.count < 4)) {
        CGSize size = [CZCommonTool boundingRectWithString:str withFont:14 withWidth:SCREEN_WIDTH-30];
        return height + size.height;
    }else{
        CGSize size = [CZCommonTool boundingRectWithString:@"111" withFont:14 withWidth:SCREEN_WIDTH-30];
        return height + 3*size.height;
    }
}

//获取在串中位置
+ (NSRange)getRangeFromString:(NSString *)targetStr withString:(NSString *)subStr{
    NSString *strLin = [NSString stringWithFormat:@"@%@",subStr];
    NSRange range = [targetStr rangeOfString:strLin];
    return range;
}

//秒 转为 01:30:20
+ (NSString *)getFormatTimeStrWith:(NSInteger)timeTotal{
    int s = timeTotal % 60;
    int m = (timeTotal - s) / 60 % 60;
    long h = ((timeTotal - s) / 60 - m) / 60;
    return [NSString stringWithFormat:@"%02ld:%02d:%02d",h,m,s];
}

@end
