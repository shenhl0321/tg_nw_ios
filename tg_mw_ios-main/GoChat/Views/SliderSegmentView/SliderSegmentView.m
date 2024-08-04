//
//  SliderSegmentView.m

#import "SliderSegmentView.h"

@implementation SliderSegmentConfig
-(id)init
{
    self = [super init];
    if(self)
    {
        _itemWidth = 0;
        _itemFont = [UIFont boldSystemFontOfSize:17];
        _textColor = [UIColor blackColor];
        _selectedColor = RGB(63, 139, 247);
        _linePercent = 0.6;
        _lineHieght = 2;
    }
    return self;
}
@end

@interface SliderSegmentView()
@property(nonatomic,strong) UIView *line;
@end

@implementation SliderSegmentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
    }
    return self;
}

- (void)setTitleArray:(NSArray *)titleArray
{
    _titleArray = titleArray;
    
    float x = 0;
    float y = 0;
    float width = _config.itemWidth;
    float height = self.frame.size.height;
    for (int i=0; i<titleArray.count; i++)
    {
        x = _config.itemWidth*i;
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(x, y, width, height)];
        btn.tag = 100+i;
        [btn setTitle:titleArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:_config.textColor forState:UIControlStateNormal];
        btn.titleLabel.font = _config.itemFont;
        if(self.isAlignmentLeft)
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btn addTarget:self action:@selector(itemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        if(i==0)
        {
            [btn setTitleColor:_config.selectedColor forState:UIControlStateNormal];
            _currentIndex = 0;
            if(self.isAlignmentLeft)
            {
                self.line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - _config.lineHieght, _config.itemWidth*_config.linePercent, _config.lineHieght)];
            }
            else
            {
                self.line = [[UIView alloc] initWithFrame:CGRectMake(_config.itemWidth*(1-_config.linePercent)/2.0, CGRectGetHeight(self.frame) - _config.lineHieght, _config.itemWidth*_config.linePercent, _config.lineHieght)];
            }

            _line.backgroundColor = _config.selectedColor;
            [self addSubview:_line];
        }
    }
}

- (void)itemButtonClicked:(UIButton*)btn
{
    _currentIndex = btn.tag-100;
    [self changeItemColor:_currentIndex];
    [self changeLine:_currentIndex];
    
    if([self.delegate respondsToSelector:@selector(SliderSegmentDidChanged:)])
    {
        [self.delegate SliderSegmentDidChanged:_currentIndex];
    }
}

- (void)changeItemColor:(NSInteger)index
{
    for (int i=0; i<_titleArray.count; i++)
    {
        UIButton *btn = (UIButton*)[self viewWithTag:i+100];
        [btn setTitleColor:_config.textColor forState:UIControlStateNormal];
        if(btn.tag == index+100)
        {
            [btn setTitleColor:_config.selectedColor forState:UIControlStateNormal];
        }
    }
}

- (void)changeLine:(float)index
{
    CGRect rect = _line.frame;
    if(self.isAlignmentLeft)
    {
        rect.origin.x = index*_config.itemWidth;
    }
    else
    {
        rect.origin.x = index*_config.itemWidth + _config.itemWidth*(1-_config.linePercent)/2.0;
    }
    _line.frame = rect;
}

- (void)moveToIndex:(float)x
{
    _currentIndex = x;
    [self changeLine:x];
    [self changeItemColor:x];
}

@end
