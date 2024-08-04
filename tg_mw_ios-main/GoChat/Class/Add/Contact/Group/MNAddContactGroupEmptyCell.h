//
//  MNAddContactGroupEmptyCell.h
//  BaseChat
//
//  Created by 漫漫人生路 on 2023/3/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNAddContactGroupEmptyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *logoImageV;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabTop;


@end

NS_ASSUME_NONNULL_END
