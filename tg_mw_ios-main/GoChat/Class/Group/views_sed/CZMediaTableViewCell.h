//
//  CZMediaTableViewCell.h
//  GoChat
//
//  Created by mac on 2021/7/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CZMediaTableViewCellDelegate <NSObject>

- (void)collectioncellClickWtihArray:(NSArray *)arr withIndex:(int)cursel;

@end

@interface CZMediaTableViewCell : UITableViewCell
@property (nonatomic,weak) id<CZMediaTableViewCellDelegate>delegate;
@property (nonatomic, strong) ChatInfo *chatInfo;
@property (nonatomic,strong) NSMutableArray *soureArray;
/// <#code#>
@property (nonatomic,assign) long startId;

/// 类型 1-媒体 5-gif
@property (nonatomic,assign) NSInteger type;

/// <#code#>
@property (nonatomic,copy) void(^startLoadCall)(void);

@end

NS_ASSUME_NONNULL_END
