//
//  ChatSearchBarView.m
//  GoChat
//
//  Created by wangyutao on 2021/1/18.
//

#import "ChatSearchBarView.h"

@implementation ChatSearchBarView

- (IBAction)click_search:(id)sender
{
    if([self.delegate respondsToSelector:@selector(ChatSearchBarView_Search:)])
    {
        [self.delegate ChatSearchBarView_Search:self];
    }
}

- (IBAction)click_scan:(id)sender
{
    if([self.delegate respondsToSelector:@selector(ChatSearchBarView_Scan:)])
    {
        [self.delegate ChatSearchBarView_Scan:self];
    }
}

@end
