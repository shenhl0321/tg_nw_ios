//
//  EmptyMessageCell.m

#import "EmptyMessageCell.h"

@interface EmptyMessageCell()
@end

@implementation EmptyMessageCell

+ (CGFloat)contentHeightForTableViewWith:(MessageInfo *)chatRecordDTO showNickName:(BOOL)showNickName
{
    return 0;
}

- (void)reset
{
    [super reset];
}

- (void)initialize
{
    [super initialize];
}

- (void)config
{
    [super config];
}

- (void)adjustFrame
{
    self.contentBaseView.frame = CGRectMake(0, 0, 0, 0);
    [super adjustFrame];
}

@end
