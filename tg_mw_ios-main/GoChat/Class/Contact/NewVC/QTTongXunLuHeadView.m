//
//  QTTongXunLuHeadView.m
//  BaseChat
//
//  Created by 漫漫人生路 on 2023/3/20.
//

#import "QTTongXunLuHeadView.h"

@interface QTTongXunLuHeadView ()

@end

@implementation QTTongXunLuHeadView

- (IBAction)buttonClick:(UIButton *)sender {
    if (self.chooseBlock){
        self.chooseBlock(sender.tag);
    }
}


@end
