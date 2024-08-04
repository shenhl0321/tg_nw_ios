//
//  TF_MemoryUseSettingCell.m
//  GoChat
//
//  Created by apple on 2022/2/16.
//

#import "TF_MemoryUseSettingCell.h"
#import "GC_DataSetInfo.h"
@interface TF_MemoryUseSettingCell ()
/// 内容父空间
@property (nonatomic,strong) UIView *contentV;
/// 进度条
@property (nonatomic, strong) UIProgressView *progressView;
/// 可选择项
@property (nonatomic,strong) NSArray *titles;
/// <#code#>
@property (nonatomic,strong) NSMutableArray<UILabel *> *titleLs;
@end

@implementation TF_MemoryUseSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor colorForF5F9FA];
        self.contentView.backgroundColor = [UIColor colorForF5F9FA];
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI{
    [self.contentView addSubview:self.contentV];
    [self.contentV addSubview:self.progressView];
    
    
    
    [self.contentV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.bottom.mas_equalTo(0);
    }];
    
    CGFloat gap = 0;
    CGFloat progressW = SCREEN_WIDTH - 20 - 20;
    CGFloat width = (progressW - (self.titles.count - 1) * gap) / self.titles.count;
    CGFloat height = 40;
    
    for (int i = 0; i<self.titles.count; i++) {
        UILabel *nameL = [[UILabel alloc] init];
        [self.contentV addSubview:nameL];
        nameL.text = self.titles[i];
        
        [self.titleLs addObject:nameL];
        
        CGFloat ratio = (CGFloat)i / (CGFloat)(self.titles.count - 1);
        CGFloat centerX = 10 + ratio * progressW;
        CGFloat left = centerX - width * 0.5;
        if (i == 0) {
            left += 15;
        } else if (i == self.titles.count - 1){
            left -= 15;
        }
        
        nameL.textAlignment = NSTextAlignmentCenter;
        nameL.textColor = XHQHexColor(0x333333);
        nameL.font = XHQFont(15);
        
        [nameL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(left);
            make.height.mas_equalTo(height);
            make.width.mas_equalTo(width);
            make.bottom.mas_equalTo(self.progressView.mas_top);
        }];
        nameL.tag = i;
        MJWeakSelf
        [nameL xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            NSInteger index = gestureRecoginzer.view.tag;
            CGFloat ratio = (CGFloat)index / (CGFloat)(weakSelf.titles.count - 1);
            weakSelf.progressView.progress = ratio;
            
            weakSelf.model.cacheTime = index;
            
            [GC_DataSetInfo saveUserDataSetInfo:weakSelf.setData];
        }];
    }
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(-35);
        make.height.mas_equalTo(2);
    }];
}

- (void)setModel:(GC_MemoryUse *)model{
    _model = model;
    NSInteger index = model.cacheTime;
    
    CGFloat ratio = (CGFloat)index / (CGFloat)(self.titles.count - 1);
    self.progressView.progress = ratio;
}

- (NSMutableArray<UILabel *> *)titleLs{
    if (!_titleLs) {
        _titleLs = [NSMutableArray array];
    }
    return _titleLs;
}

- (UIView *)contentV{
    if (!_contentV) {
        _contentV = [[UIView alloc] init];
        _contentV.layer.cornerRadius = 8;
        _contentV.clipsToBounds = YES;
        _contentV.backgroundColor = [UIColor whiteColor];
    }
    return _contentV;
}

- (NSArray *)titles{
    if (!_titles) {
        _titles = @[@"3天".lv_localized, @"1周".lv_localized, @"1个月".lv_localized, @"永久".lv_localized];
    }
    return _titles;
}


- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        //设置进度条颜色
        _progressView.trackTintColor = [UIColor grayColor];
        //设置进度条上进度的颜色
        _progressView.progressTintColor=[UIColor colorMain];
        _progressView.clipsToBounds = YES;
        
    }
    return _progressView;
}
@end
