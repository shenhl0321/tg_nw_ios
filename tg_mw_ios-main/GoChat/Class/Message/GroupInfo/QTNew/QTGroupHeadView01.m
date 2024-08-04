//
//  QTGroupHeadView01.m
//  BaseChat
//
//  Created by 漫漫人生路 on 2023/4/7.
//

#import "QTGroupHeadView01.h"

@interface QTGroupHeadView01 ()

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) NSMutableArray *viewsArr;
@property (weak, nonatomic) IBOutlet UILabel *numLab;

@end

@implementation QTGroupHeadView01

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        [self initUI];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder{
    if (self = [super initWithCoder:coder]){
        [self initUI];
    }
    return self;
}
- (void)setPersonNum:(NSInteger)personNum{
    _personNum = personNum;
    
    self.numLab.text = [NSString stringWithFormat:@"%ld", personNum];
}
- (void)setDataArr:(NSArray *)dataArr{
    _dataArr = dataArr;
    
    [self initUI];
}

- (void)initUI{
    for (UIView *view in self.viewsArr) {
        [view removeFromSuperview];
    }
    [self.viewsArr removeAllObjects];
    
    NSInteger count = 7;
    CGFloat space = 10;
    CGFloat left_W = 20;
    CGFloat right_W = left_W;
    CGFloat view_W = (SCREEN_WIDTH-left_W-right_W-(count-1)*space)/count;
    CGFloat view_H = view_W;
    
    for (int i=0; i<self.dataArr.count; i++) {
        [self addViewFrame:CGRectMake(left_W+(i%count)*(view_W+space), (i/count)*(view_H+space), view_W, view_H) Index:i];
    }
}
- (void)addViewFrame:(CGRect)frame Index:(NSInteger)index{
    CGFloat cellWidth = CGRectGetWidth(frame);
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.clipsToBounds = YES;
    view.layer.cornerRadius = cellWidth/2;
    view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *avatarImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    avatarImageV.contentMode = UIViewContentModeScaleAspectFill;
    NSObject *detailModel = self.dataArr[index];
    if([detailModel isKindOfClass:[GroupMemberInfo class]]){
        GroupMemberInfo *info = (GroupMemberInfo *)detailModel;
        UserInfo *user = [[TelegramManager shareInstance] contactInfo:info.user_id];
        if(user != nil)
        {
            if(user.profile_photo != nil)
            {
                if(!user.profile_photo.isSmallPhotoDownloaded && user.profile_photo.small.remote.unique_id.length > 1){
                    [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", user._id] fileId:user.profile_photo.fileSmallId download_offset:0 type:FileType_Photo];
                    //本地头像
                    avatarImageV.image = nil;
                    unichar text = [@" " characterAtIndex:0];
                    if(user.displayName.length>0)
                    {
                        text = [[user.displayName uppercaseString] characterAtIndex:0];
                    }
                    [UserInfo setColorBackgroundWithView:avatarImageV withSize:CGSizeMake(cellWidth, cellWidth) withChar:text];
                }else{
                    [UserInfo cleanColorBackgroundWithView:avatarImageV];
                    avatarImageV.image = [UIImage imageWithContentsOfFile:user.profile_photo.localSmallPath];
                }
            }else{
                //本地头像
                avatarImageV.image = nil;
                unichar text = [@" " characterAtIndex:0];
                if(user.displayName.length>0)
                {
                    text = [[user.displayName uppercaseString] characterAtIndex:0];
                }
                [UserInfo setColorBackgroundWithView:avatarImageV withSize:CGSizeMake(cellWidth, cellWidth) withChar:text];
            }
        }else{
            NSString *titleStr = [NSString stringWithFormat:@"u%ld", info.user_id];
            //本地头像
            avatarImageV.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(titleStr.length>0)
            {
                text = [[titleStr uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:avatarImageV withSize:CGSizeMake(cellWidth, cellWidth) withChar:text];
        }
    }else if([detailModel isKindOfClass:[MessageInfo class]]){
        NSLog(@"头像类型 - 2");
    }else if([detailModel isKindOfClass:[NSString class]]){
        NSLog(@"头像类型 - 3");
        if([@"add" isEqualToString:(NSString *)detailModel])
        {
//            [UserInfo cleanColorBackgroundWithView:_headerImageView];
            avatarImageV.image = [UIImage imageNamed:@"icon_add"];
//            _userNameLabel.text = @"   ";
        }
        if([@"delete" isEqualToString:(NSString *)detailModel])
        {
//            [UserInfo cleanColorBackgroundWithView:_headerImageView];
            avatarImageV.image = [UIImage imageNamed:@"icon_delete"];
//            _userNameLabel.text = @"   ";
        }
    }
    [view addSubview:avatarImageV];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cellWidth, cellWidth)];
    button.tag = 100+index;
    [view addSubview:button];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.viewsArr addObject:view];
    [self.backView addSubview:view];
}
- (void)buttonClick:(UIButton *)sender{
    NSInteger index = sender.tag - 100;
    if (self.chooseBlock){
        self.chooseBlock(index);
    }
}
- (NSMutableArray *)viewsArr{
    if (!_viewsArr){
        _viewsArr = [[NSMutableArray alloc] init];
    }
    return _viewsArr;
}

@end
