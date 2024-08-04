//
//  TfRow.h
//  Coulisse
//
//  Created by XMJ on 2017/8/29.
//  Copyright © 2017年 Coulisse. All rights reserved.
//

#import "MNRow.h"

@interface TfRow : MNRow

//@property (nonatomic, copy) NSString *text;
//@property (nonatomic, copy) NSString *placeholder;

- (instancetype)initWithText:(NSString *)text placeholder:(NSString *)placeholder;

@property (nonatomic, strong) UITextField *tf;

@end
