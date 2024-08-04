//
//  CreateTagsVC.h
//  GoChat
//
//  Created by Autumn on 2021/11/9.
//

#import "DYCollectionViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CreateTagsType) {
    CreateTagsTypeAdd,
    CreateTagsTypeEdit
};

@interface CreateTagsVC : DYCollectionViewController

@property (nonatomic, assign) CreateTagsType type;

@property (nonatomic, copy) NSString *tagName;
@property (nonatomic, assign) int tagId;
@property (nonatomic, strong) NSMutableArray<UserInfo *> *selectedContacts;

@end

NS_ASSUME_NONNULL_END
