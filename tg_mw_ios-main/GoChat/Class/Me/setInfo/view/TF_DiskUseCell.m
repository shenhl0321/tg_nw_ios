//
//  TF_DiskUseCell.m
//  GoChat
//
//  Created by apple on 2022/2/16.
//

#import "TF_DiskUseCell.h"
#import "TF_DiskCache.h"
@interface TF_DiskUseCell()
/// 内容父空间
@property (nonatomic,strong) UIView *contentV;
/// 进度条
@property (nonatomic, strong) UIProgressView *progressView;
/// 提示文字
@property (nonatomic,strong) UILabel *tipL;
/// 清除按钮
@property (nonatomic,strong) UIButton *clearBtn;
@end

@implementation TF_DiskUseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

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
    [self.contentV addSubview:self.tipL];
    
    UIView *sep = [[UIView alloc] init];
    sep.backgroundColor = XHQHexColor(0xdadada);
    [self.contentV addSubview:sep];
    
    [self.contentV addSubview:self.clearBtn];
    
    [self.contentV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.bottom.mas_equalTo(0);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(15);
        make.height.mas_equalTo(20);
    }];
    
    [self.tipL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.progressView);
        make.top.mas_equalTo(self.progressView.mas_bottom).offset(15);
    }];
    
    [sep mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(1);
        make.top.mas_equalTo(self.tipL.mas_bottom).offset(15);
    }];
    
    [self.clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.mas_equalTo(0);
        make.top.mas_equalTo(sep.mas_bottom);
        make.width.mas_equalTo(140);
        make.height.mas_equalTo(40);
    }];
}

- (void)clearClick{
    //提示用户
    MMPopupItemHandler block = ^(NSInteger index) {
        if(index == 0)
        {
            CGFloat cache = [TF_DiskCache goChatCacheSize];
            NSString *tip;
            if (cache < 0.01) {
                cache *= 1024;
                tip = [NSString stringWithFormat:@"%.2fKB", cache];
            } else {
                tip = [NSString stringWithFormat:@"%.2fMB", cache];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [UserInfo showTips:tp_mainWindow() des:[NSString stringWithFormat:@"共清理%@缓存数据".lv_localized,tip] duration:1];
            });
            [TF_DiskCache goChatCacheClear];
            [self updateTipText];
        }
    };
    NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block),
                       MMItemMake(@"取消".lv_localized, MMItemTypeNormal, block)];
    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示".lv_localized detail:@"是否确定清除应用缓存".lv_localized items:items];
    [view show];
    
    
}

- (void)updateTipText{
    CGFloat mb = [TF_DiskCache freeDiskSpaceInMB] ;
    CGFloat cache = [TF_DiskCache goChatCacheSize];
    CGFloat ratio = cache / mb;
//    if (ratio < 0.001) {
//        ratio = 0.0;
//    }
    self.progressView.progress = ratio;
    NSString *tip;
    if (cache < 0.01) {
        cache *= 1024;
        tip = [NSString stringWithFormat:@"%.2fKB", cache];
    } else {
        tip = [NSString stringWithFormat:@"%.2fMB", cache];
    }
    
    self.tipL.text = [NSString stringWithFormat:@"%@缓存：%@  手机可用空间：%@".lv_localized, localAppName.lv_localized, tip, [TF_DiskCache freeDiskSpaceInGB]];
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

- (UILabel *)tipL{
    if (!_tipL) {
        _tipL = [[UILabel alloc] init];
        _tipL.font = XHQFont(14);
        _tipL.textColor = XHQHexColor(0x666666);
        [self updateTipText];
    }
    return _tipL;
}

- (UIButton *)clearBtn{
    if (!_clearBtn) {
        _clearBtn = [[UIButton alloc] init];
        [_clearBtn addTarget:self action:@selector(clearClick) forControlEvents:UIControlEventTouchUpInside];
        [_clearBtn setTitle:[NSString stringWithFormat:@"清空%@缓存".lv_localized, localAppName.lv_localized] forState:UIControlStateNormal];
        [_clearBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
        _clearBtn.titleLabel.font = XHQFont(15);
    }
    return _clearBtn;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        
        //设置进度条颜色
        _progressView.trackTintColor = [UIColor grayColor];
        //设置进度条上进度的颜色
        _progressView.progressTintColor=[UIColor colorMain];
        _progressView.layer.cornerRadius = 5;
        _progressView.clipsToBounds = YES;
        
    }
    return _progressView;
}
@end
