//
//  UIImageView+VideoThumbnail.m
//  GoChat
//
//  Created by Autumn on 2021/12/25.
//

#import "UIImageView+VideoThumbnail.h"
#import "VideoThumbnailManager.h"

@implementation UIImageView (VideoThumbnail)

- (void)setThumbnailImage:(VideoInfo *)video {
    [self setThumbnailImage:video placeholder:[UIImage imageNamed:@"image_default_2"]];
}

- (void)setThumbnailImage:(VideoInfo *)video placeholder:(UIImage *)placeholder {
    self.image = placeholder;
    self.videoId = video.video._id;
    @weakify(self);
    [VideoThumbnailManager.manager thumbnailForVideo:video result:^(UIImage * _Nullable thumbnail) {
        @strongify(self);
        if (self.videoId == video.video._id) {
            self.image = thumbnail;
        }
    }];
}

- (void)setLocalThumbnailImage:(VideoInfo *)video {
    [self setLocalThumbnailImage:video placeholder:[UIImage imageNamed:@"image_default_2"]];
}

- (void)setLocalThumbnailImage:(VideoInfo *)video placeholder:(UIImage *)placeholder {
    self.image = placeholder;
    UIImage *image = [VideoThumbnailManager.manager localThumbnailForVideoName:video.file_name];
    if (image) {
        self.image = image;
    }
}


- (long)videoId {
    return [objc_getAssociatedObject(self, _cmd) longValue];
}

- (void)setVideoId:(long)videoId {
    objc_setAssociatedObject(self, @selector(videoId), @(videoId), OBJC_ASSOCIATION_ASSIGN);
}


@end
