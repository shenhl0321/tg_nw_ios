//
//  IMMessagePasteboard.h
//

#import <Foundation/Foundation.h>

@interface IMMessagePasteboard : NSObject

+ (IMMessagePasteboard *)messagePasteboard;

@property (nonatomic, assign, readonly) BOOL hasCustomContent;

@property (nonatomic, strong) MessageInfo *chatRecordDTO;
@property (nonatomic, strong) NSArray *chatRecordDTOs;//多条消息

@end
