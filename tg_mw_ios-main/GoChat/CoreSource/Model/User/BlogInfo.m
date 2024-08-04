//
//  BlogInfo.m
//  GoChat
//
//  Created by mac on 2021/11/3.
//

#import "BlogInfo.h"

@implementation BlogInfo

@end

@implementation BlogLocation

@end

@implementation BlogLocationList

@end

@implementation BlogContent

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"photos": PhotoInfo.class};
}

- (BOOL)isPhotoContent {
    return [self.atType isEqualToString:@"blogContentTypePhoto"];
}

- (BOOL)isVideoContent {
    return [self.atType isEqualToString:@"blogContentTypeVideo"];
}

@end

@implementation BlogUserDates

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"user_dates": BlogUserDate.class};
}

@end

@implementation BlogUserDate


@end

@implementation BlogRepays

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"replys": BlogRepayList.class};
}

@end

@implementation BlogRepayList

@end

@implementation BlogId

@end


@implementation BlogEntities

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"entities": BlogEntity.class};
}

@end

@implementation BlogEntity


@end

@implementation BlogEntityType

- (NSString *)topicText {
    if (!self.isTopic) {
        return @"";
    }
    NSString *text = [self.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    text = [text stringByReplacingOccurrencesOfString:@"#" withString:@""];
    return text;
}

- (BOOL)isAt {
    return [self.atType isEqualToString:@"textEntityTypeMentionName"];
}

- (BOOL)isTopic {
    return [self.atType isEqualToString:@"textEntityTypeHashtag"];
}

@end
