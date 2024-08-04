//
//  GC_OtherPhotoCell.m
//  GoChat
//
//  Created by wangfeiPro on 2022/1/7.
//

#import "GC_OtherPhotoCell.h"
#import "PhotoImageView.h"
#import "UIImageView+VideoThumbnail.h"

@implementation GC_OtherPhotoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setData:(NSArray <BlogInfo *>*)arr{
    
    float witdh = (kScreenWidth() - 145 - 20)/3.;
    PhotoImageView *temp = nil;
    for (int i = 0; i < arr.count; i ++) {
        if (i > 2) {
            return;
        }
        PhotoImageView *iv = [[PhotoImageView alloc] init];
        [iv xhq_cornerRadius:6];
        BlogInfo *blog = arr[0];
        if (blog.content.isPhotoContent) {
            iv.photo = blog.content.photos.firstObject;
        } else if (blog.content.isVideoContent) {
            [iv setThumbnailImage:blog.content.video];
        } else {
            [iv reset];
        }
        [self.photoContainView addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            if (temp) {
                make.left.mas_equalTo(temp.mas_right).offset(10);
            }else{
                make.left.mas_equalTo(0);
            }
            make.width.height.mas_equalTo(witdh);
            make.centerY.mas_equalTo(0);
        }];
        temp = iv;
    }
    
    
}

@end
