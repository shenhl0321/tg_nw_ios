//
//  GC_ExpressionDetailTopView.h
//  GoChat
//
//  Created by wangfeiPro on 2021/12/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GC_ExpressionDetailTopView : UIView

@property(nonatomic, strong) UIImageView *headerImageV;


@property(nonatomic, strong) UILabel *titleLab;
@property(nonatomic, strong) UILabel *numLab;

@property(nonatomic, strong) UIButton *menuBtn;

@property(nonatomic, strong) UILabel *desLab;
@property(nonatomic, strong) UILabel *lineLab;

@end

NS_ASSUME_NONNULL_END
