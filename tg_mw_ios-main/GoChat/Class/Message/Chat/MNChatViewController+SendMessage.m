//
//  MNChatViewController+SendMessage.m
//  GoChat
//
//  Created by Autumn on 2022/1/19.
//

#import "MNChatViewController+SendMessage.h"

#import "ChatMsgSender.h"
#import "ChatMsgReplyMarkupInlineKeyboard.h"

@implementation MNChatViewController (SendMessage)

- (NSDictionary *)photoMarkup {
    if (![NSString xhq_notEmpty:self.photoAdContent]) {
        return nil;
    }
    NSArray *matchs = [self ADMsgMatchsFromText:self.photoAdContent];
    if (matchs == 0) {
        return nil;
    }
    NSString *text = [self text:self.photoAdContent forReplaceMatchs:matchs];
    if (text.length > 0) {
        return nil;
    }
    return [self ADReplyMarkup:matchs];
}

- (BOOL)isAdSend {
    return [NSString xhq_notEmpty:self.photoAdContent];
}

- (NSString *)photoAdContent {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPhotoAdContent:(NSString *)photoAdContent {
    objc_setAssociatedObject(self, @selector(photoAdContent), photoAdContent, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)photoAdIndex {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setPhotoAdIndex:(NSInteger)photoAdIndex {
    objc_setAssociatedObject(self, @selector(photoAdIndex), @(photoAdIndex), OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - 发送广告（仅管理员权限）


- (NSArray<NSString *> *)ADMsgMatchsFromText:(NSString *)text {
    NSString *regex = @"\\[.+?(:|：)http(s?)://.+?\\]";
    NSError *error;
    
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:regex
                                                                                       options:kNilOptions
                                                                                         error:&error];
    NSArray *matchs = [regularExpression matchesInString:text
                                                 options:0
                                                   range:NSMakeRange(0, text.length)];
    
    NSMutableArray *subTexts = NSMutableArray.array;
    for (NSTextCheckingResult *match in matchs) {
        [subTexts addObject:[text substringWithRange:match.range]];
    }
    return subTexts;
}

- (NSDictionary *)ADReplyMarkup:(NSArray<NSString *> *)ads {
    ChatMsgReplyMarkupInlineKeyboard *markup = [ChatMsgReplyMarkupInlineKeyboard initWithInputs:ads];
    return markup.jsonObject;
}

- (NSString *)text:(NSString *)text forReplaceMatchs:(NSArray<NSString *> *)matchs {
    NSString *copyText = text.copy;
    for (NSString *match in matchs) {
        copyText = [copyText stringByReplacingOccurrencesOfString:match withString:@""];
    }
    copyText = [copyText stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    return copyText;
}

@end
