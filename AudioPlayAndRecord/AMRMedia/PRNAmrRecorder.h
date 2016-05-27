//
//  PRNAmrRecorder.h
//  AMRMedia
//
//  Created by yyb on 14/11/21.
//  Copyright (c) 2014年 prinsun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PRNAmrRecorderDelegate;

/**
 *  AMR 录音器
 */
@interface PRNAmrRecorder : NSObject

+ (instancetype)manager;
/**
 *  开始录音
 *
 *  @param fileUrl 录音要保存的路径
 */
- (void)recordWithURL:(NSURL *)fileUrl RelativelyPath:(NSString *)path;

-(NSString *)getRelativelyPath;
/**
 *  暂停录音
 */
- (void)pause;
/**
 *  继续录音
 */
- (void)continueRecord;
/**
 *  结束录音
 */
- (void)stop;


/**
 *  是否正在录音
 */
@property (nonatomic, assign , readonly)  BOOL isRecording;


/**
 *  使用免提, 还是耳机线进行录制
 *
 *  @param speakMode 是否使用免提录制
 */
- (void)setSpeakMode:(BOOL)speakMode;



/**
 *  录音器委托
 */
@property (nonatomic, weak) id<PRNAmrRecorderDelegate> delegate;


@end




/**
 *  AMR 文件信息
 */
@interface PRNAmrFileInfo  : NSObject

/**
 *  文件路径
 */
@property (nonatomic, copy) NSURL *fileUrl;

/**
 *  文件时间, 单位秒
 */
@property (nonatomic, assign) NSTimeInterval duration;

/**
 *  文件大小
 */
@property (nonatomic, assign) unsigned long long fileSize;





@end




/**
 *  录音器委托
 */
@protocol PRNAmrRecorderDelegate <NSObject>
@optional

/**
 *  录音完毕的回调
 *
 *  @param aRecorder 录音器
 *  @param fileUrl   产生的录音文件
 */
- (void)recorder:(PRNAmrRecorder *)aRecorder didRecordWithFile:(PRNAmrFileInfo *)fileInfo;
/**
 *  录音被迫中断
 */
- (void)recorderHasBeInterpurt;

/**
 *  录音时, 语音大小值,录音时间
 *
 *  @param aRecorder 录音器
 *  @param power     音量大小 (0f - 1f)
 *  @param currentTime     录音时间
 */
- (void)recorder:(PRNAmrRecorder *)aRecorder didPickSpeakPower:(float)power andTime:(double)currentTime;

@end
