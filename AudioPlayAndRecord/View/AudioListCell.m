//
//  AudioListCell.m
//  MyDemo
//
//  Created by ENIAC on 15/12/25.
//  Copyright © 2015年 yyb. All rights reserved.
//

#import "AudioListCell.h"
#import "UserContext.h"

#define AUDIO_PATH        [NSString stringWithFormat:@"%@/Library/Caches/ghost/audio", NSHomeDirectory()]
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>
#import "amr_wav_converter.h"


#define PATH_OF_FILE      [AUDIO_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",@"audio.text"]]

#define AUDIO_DELETED_PATH [NSString stringWithFormat:@"%@/Library/Caches/ghost/audio/deleted", NSHomeDirectory()]

#define AUDIO_FOBIDDENDELETED_USER_PATH [NSString stringWithFormat:@"%@/Library/Caches/ghost/audio/forbidden/%@/", NSHomeDirectory(),[UserContext sharedContext].user.userId]

//static  double       const  kMediaPlayX = 18.0f;
//static  double       const  kMediaPlayY = 15.0f;

@implementation AudioListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setValueWithfileInfo:(AudioFileInfoModel *)fileInfo{
    self.nameLab.text = fileInfo.name;
    self.sizeLab.text = fileInfo.duration;
    self.durationLab.text = fileInfo.fileSize;
    [self setUploderButtonImageAndTitleWifhFile:fileInfo];
    
//    NSLog(@"filepath======%@",fileInfo.url);
    NSString *fileAbsolutePath;
    
    if (fileInfo.audioSavePath == MSDAudio_FOBIDDENDELETED_USER_PATH) {
        fileAbsolutePath=[AUDIO_FOBIDDENDELETED_USER_PATH stringByAppendingPathComponent:fileInfo.path];
    }else if(fileInfo.audioSavePath == MSDAudio_AUDIO_DELETED_PATH){
        fileAbsolutePath=[AUDIO_DELETED_PATH stringByAppendingPathComponent:fileInfo.path];
    }
//    NSLog(@"fileAbsolutePath%@",fileAbsolutePath);
    
    NSFileManager* manager = [NSFileManager defaultManager];
    RecordView *recordPlayView ;
    if (![manager fileExistsAtPath:fileAbsolutePath]){
        //        self.recordPlayView.bundleFilePath = fileInfo.url;
        recordPlayView =[RecordView initWithUrl:fileInfo.url];
    }else{
        recordPlayView =[RecordView initWithUrl:fileAbsolutePath];
    }
    CGRect frame= recordPlayView.frame;
    frame.size.width  =  173;
    recordPlayView.frame = frame;
    [self.bgView addSubview:recordPlayView];

}
- (void)setUploderButtonImageAndTitleWifhFile:(AudioFileInfoModel *)fileInfo{
    UIImage *imageNor;
    UIImage *imagePress;
    NSString *uploaderstatus;
    switch (fileInfo.uploaderStatus) {
        case MSDAudioDidNotUploader:
        {
            imageNor  = [UIImage imageNamed:@"icon_uploder_nor"];
            imagePress= [UIImage imageNamed:@"icon_uploder_press"];
            uploaderstatus = @"上传中";
            
        }
            break;
        case MSDAudioUploaderSuccess:
        {
            imageNor  = [UIImage imageNamed:@"icon_uploder_nor"];
            imagePress= [UIImage imageNamed:@"icon_uploder_press"];
            uploaderstatus = @"已上传";
        }
            break;
        case MSDAudioUploaderFailed:
        {
            imageNor  = [UIImage imageNamed:@"icon_upfinish_nor"];
            imagePress= [UIImage imageNamed:@"icon_upfinish_press"];
            uploaderstatus = @"重新上传";
        }
            break;
        default:
            break;
    }
    [self.uploderStatusBtn setBackgroundImage:imageNor forState:UIControlStateNormal];
    [self.uploderStatusBtn setBackgroundImage:imagePress forState:UIControlStateHighlighted];
    [self.uploderStatusBtn setTitle:uploaderstatus forState:UIControlStateNormal];
    [self.uploderStatusBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.uploderStatusBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    self.hiddenUploderBtn.hidden = YES;
    
}
//点击到了重新上传的按钮
- (IBAction)reUploder:(UIButton *)sender {

    if (self.reuploderBlock && [sender.titleLabel.text isEqualToString:@"重新上传"]) {
        [self.hiddenUploderBtn setBackgroundImage:[UIImage imageNamed:@"icon_uploder_nor"] forState:0];
        [self.hiddenUploderBtn setBackgroundImage:[UIImage imageNamed:@"icon_uploder_press"] forState:UIControlStateHighlighted];
        [self.hiddenUploderBtn setTitle:@"上传中" forState:UIControlStateNormal];
        [self.hiddenUploderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.hiddenUploderBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        self.reuploderBlock(YES);
        self.hiddenUploderBtn.hidden = NO;
    };
}


@end
