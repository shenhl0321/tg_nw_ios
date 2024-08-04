//
//  TransferInfoReceivedView.h
//  GoChat
//
//  Created by Autumn on 2022/1/28.
//

#import "DYView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TransferInfoReceivedView : DYView

@property (nonatomic, copy) dispatch_block_t receivedBlock;
@property (nonatomic, copy) dispatch_block_t refundBlock;

@end

NS_ASSUME_NONNULL_END
