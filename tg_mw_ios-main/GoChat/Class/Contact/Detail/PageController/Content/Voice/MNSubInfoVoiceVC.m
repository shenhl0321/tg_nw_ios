//
//  MNSubInfoVoiceVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/22.
//

#import "MNSubInfoVoiceVC.h"
#import "MNSubInfoVoiceCell.h"
#import "PlayAudioManager.h"

@interface MNSubInfoVoiceVC ()

@end

@implementation MNSubInfoVoiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)initDataCompleteFunc{
    [super initDataCompleteFunc];
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 15;
    }
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"MNSubInfoVoiceCell";
    MNSubInfoVoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[MNSubInfoVoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    MessageInfo *msg = [self.dataArray objectAtIndex:indexPath.row];
    [cell fillDataWithMessage:msg];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageInfo *msg = [self.dataArray objectAtIndex:indexPath.row];
    // 文件

    if(msg.messageType == MessageType_Audio)
    {//语音消息
        AudioInfo *audioInfo = msg.content.audio;
        if(audioInfo != nil)
        {
            if(!audioInfo.isAudioDownloaded)
            {//未下载，启动下载
                [UserInfo showTips:nil des:@"语音下载中...".lv_localized];
                if(![[TelegramManager shareInstance] isFileDownloading:audioInfo.audio._id type:FileType_Message_Audio]
                   && audioInfo.audio.remote.unique_id.length > 1)
                {
                    NSString *key = [NSString stringWithFormat:@"%ld_%ld", self.userInfo._id, msg._id];
                    [[TelegramManager shareInstance] DownloadFile:key fileId:audioInfo.audio._id download_offset:0 type:FileType_Message_Audio];
                }
            }
            else
            {//播放
                [[PlayAudioManager sharedPlayAudioManager] playAudio:msg.content.audio.localAudioPath chatId:self.userInfo._id msgId:msg._id];
//                                [self.tableView reloadData];
            }
        }
    }else if(msg.messageType == MessageType_Voice)
    {//语音消息
        VoiceInfo *voiceInfo = msg.content.voice_note;
        if(voiceInfo != nil)
        {
            if(!voiceInfo.isAudioDownloaded)
            {//未下载，启动下载
                [UserInfo showTips:nil des:@"语音下载中...".lv_localized];
                if(![[TelegramManager shareInstance] isFileDownloading:voiceInfo.voice._id type:FileType_Message_Voice]
                   && voiceInfo.voice.remote.unique_id.length > 1)
                {
                    NSString *key = [NSString stringWithFormat:@"%ld_%ld", self.userInfo._id, msg._id];
                    [[TelegramManager shareInstance] DownloadFile:key fileId:voiceInfo.voice._id download_offset:0 type:FileType_Message_Voice];
                }
            }
            else
            {//播放
                [[PlayAudioManager sharedPlayAudioManager] playAudio:msg.content.voice_note.localAudioPath chatId:self.userInfo._id msgId:msg._id];
//                                [self.tableView reloadData];
            }
        }
    }
}
-(UITableViewStyle)style{
    return UITableViewStylePlain;
}

@end
