//
//  MNChatViewController+VideoPlayer.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/26.
//

#import "MNChatViewController.h"
#import "ZFPlayer.h"
#import "ZFAVPlayerManager.h"
#import "ZFPlayerControlView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNChatViewController (VideoPlayer)
@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) ZFPlayerControlView *controlView;

- (void)setupPlayerWithScrollView:(UIScrollView *)scrollView;

- (void)prepareToPlay;

- (void)playTheVideoAtIndexPath:(NSIndexPath *)indexPath scrollAnimated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
