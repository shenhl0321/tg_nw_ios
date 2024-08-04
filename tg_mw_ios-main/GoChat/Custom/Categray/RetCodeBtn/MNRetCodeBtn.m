//
//  MNRetCodeBtn.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/25.
//

#import "MNRetCodeBtn.h"

@interface MNRetCodeBtn ()
@property (nonatomic, assign) NSInteger count;//倒计时的
@end

@implementation MNRetCodeBtn

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.font = fontRegular(17);
        [self setTitleColor: [UIColor colorTextFor0DBFC0] forState:UIControlStateNormal];
        [self setTitleColor: [UIColor colorTextFor0DBFC0] forState:UIControlStateDisabled];
        [self setTitle:LocalString(localVerificationCode) forState:UIControlStateNormal];
       
    }
    return self;
}

- (void)timer{
    _count = 60;
    WS(weakSelf)
    NSTimeInterval period = 1.0; //设置时间间隔
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        weakSelf.count --;
        if (weakSelf.count == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                 [weakSelf tvStyleNormal:YES];
            });
            dispatch_source_cancel(_timer);
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf tvStyleNormal:NO];
            });
        }
    });
    dispatch_resume(_timer);
}

- (void)tvStyleNormal:(BOOL)normal{
    self.enabled = normal;
    if (normal) {
        [self setTitle:LocalString(localVerificationCode) forState:UIControlStateNormal];
    }else{
        
        [self setTitle:[NSString stringWithFormat:LocalString(localResentK),self.count] forState:UIControlStateNormal];
        
        [self setTitleColor:HEXCOLOR(0x34CDAC) forState:UIControlStateNormal];
    }
}


@end
