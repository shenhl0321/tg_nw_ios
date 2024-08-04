//
//  IMTextView.h
//

#import <UIKit/UIKit.h>
@class TextUnit;

@protocol IMTextViewDelegate <UITextViewDelegate>

@optional

- (void)textView:(UITextView *)textView willPaste:(MessageInfo *)chatRecordDTO;

@end

//目前只支持@和表情处理

@interface IMTextView : UITextView

@property (nonatomic, weak) id <IMTextViewDelegate> delegate;

//返回特殊属性串
- (NSString *)attributedString;

//text表示表情符号串（原串即各端都能解析的那个）
- (void)insertEmoji:(NSString *)text;

//插入话题,//{{#轻松一刻#|3104}} topicName包括两遍的#符号
- (void)insertTopic:(NSString *)topicId topicName:(NSString *)topicName;

//插入@体系,//{{@tx%@|%@}}
- (void)insertTx:(NSString *)snID systemName:(NSString *)systemName;

//供插入@调用，在光标位置插入指定串
- (void)insertText:(NSString *)text withTextUnit:(TextUnit *)unit;

//更新选择范围，供删除时候调用
- (void)updateSelectedRange;

//清空
- (void)clearAttributedString;

//将属性串向普通字符串做匹配
- (void)makeAttributedStringToFitText;

//将特殊属性串，转换为一般字符串
- (NSString *)convertAttributedStringToNormalString;

//将表情中文字符转换为符号
- (NSString *)convertToEmoji:(NSString *)sourceText;

//分割
- (NSArray *)componentsSeparatedByVery2000:(NSString *)sourceText;

@end
