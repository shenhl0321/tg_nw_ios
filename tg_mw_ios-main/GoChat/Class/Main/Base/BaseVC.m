//
//  BaseVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/21.
//

#import "BaseVC.h"

@interface BaseVC ()

@property (strong, nonatomic) UIImageView *leftImageV;
@property (strong, nonatomic) UIImageView *rightImageV;

@end

@implementation BaseVC

- (void)dealloc{
    NSLog(@"********** %@被销毁 **********", self.class);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorTextForFFFFFF];
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    
    [self.view addSubview:self.leftImageV];
    [self.view addSubview:self.rightImageV];
    
    [self.leftImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.width.height.mas_offset(140);
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top);
    }];
    
    [self.rightImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.top.right.equalTo(self.view);
        make.width.height.mas_offset(350);
    }];
}

- (void)showLogoUI{
    self.leftImageV.hidden = NO;
    self.rightImageV.hidden = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;//隐藏导航栏 这边在做一下处理。免得别的页面又出来了导致问题
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    
    NSLog(@"*********** - %@ - ***********", self.class);
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
//- (void)searchStyle{
//    self.contentView.frame
//}


- (UIImageView *)leftImageV{
    if (!_leftImageV){
        _leftImageV = [[UIImageView alloc] init];
        _leftImageV.image = [UIImage imageNamed:@"logo_left"];
        _leftImageV.hidden = YES;
    }
    return _leftImageV;
}

- (UIImageView *)rightImageV{
    if (!_rightImageV){
        _rightImageV = [[UIImageView alloc] init];
        _rightImageV.image = [UIImage imageNamed:@"logo_right"];
        _rightImageV.hidden = YES;
    }
    return _rightImageV;
}

@end
