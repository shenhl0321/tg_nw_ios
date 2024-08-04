//
//  ChatMultiSelOptToolView.m
//  GoChat
//
//  Created by wangyutao on 2021/5/15.
//

#import "ChatMultiSelOptToolView.h"

@implementation ChatMultiSelOptToolView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = HEX_COLOR(@"#F1F4F3");
}

- (void)setChatInfo:(ChatInfo *)chatInfo{
    _chatInfo = chatInfo;
    self.forwordBtn.hidden = chatInfo.isSecretChat;
}

- (IBAction)click_forword:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(ChatMultiSelOptToolView_Forword)])
    {
        [self.delegate ChatMultiSelOptToolView_Forword];
    }
}

- (IBAction)click_fov:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(ChatMultiSelOptToolView_Fov)])
    {
        [self.delegate ChatMultiSelOptToolView_Fov];
    }
}

- (IBAction)click_revoke:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(ChatMultiSelOptToolView_Revoke)])
    {
        [self.delegate ChatMultiSelOptToolView_Revoke];
    }
}

- (IBAction)click_delete:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(ChatMultiSelOptToolView_Delete)])
    {
        [self.delegate ChatMultiSelOptToolView_Delete];
    }
}

@end
