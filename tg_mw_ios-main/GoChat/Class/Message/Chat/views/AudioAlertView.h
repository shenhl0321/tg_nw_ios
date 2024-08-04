//
//  AudioAlertView.h

//录音的状态
typedef NS_ENUM(NSInteger, RecordStatus)
{
    RecordStatusNoRecording = 0,//没有录音的状态//这个状态一般该页面就被移除了
    RecordStatusIsRecording = 1, //正在录音
    RecordStatusWillCancelRecording = 2, //将要取消录音
    RecordStatusTimeTooShort = 3,//时间太短
    RecordStatusRecordingWillBeOver = 4,//时间进入55->60过程中将会是这个状态
    RecordStatusRecordingIsOver = 5,//录音结束了//这个状态一般该页面就被移除了
};
@interface AudioAlertView : UIView
- (void)setViewWithRecordStatus:(RecordStatus)recordStatus;
@property (strong, nonatomic) IBOutlet UILabel *alertLabel;
@end
