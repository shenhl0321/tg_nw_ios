//
//  GotRpDialog.m

#import "GotRpDialog.h"
#import "GotRpContentDialog.h"

@interface GotRpDialog()<GotRpContentDialogDelegate>
@end

@implementation GotRpDialog

- (instancetype)initDialog:(RedPacketInfo *)rp
{
    self = [super init];
    if (self)
    {
        self.type = MMPopupTypeAlert;
        self.backgroundColor = [UIColor clearColor];
        [MMPopupWindow sharedWindow].touchWildToHide = YES;
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(250);
            make.height.mas_equalTo(440);
        }];
        
        GotRpContentDialog *contentView = [[[UINib nibWithNibName:@"GotRpContentDialog" bundle:nil] instantiateWithOwner:self options:nil] firstObject];
        [self addSubview:contentView];
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self);
        }];
        [contentView.closeBtn addTarget:self action:@selector(close_click) forControlEvents:UIControlEventTouchUpInside];
        [contentView initRp:rp];
        contentView.delegate = self;
    }
    return self;
}

- (void)close_click
{
    [self hide];
}

- (void)GotRpContentDialog_viewDetail:(RedPacketInfo *)rp
{
    [self hide];
    if(self.delegate && [self.delegate respondsToSelector:@selector(GotRpDialog_viewDetail:)])
    {
        [self.delegate GotRpDialog_viewDetail:rp];
    }
}

- (void)GotRpContentDialog_close
{
    [self hide];
}

@end
