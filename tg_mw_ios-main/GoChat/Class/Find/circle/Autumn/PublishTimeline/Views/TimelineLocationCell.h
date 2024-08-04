//
//  TimelineLocationCell.h
//  GoChat
//
//  Created by Autumn on 2021/11/17.
//

#import "DYTableViewCell.h"
#import <AMapSearchKit/AMapSearchKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimelineLocationCellItem : DYTableViewCellItem

@property (nonatomic, assign, getter=isSelected) BOOL selected;

@property (nonatomic, strong) AMapPOI *poi;

@property (nonatomic, assign) NSString *city;

@property (nonatomic, assign, getter=isNone) BOOL none;

@end

@interface TimelineLocationCell : DYTableViewCell

@end

NS_ASSUME_NONNULL_END
