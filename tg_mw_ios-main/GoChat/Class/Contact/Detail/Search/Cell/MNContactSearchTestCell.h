//
//  MNContactSearchTestCell.h
//  GoChat
//
//  Created by Autumn on 2022/3/14.
//

#import "DYTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNContactSearchTestCellItem : DYTableViewCellItem

@property (nonatomic, strong) MessageInfo *msg;
@property (nonatomic, copy) NSString *keyword;

@end

@interface MNContactSearchTestCell : DYTableViewCell

@end

NS_ASSUME_NONNULL_END
