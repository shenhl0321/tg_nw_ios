//
//  MNContactDetailSearchLayout.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/22.
//

#import "MNContactDetailSearchLayout.h"

@implementation MNContactDetailSearchLayout

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    if (attributes==nil) {
        return nil;
    }
    if (attributes.count == 0) {
        return attributes;
    }
    UICollectionViewLayoutAttributes *firstLayoutAttributes = attributes[0];
    firstLayoutAttributes.frame = CGRectMake(self.sectionInset.left, firstLayoutAttributes.frame.origin.y, firstLayoutAttributes.frame.size.width, firstLayoutAttributes.frame.size.height);
   
    for(int i = 1; i < [attributes count]; ++i) {
        
        //当前attributes
        UICollectionViewLayoutAttributes *currentLayoutAttributes = attributes[i];
        if (currentLayoutAttributes.size.height> 50) {
            currentLayoutAttributes.frame = CGRectMake(0, 0, currentLayoutAttributes.size.width, currentLayoutAttributes.size.height);
            continue;
        }
        //上一个attributes
        UICollectionViewLayoutAttributes *prevLayoutAttributes = attributes[i - 1];
        //我们想设置的最大间距，可根据需要改
        NSInteger maximumSpacing = self.maximumSpacing;
        //前一个cell的最右边
        NSInteger origin = CGRectGetMaxX(prevLayoutAttributes.frame);
        //如果当前一个cell的最右边加上我们想要的间距加上当前cell的宽度依然在contentSize中，我们改变当前cell的原点位置
        //不加这个判断的后果是，UICollectionView只显示一行，原因是下面所有cell的x值都被加到第一行最后一个元素的后面了
        if(origin + maximumSpacing + currentLayoutAttributes.frame.size.width < self.collectionViewContentSize.width - self.sectionInset.left) {
            CGRect frame = currentLayoutAttributes.frame;
            frame.origin.x = origin + maximumSpacing;
            frame.origin.y = prevLayoutAttributes.frame.origin.y;
            currentLayoutAttributes.frame = frame;
            NSLog(@"frame %d --- %@",i,NSStringFromCGRect(frame));
        }else{
            CGRect frame = currentLayoutAttributes.frame;
//            frame.origin.x = origin + maximumSpacing;
            frame.origin.x = self.sectionInset.left;
            frame.origin.y = CGRectGetMaxY(prevLayoutAttributes.frame) + self.minimumLineSpacing;
            currentLayoutAttributes.frame = frame;
            NSLog(@"frame %d --- %@",i,NSStringFromCGRect(frame));
            
        }
    }
    
    return [self deepCopyWithArray:attributes];
}

- (NSArray *)deepCopyWithArray:(NSArray *)array
{
    NSMutableArray *copys = [NSMutableArray arrayWithCapacity:array.count];
    
    for (UICollectionViewLayoutAttributes *attris in array) {
        [copys addObject:[attris copy]];
    }
    return copys;
}

@end
