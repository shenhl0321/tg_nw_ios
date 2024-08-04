//
//  TransferVC.h
//  GoChat
//
//  Created by Autumn on 2022/1/18.
//

#import "DYTableViewController.h"
#import "TransferObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface TransferVC : DYTableViewController

- (instancetype)initWithChatId:(NSInteger)chatId userid:(NSInteger)userid type:(TransferChatType)type;

@end

NS_ASSUME_NONNULL_END
