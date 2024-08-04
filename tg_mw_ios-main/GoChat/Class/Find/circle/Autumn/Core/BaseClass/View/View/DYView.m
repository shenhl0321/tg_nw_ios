//
//  DYView.m
//  ShanghaiCard
//
//  Created by 帝云科技 on 2018/11/2.
//  Copyright © 2018 帝云科技. All rights reserved.
//

#import "DYView.h"

@implementation DYView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self dy_initUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self dy_initUI];
}

- (void)dy_initUI {
    
}

+ (instancetype)loadFromNib {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *name = NSStringFromClass(self.class);
    return [bundle loadNibNamed:name owner:nil options:nil].firstObject;
}

@end
