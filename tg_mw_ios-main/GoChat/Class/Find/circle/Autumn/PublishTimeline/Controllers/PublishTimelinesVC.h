//
//  PublishTimelinesVC.h
//  GoChat
//
//  Created by Autumn on 2022/1/5.
//

#import "DYCollectionViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class HXPhotoManager;
@interface PublishTimelinesVC : DYCollectionViewController

@property (nonatomic, strong) HXPhotoManager *photoManager;

@end

NS_ASSUME_NONNULL_END
