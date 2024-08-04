//
//  MNGroupSentSendVC.h
//  GoChat
//
//  Created by Autumn on 2022/2/22.
//

#import "DYViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class GroupSentMessage;
@interface MNGroupSentSendVC : DYViewController

@property (nonatomic, strong) GroupSentMessage *sent;

@end

NS_ASSUME_NONNULL_END
