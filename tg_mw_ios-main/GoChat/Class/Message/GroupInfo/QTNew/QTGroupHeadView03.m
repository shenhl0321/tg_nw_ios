//
//  QTGroupHeadView03.m
//  BaseChat
//
//  Created by 漫漫人生路 on 2023/4/7.
//

#import "QTGroupHeadView03.h"

@interface QTGroupHeadView03 ()

@end

@implementation QTGroupHeadView03

- (void)buttonClick:(UIButton *)sender{
    NSInteger index = sender.tag - 100;
    if (self.chooseBlock){
        self.chooseBlock(index);
    }
}

@end
