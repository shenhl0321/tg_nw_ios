//
//  SelectCNAreasCell.h
//  GoChat
//
//  Created by Autumn on 2022/3/12.
//

#import "DYTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectCNAreasCellItem : DYTableViewCellItem

@property (nonatomic, assign, getter=isSelected) BOOL selected;

@end

@interface SelectCNAreasCell : DYTableViewCell

@end

NS_ASSUME_NONNULL_END
