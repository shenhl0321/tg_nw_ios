//
//  ChatMsgReplyMarkupInlineKeyboard.m
//  GoChat
//
//  Created by Autumn on 2022/1/19.
//

#import "ChatMsgReplyMarkupInlineKeyboard.h"

@implementation ChatMsgReplyMarkupInlineKeyboard

+ (instancetype)initWithInputs:(NSArray<NSString *> *)inputs {
    return [[ChatMsgReplyMarkupInlineKeyboard alloc] initWithInputs:inputs];
}

- (instancetype)initWithInputs:(NSArray<NSString *> *)inputs {
    self = [super init];
    if (self) {
        NSMutableArray *buttons = NSMutableArray.array;
        [inputs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ChatMsgInlineKeyboardButton *button = [ChatMsgInlineKeyboardButton initWithInput:obj];
            [buttons addObject:button];
        }];
        /// 数组拆分
        NSUInteger itemsRemaining = buttons.count;
        int startIndex = 0;
        while (itemsRemaining) {
            NSRange range = NSMakeRange(startIndex, MIN(5, itemsRemaining));
            NSMutableArray *rows = [buttons subarrayWithRange:range].mutableCopy;
            [self.rows addObject:rows];
            itemsRemaining -= range.length;
            startIndex += range.length;
        }
    }
    return self;
}

- (NSString *)types {
    return @"replyMarkupInlineKeyboard";
}

- (NSDictionary *)jsonObject {
    
    return @{
        @"@type": self.types,
        @"rows": self.rowsObjects
    };
}

- (NSMutableArray<NSMutableArray<ChatMsgInlineKeyboardButton *> *> *)rows {
    if (!_rows) {
        _rows = NSMutableArray.array;
    }
    return _rows;
}

- (NSMutableArray *)rowsObjects {
    NSMutableArray *rows = NSMutableArray.array;
    [self.rows enumerateObjectsUsingBlock:^(NSMutableArray<ChatMsgInlineKeyboardButton *> * _Nonnull buttons, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *objs = NSMutableArray.array;
        [buttons enumerateObjectsUsingBlock:^(ChatMsgInlineKeyboardButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [objs addObject:obj.jsonObject];
        }];
        [rows addObject:objs];
    }];
    return rows;
}

@end



@implementation ChatMsgInlineKeyboardButton

+ (instancetype)initWithInput:(NSString *)input {
    return [[ChatMsgInlineKeyboardButton alloc] initWithInput:input];
}
- (instancetype)initWithInput:(NSString *)input {
    self = [super init];
    if (self) {
        NSString *text = [input stringByReplacingOccurrencesOfString:@"[" withString:@""];
        text = [text stringByReplacingOccurrencesOfString:@"]" withString:@""];
        NSArray *values;
        if ([text containsString:@"："]) {
            values = [text componentsSeparatedByString:@"："];
        } else if ([text containsString:@":"]) {
            values = [text componentsSeparatedByString:@":"];
        }
        self.type = ChatMsgInlineKeyboardButtonTypeUrl.new;
        if (values.count == 2) {
            self.text = values.firstObject;
            self.type.url = values.lastObject;
        } else if (values.count == 3) {
            self.text = values.firstObject;
            self.type.url = [NSString stringWithFormat:@"%@:%@", values[1], values.lastObject];
        }
    }
    return self;
}

- (NSString *)types {
    return @"inlineKeyboardButton";
}

- (NSDictionary *)jsonObject {
    return @{
        @"@type": self.types,
        @"type": self.type.jsonObject,
        @"text": self.text ? : @""
    };
}

@end

@implementation ChatMsgInlineKeyboardButtonTypeUrl

- (NSString *)types {
    return @"inlineKeyboardButtonTypeUrl";
}

- (NSDictionary *)jsonObject {
    return @{
        @"@type": self.types,
        @"url": self.url ? : @""
    };
}

@end
