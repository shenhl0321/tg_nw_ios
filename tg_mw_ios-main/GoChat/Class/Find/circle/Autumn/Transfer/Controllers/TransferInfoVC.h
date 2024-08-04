//
//  TransferInfoVC.h
//  GoChat
//
//  Created by Autumn on 2022/1/18.
//

#import "DYTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class Transfer;
@interface TransferInfoVC : DYTableViewController

@property (nonatomic, strong) Transfer *transfer;

@property (nonatomic, copy) dispatch_block_t transferStateChanged;

@end

NS_ASSUME_NONNULL_END
