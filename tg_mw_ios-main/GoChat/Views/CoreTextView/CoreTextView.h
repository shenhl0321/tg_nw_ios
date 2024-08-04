//
//  CoreTextView.h
//  
/*
 使用说明
 CoreTextView *textView = [[CoreTextView alloc] initWithFrame:CGRectMake(0, 0, 200, 0)];
 textView.analyzeType = AnalyzeTypeEmoji|AnalyzeTypeURL|AnalyzeTypeSomeone;
 textView.text = ...;
 [textView startAnalyze];
 [textView adjustFrame];
 其他具体参考注释
 */
#import <Foundation/Foundation.h>
#import "TextUnit.h"

static CGFloat const kCoreTextViewEmojiSize = 21;

//消息内容的类型
typedef NS_ENUM(NSUInteger, AnalyzeType)
{
    AnalyzeTypeNone             = 0<<0, //什么都不解析，默认值
    
    AnalyzeTypeEmoji            = 1<<0, //表情
    
    AnalyzeTypeURL              = 1<<1, //网址（这里指一般的网址）
    AnalyzeTypeEmail            = 1<<2, //邮箱
    AnalyzeTypePhoneNumber      = 1<<3, //电话号码
    
    AnalyzeTypeSomeone          = 1<<4, //@某人
    AnalyzeTypeTopic            = 1<<5, //话题
    AnalyzeTypeDepartment       = 1<<6, //部门，体系
    
    AnalyzeTypeRetryInvite      = 1<<7, //讨论组点击重试
    
    AnalyzeTypeAutoReply        = 1<<8, //不再提醒
    AnalyzeTypeName             = 1<<9, //人名
    AnalyzeTypeURLSample        = 1<<10,//网址简写
    AnalyzeTypeImage            = 1<<11, //图片
    AnalyzeTypekKfcQuitQueue    = 1<<12, //在线客服－结束排队
    AnalyzeTypekKfcAppraise     = 1<<13, //在线客服－进行评价
    AnalyzeTypeRPPrompt  = 1<<14, //
    AnalyzeTypeTransferRemind  = 1<<15, //
    AnalyzeTypeAll              = 0xFFFFFFFF,
};

@class CoreTextView;
@protocol CoreTextViewDelegate <NSObject>

@optional
//选中了一个unit（一般指有意义的，如网址，某个人，话题等）
- (void)coreTextView:(CoreTextView *)coreTextView didSelected:(TextUnit *)textUnit;

@end


@interface CoreTextView : UIView

//显示的最大宽度，如果不设置，默认是initWithFrame的宽度
@property (nonatomic, assign) CGFloat maxWidth;

//待显示的消息体
@property (nonatomic, strong) NSString *text;

//默认普通字体颜色（默认[UIColor blackColor]）
@property (nonatomic, strong) UIColor *textColor;

//设置字体(默认[UIFont systemFontOfSize:15])
@property (nonatomic, strong) UIFont *textFont;

//特殊字符串颜色（如网址，邮箱，@等默认[UIColor blueColor]主要供给限制行场景下用）
@property (nonatomic, strong) UIColor *linkColor;

//行数限制，0的话不限制，如果限制行数，达到限制行，结尾将以...代替（默认值0）
@property (nonatomic, assign) NSUInteger numberOfLines;

//字符串做了限制行数处理，超过了numberOfLines
@property (nonatomic, assign,readonly) BOOL hasBreak;
//需要解析的类型（默认AnalyzeTypeNone）
@property (nonatomic, assign) AnalyzeType analyzeType;

//表情大小（默认48）（暂时将该接口暴露，后续使用进一步观察）
@property (nonatomic, assign) CGFloat emojiWidthAndHeight;

@property (nonatomic, assign) CGFloat imageWidthAndHeight;

//图片信息
@property (nonatomic, strong) NSArray *imageIds;//唯一 id
@property (nonatomic, strong) NSArray *imagePaths;//本地路径

//代理
@property (nonatomic, weak) id<CoreTextViewDelegate>delegate;

//touch begin 后得到的点击单元（一般指有意义的，如网址，某个人，话题等）
@property (nonatomic, strong, readonly) TextUnit *selectedTextUnit;
//分析（设置好属性后调用）
- (void)startAnalyze;

//是否按内部实际计算的大小调整frame，需要在startAnalyze后调用才有效
- (void)adjustFrame;

@property (nonatomic,strong) MessageInfo *msginfo;

@end
