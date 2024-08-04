//
//  IMMessagePasteboard.m
//

#import "IMMessagePasteboard.h"
@interface IMMessagePasteboard()
@end

@implementation IMMessagePasteboard

static IMMessagePasteboard *_MessagePasteboard;

+ (IMMessagePasteboard *)messagePasteboard
{
    if (_MessagePasteboard == nil)
    {
        _MessagePasteboard = [[IMMessagePasteboard alloc] init];
    }
    return _MessagePasteboard;
}

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void)setChatRecordDTO:(MessageInfo *)chatRecordDTO
{
    [self willChangeValueForKey:@"chatRecordDTO"];
    
    UIImage *image = [UIPasteboard generalPasteboard].image;
    
    if (chatRecordDTO)
    {
        [UIPasteboard generalPasteboard].string = @"";
    }

    if (image)
    {
        [UIPasteboard generalPasteboard].image = image;
    }

    _chatRecordDTO = chatRecordDTO;
    _chatRecordDTOs = nil;
    
    [self didChangeValueForKey:@"chatRecordDTO"];
}

- (void)setChatRecordDTOs:(NSArray *)chatRecordDTOs
{
    UIImage *image = [UIPasteboard generalPasteboard].image;
    
    if (chatRecordDTOs)
    {
        [UIPasteboard generalPasteboard].string = @"";
    }
    
    if (image)
    {
        [UIPasteboard generalPasteboard].image = image;
    }
    
    _chatRecordDTOs = chatRecordDTOs;
    _chatRecordDTO = nil;
}

- (BOOL)hasCustomContent
{
    BOOL hasCustomContent = NO;
    
    if (self.chatRecordDTO || self.chatRecordDTOs)
    {
        hasCustomContent = YES;
    }
    NSString *string = [UIPasteboard generalPasteboard].string;
    if ([string length] > 0)
    {
        hasCustomContent = NO;
    }
    return hasCustomContent;
}

@end
