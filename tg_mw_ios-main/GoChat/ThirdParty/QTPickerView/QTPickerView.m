//
//  QTPickerView.m
//  QTPickerView
//
//  Created by ijointoo on 2017/10/19.
//  Copyright © 2017年 demo. All rights reserved.
//

#import "QTPickerView.h"

@interface QTPickerView ()

@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)void(^confirmBolck)(NSInteger path,NSString *pathStr);
@property (nonatomic,strong)void(^cancelBolck)(void);

@property (nonatomic,strong)UIView *contentView;
@property (nonatomic,strong)UILabel *titleLab;
@property (nonatomic,strong)UIButton *cancelBtn;
@property (nonatomic,strong)UIButton *confirmBtn;
@property (nonatomic,strong)UIDatePicker *datePicker;

@end

# define QTLog(fmt, ...) NSLog((@"[方法:%s____" "行:%d]\n " fmt),  __FUNCTION__, __LINE__, ##__VA_ARQT__);
/** 宽高*/
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
/** window*/
#define kWindow [UIApplication sharedApplication].keyWindow

@implementation QTPickerView

- (UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//        _cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
        _cancelBtn.backgroundColor = HEXCOLOR(0xF5F9FA);
        _cancelBtn.clipsToBounds = YES;
        _cancelBtn.layer.cornerRadius = 22;
        [_cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}
- (void)cancelBtnAction{
    if (self.cancelBolck) {
        self.cancelBolck();
    }
    [self disAppear];
}
- (UIButton *)confirmBtn{
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//        _confirmBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_confirmBtn setTitle:@"保存" forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmBtn.backgroundColor = HEXCOLOR(0x08CF98);
        _confirmBtn.clipsToBounds = YES;
        _confirmBtn.layer.cornerRadius = 15;
        [_confirmBtn addTarget:self action:@selector(sureBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}
- (void)sureBtnAction{
    if (self.confirmBolck) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy年MM月dd日"];
        NSString *str = [formatter stringFromDate: self.datePicker.date];
        self.confirmBolck(-1, str);
    }
    [self disAppear];
}
- (UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc]init];
        _titleLab.font = [UIFont systemFontOfSize:12];
        _titleLab.textColor = HEXCOLOR(0x999999);
    }
    return _titleLab;
}
- (UIDatePicker *)datePicker{
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc]init];
        _datePicker.backgroundColor = [UIColor whiteColor];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        if (@available(iOS 13.4, *)) {
            _datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        } else {
            // Fallback on earlier versions
        }
        _datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
        NSDate *currentDate = [NSDate date];
        _datePicker.maximumDate = currentDate;
    }
    return _datePicker;
}

- (UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}
- (void)setBackView{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, SCREEN_WIDTH, 360) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(15, 15)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.contentView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.contentView.layer.mask = maskLayer;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.cancelBtn];
        [self.contentView addSubview:self.titleLab];
        [self.contentView addSubview:self.confirmBtn];
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            //
            make.left.right.bottom.equalTo(self);
            make.height.mas_offset(360);
        }];
        
        [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            //
            make.centerY.equalTo(self.contentView.mas_top).offset(30);
            make.right.equalTo(self.contentView).offset(-15);
            make.width.mas_offset(55);
            make.height.mas_offset(30);
        }];
        
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            //
            make.centerY.equalTo(self.confirmBtn);
            make.left.equalTo(self.contentView).offset(15);
        }];
        
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            //
            make.bottom.equalTo(self.contentView).offset(-30);
            make.height.mas_offset(44);
            make.left.equalTo(self.contentView).offset(30);
            make.right.equalTo(self.contentView).offset(-30);
        }];
        
        [self setBackView];
    }
    return self;
}
/*
 * - Parameters:
 *   - title: 标题
 *   - selectedStr: 选中日期
 *   - confirmBlock: 确定回调
 *   - cancle: 取消回调
 */
- (void)appearWithTitle:(NSString *)title selectedStr:(NSString *)selectedStr sureAction:(void(^)(NSInteger path,NSString *pathStr))confirmBlock cancleAction:(void(^)(void))cancelBlock{
    self.titleLab.text = title;
    
    [kWindow addSubview:self];
    
    self.confirmBolck = confirmBlock;
    self.cancelBolck = cancelBlock;
    
    if (selectedStr) {
        selectedStr = [selectedStr stringByReplacingOccurrencesOfString:@"年" withString:@"-"];
        selectedStr = [selectedStr stringByReplacingOccurrencesOfString:@"月" withString:@"-"];
        selectedStr = [selectedStr stringByReplacingOccurrencesOfString:@"日" withString:@"-"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [formatter dateFromString:selectedStr];
        [self.datePicker setDate:date];
    }
    
    [self initDateView];
}
- (void)initDateView{
    [self.contentView addSubview:self.datePicker];
    [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(60);
        make.height.mas_offset(200);
    }];
}

- (void)disAppear{
    [self removeFromSuperview];
}

@end
