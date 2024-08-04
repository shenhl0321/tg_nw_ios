//
//  AddressItemCell.h
//  GoChat
//
//  Created by Demi on 2021/9/5.
//

#import <UIKit/UIKit.h>
@class AddressItemModel,AddressItemCell;
NS_ASSUME_NONNULL_BEGIN

@protocol AddressItemCellDelegate <NSObject>

- (void)addContact_click:(AddressItemCell *)cell;

@end

@interface AddressItemCell : UITableViewCell

@property (nonatomic, weak) id <AddressItemCellDelegate> delegate;

@property (nonatomic, assign) NSInteger indexpath;

@property (nonatomic, strong) AddressItemModel *model;

@end

NS_ASSUME_NONNULL_END
