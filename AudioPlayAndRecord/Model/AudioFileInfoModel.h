//
//  AudioFileInfoModel.h
//  MyDemo
//
//  Created by ENIAC on 15/12/25.
//  Copyright © 2015年 yyb. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MSDAudioUploaderStatus)
{
    MSDAudioUploaderSuccess =1,  //上传成功
    MSDAudioDidNotUploader,     // 未上传,正在上传
    MSDAudioUploaderFailed     // 上传失败、重新上传
};

typedef NS_ENUM(NSInteger, MSDAudioSavePath)
{
    MSDAudio_FOBIDDENDELETED_USER_PATH =1,  //不可删除录音路径
    MSDAudio_AUDIO_DELETED_PATH,            //上传成功、可删除录音路径
};

typedef NS_ENUM(NSUInteger, UploadRecordState) {
    UploadRecordStateNotStart = 0,
    UploadRecordStateStart,
    UploadRecordStateEnd
};



@interface AudioFileInfoModel : NSObject<NSCoding>

@property (nonatomic, copy) NSString   *url;      //网络url
@property (strong, nonatomic) NSString *path; //本地路径
@property (strong, nonatomic) NSString *describe; //录音描述
@property (strong, nonatomic) NSString *time; //最后录音时间,yyyy-MM-dd HH:mm:ss

@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *fileTime;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *fileSize;

@property (nonatomic, assign) MSDAudioUploaderStatus uploaderStatus;
@property (nonatomic, assign) MSDAudioSavePath  audioSavePath;
@property (nonatomic, assign) UploadRecordState state;
- (id)description;

@end
