//
//  LabelPwdTfView.m
//  LoganSmart
//
//  Created by 许蒙静 on 2021/10/18.
//

#import "LabelPwdTfView.h"

//@interface LabelPwdTfView ()
//@property (nonatomic, copy) NSString *title;
//@property (nonatomic, copy) NSString *placeholder;
//@property (nonatomic, copy) NSString *text;
//@end
//
//@implementation LabelPwdTfView
//
//-(void)awakeFromNib{
//    [super awakeFromNib];
//    [self initUI];
//}
//
//
//- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title text:(NSString *)text placeholder:(NSString *)placeholder
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.title = title;
//        self.placeholder = placeholder;
//        self.text = text;
//        [self initUI];
//    }
//    return self;
//}
//
//- (instancetype)initWithTitle:(NSString *)title text:(NSString *)text placeholder:(NSString *)placeholder
//{
//    self = [super init];
//    if (self) {
//        self.title = title;
//        self.placeholder = placeholder;
//        self.text = text;
//        [self initUI];
//    }
//    return self;
//}
//
//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self initUI];
//    }
//    return self;
//}
//
//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        self.frame = CGRectMake(0, 0, kScreenWidth, 20+48);
//        [self initUI];
//    }
//    return self;
//}
//
//- (void)initUI{
//    self.backgroundColor = [UIColor clearColor];
//    [self addSubview:self.header];
//    [self addSubview:self.tfRow];
//    
//}
//
//-(SectionHeaderView *)header{
//    if (!_header) {
//        _header = [[SectionHeaderView alloc] initWithTitle:[Util objToStr:self.title]];
//        _header.frame = CGRectMake(0, 0, kScreenWidth, 20);
//    }
//    return _header;
//}
//
//-(PwdTfRow *)tfRow{
//    if (!_tfRow) {
//        _tfRow = [[PwdTfRow alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, 48)];
//        _tfRow.tf.placeholder = [Util objToStr:self.placeholder];
//        _tfRow.tf.text = [Util objToStr:self.text];
//    }
//    return _tfRow;
//}
//
//
//-(void)setTitle:(NSString *)title{
//    _title = [Util objToStr:title];
//    self.header.title = _title;
//}
//
//-(void)setText:(NSString *)text{
//    _text = [Util objToStr:text];
//    self.tfRow.text = _text;
//}
//
//-(void)setPlaceholder:(NSString *)placeholder{
//    _placeholder = [Util objToStr:placeholder];
//    self.tfRow.placeholder = _placeholder;
//}
//
//@end
