//
//  UILabel+CZReadMore.h
//  GoChat
//
//  Created by mac on 2021/7/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (CZReadMore)
-(void)setReadMoreLabelContentMode;
- (NSArray *)getLinesArrayOfStringInLabel;
@end

NS_ASSUME_NONNULL_END
