//
//  SelectMemberSearchView.h
//  GoChat
//
//  Created by Autumn on 2021/11/7.
//

#import "DYView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectMemberSearchView : DYView

@property (nonatomic, assign, getter=isFromGroup) BOOL fromGroup;

@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSArray *groups;

@property (nonatomic, copy, readonly) NSString *keyword;
@property (nonatomic, copy) dispatch_block_t searchBlock;

@end

NS_ASSUME_NONNULL_END
