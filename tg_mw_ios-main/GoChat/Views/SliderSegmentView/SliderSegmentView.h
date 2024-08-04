//
//  SliderSegmentView.h

#import <UIKit/UIKit.h>

@interface SliderSegmentConfig : NSObject
@property(nonatomic,assign) float itemWidth;
@property(nonatomic,strong) UIFont *itemFont;
@property(nonatomic,strong) UIColor *textColor;
@property(nonatomic,strong) UIColor *selectedColor;

@property(nonatomic,assign) float linePercent;
@property(nonatomic,assign) float lineHieght;
@end

@class SliderSegmentView;
@protocol SliderSegmentViewDelegate <NSObject>
@optional
- (void)SliderSegmentDidChanged:(NSInteger)index;
@end

@interface SliderSegmentView : UIView
@property (nonatomic, weak) id<SliderSegmentViewDelegate> delegate;

@property (nonatomic,strong) SliderSegmentConfig *config;
@property (nonatomic) BOOL isAlignmentLeft;//default center

@property (nonatomic,strong) NSArray *titleArray;

@property (nonatomic,readonly) NSInteger currentIndex;

- (void)moveToIndex:(float)index;

@end
