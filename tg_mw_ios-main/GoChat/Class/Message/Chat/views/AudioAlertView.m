//
//  AudioAlertView.m

#import "AudioAlertView.h"

@interface AudioAlertView ()
@property (strong, nonatomic) IBOutlet UILabel *promptMessageLabel;
@property (strong, nonatomic) IBOutlet UIImageView *playAnimationImageView;
@property (strong, nonatomic) IBOutlet UIImageView *alertImageView;
@end

@implementation AudioAlertView

- (void)dealloc
{
    [self.playAnimationImageView stopAnimating];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        UIView *v = [[[NSBundle mainBundle] loadNibNamed:@"AudioAlertView" owner:self options:nil] objectAtIndex:0];
        v.center = self.center;
        [self addSubview:v];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int i = 1; i < 4; i++)
        {
            [array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"snim_speak_0%d", i]]];
        }
        self.playAnimationImageView.animationImages = array;
        self.playAnimationImageView.animationDuration = 0.8;
    }
    return self;
}

- (void)setViewWithRecordStatus:(RecordStatus)recordStatus
{
    switch (recordStatus)
    {
        case RecordStatusNoRecording:
        {
            [self.alertImageView setHidden:YES];
            [self.alertLabel setHidden:YES];
            [self.playAnimationImageView stopAnimating];
            [self.playAnimationImageView setHidden:YES];
            self.promptMessageLabel.text = @"尚未开始录音".lv_localized;
            break;
        }
        case RecordStatusIsRecording:
        {
            [self.alertImageView setHidden:YES];
            [self.alertLabel setHidden:YES];
            [self.playAnimationImageView startAnimating];
            [self.playAnimationImageView setHidden:NO];
            self.promptMessageLabel.text = @"向上滑动取消".lv_localized;
            break;
        }
        case RecordStatusWillCancelRecording:
        {
            [self.alertImageView setHidden:NO];
            self.alertImageView.image = [UIImage imageNamed:@"snim_speak_up"];
            [self.alertLabel setHidden:YES];
            [self.playAnimationImageView stopAnimating];
            [self.playAnimationImageView setHidden:YES];
            self.promptMessageLabel.text = @"松开取消发送".lv_localized;
            break;
        }
        case RecordStatusTimeTooShort:
        {
            [self.alertImageView setHidden:NO];
            self.alertImageView.image = [UIImage imageNamed:@"snim_speak_short"];
            [self.alertLabel setHidden:YES];
            [self.playAnimationImageView stopAnimating];
            [self.playAnimationImageView setHidden:YES];
            self.promptMessageLabel.text = @"时间太短".lv_localized;
            break;
        }
        case RecordStatusRecordingWillBeOver:
        {
            [self.alertImageView setHidden:YES];
            [self.alertLabel setHidden:NO];
            [self.playAnimationImageView startAnimating];
            [self.playAnimationImageView setHidden:NO];
            self.promptMessageLabel.text = @"向上滑动取消".lv_localized;
            break;
        }
        case RecordStatusRecordingIsOver:
        {
            [self.alertImageView setHidden:YES];
            [self.alertLabel setHidden:YES];
            [self.playAnimationImageView stopAnimating];
            [self.playAnimationImageView setHidden:YES];
            self.promptMessageLabel.text = @"已完成".lv_localized;
            break;
        }
        default:
            break;
    }
}

- (void)removeFromSuperview
{
    [self.playAnimationImageView stopAnimating];
    [super removeFromSuperview];
}

@end
