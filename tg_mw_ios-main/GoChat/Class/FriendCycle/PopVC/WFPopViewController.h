//
//  WFPopViewController.h
//  MyTestDemo
//
//  Created by 吴亮 on 2021/10/8.
//  Copyright © 2021 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WFPopViewController : UIViewController

@property (nonatomic, copy) dispatch_block_t reportBlock;
@property (nonatomic, copy) dispatch_block_t blockBlock;

@end

NS_ASSUME_NONNULL_END
