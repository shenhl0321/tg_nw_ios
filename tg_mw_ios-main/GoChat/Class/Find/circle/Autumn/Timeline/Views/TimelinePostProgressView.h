//
//  TimelinePostProgressView.h
//  GoChat
//
//  Created by Autumn on 2021/12/22.
//

#import "DYView.h"

NS_ASSUME_NONNULL_BEGIN
@class BlogInfo;
@interface TimelinePostProgressView : DYView

@property (nonatomic, strong) BlogInfo *sendingBlog;

@property (nonatomic, copy) dispatch_block_t changedBlock;

@end

NS_ASSUME_NONNULL_END
