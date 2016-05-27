//
//  PRNAmrRecorder.m
//  AMRMedia
//
//  Created by yyb on 14/11/21.
//  Copyright (c) 2014年 prinsun. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "PRNAmrRecorder.h"
#import "amr_wav_converter.h"
#import <UIKit/UIKit.h>

static PRNAmrRecorder *_instance;

@interface PRNAmrRecorder () <AVAudioRecorderDelegate>
{
    AVAudioRecorder *audioRecorder;
    
    NSURL *tempRecordFileURL;
    NSURL *currentRecordFileURL;

    dispatch_source_t timer;
    
    NSString            *               _relativelyPath;
}

/**
 *  是否正在录音
 */
@property (nonatomic, assign)  BOOL isRecording;

@end
@implementation PRNAmrRecorder

+ (instancetype)manager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance) {
            _instance = [self new];
            [_instance p_setupAudioRecorder];
        }
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance) {
            _instance = [super allocWithZone:zone];
            
        }
    });
    return _instance;
}

- (void)p_setupAudioRecorder
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *recordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"records"];
    
    if (![fileManager fileExistsAtPath:recordFilePath]) {
        [fileManager createDirectoryAtPath:recordFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *recordFile = [recordFilePath stringByAppendingPathComponent:@"rec.wav"];
    tempRecordFileURL = [NSURL URLWithString:recordFile];
    
    NSDictionary *recordSetting = @{ AVSampleRateKey        : @8000.0,                      // 采样率
                                     AVFormatIDKey          : @(kAudioFormatLinearPCM),     // 音频格式
                                     AVLinearPCMBitDepthKey : @16,                          // 采样位数 默认 16
                                     AVNumberOfChannelsKey  : @1                            // 通道的数目
                                     };
    
    // AVLinearPCMIsBigEndianKey    大端还是小端 是内存的组织方式
    // AVLinearPCMIsFloatKey        采样信号是整数还是浮点数
    //     AVEncoderAudioQualityKey     音频编码质量
    
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:tempRecordFileURL
                                                settings:recordSetting
                                                   error:nil];
    
    audioRecorder.delegate = self;
    audioRecorder.meteringEnabled = YES;
}


- (void)recordWithURL:(NSURL *)fileUrl RelativelyPath:(NSString *)path
{
    _isRecording     =[audioRecorder isRecording];
    if ([audioRecorder isRecording]) return;
    
    _relativelyPath = path;
    [self p_prepareRecordFileURL:fileUrl];
    
    [audioRecorder prepareToRecord];
    
    //开始录音
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
#pragma mark--加大声音
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
     AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
/*******/
    
    [audioRecorder record];
    self.isRecording = YES;
    
    [self p_createPickSpeakPowerTimer];
    
}

-(NSString *)getRelativelyPath{
    if (self.isRecording) {
        return _relativelyPath;
    }
    
    return nil;
}

- (void)p_prepareRecordFileURL:(NSURL *)fileUrl
{
    currentRecordFileURL = fileUrl;
    
    NSString *wavFileUrlString = [fileUrl.absoluteString stringByAppendingString:@".wav"];
    
#pragma mark -- 删除.wav的文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:wavFileUrlString]) {
        [fileManager removeItemAtPath:wavFileUrlString error:nil];
    }
    NSString *recordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"records"];
    
    NSString *recordFile = [recordFilePath stringByAppendingPathComponent:@"rec.wav"];
    if ([fileManager fileExistsAtPath:recordFile]) {
        if ([fileManager removeItemAtPath:recordFile error:nil]) {
            NSLog(@"deleted caches success");
        };
    }
    
}

- (void)p_createPickSpeakPowerTimer
{
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
//    每0.01秒触发一次，误差在纳秒
    __weak __typeof(self) weakSelf = self;
    
    dispatch_source_set_event_handler(timer, ^{
        __strong __typeof(weakSelf) _self = weakSelf;
        
        if ([_self.delegate respondsToSelector:@selector(recorder:didPickSpeakPower:andTime:)]) {
            [_self->audioRecorder updateMeters];
            double currentTime = _self->audioRecorder.currentTime;

            
            double lowPassResults = pow(10, (0.05 * [_self->audioRecorder peakPowerForChannel:0]));
            [_self.delegate recorder:_self didPickSpeakPower:lowPassResults andTime:currentTime];
        }

    });
    
    dispatch_resume(timer);
}


- (void)pause{
    if ([audioRecorder isRecording])  { [audioRecorder pause];  }
}
- (void)continueRecord{
    if (![audioRecorder isRecording]) { [audioRecorder record]; }
}

- (void)stop;
{
    if (!_isRecording) return;
    
     [audioRecorder stop];
    
    if (timer) {
        dispatch_source_cancel(timer);
        timer = NULL;
    }

    self.isRecording = NO;

}

- (void)setSpeakMode:(BOOL)speakMode
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
        AVAudioSessionPortOverride portOverride = speakMode ? AVAudioSessionPortOverrideSpeaker : AVAudioSessionPortOverrideNone;
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:portOverride error:nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UInt32 route = speakMode ? kAudioSessionOverrideAudioRoute_Speaker : kAudioSessionOverrideAudioRoute_None;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(route), &route);
#pragma clang diagnostic pop
        
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - AVAudioRecorderDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
   int frames = wave_file_to_amr_file([tempRecordFileURL.absoluteString cStringUsingEncoding:NSASCIIStringEncoding],
                          [currentRecordFileURL.absoluteString cStringUsingEncoding:NSASCIIStringEncoding], 1, 16);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *recordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"records"];
    
    NSString *recordFile = [recordFilePath stringByAppendingPathComponent:@"rec.wav"];
    if ([fileManager fileExistsAtPath:recordFile]) {
        if ([fileManager removeItemAtPath:recordFile error:nil]) {
            NSLog(@"deleted caches success");
        };
    }
    
    if ([self.delegate respondsToSelector:@selector(recorder:didRecordWithFile:)]) {
        
        PRNAmrFileInfo *recFileInfo = [[PRNAmrFileInfo alloc] init];
        recFileInfo.fileUrl = currentRecordFileURL;
        recFileInfo.fileSize = [fileManager attributesOfItemAtPath:currentRecordFileURL.path error:nil].fileSize;
        recFileInfo.duration = (double)frames * 20.0 / 1000.0;
        
        [self.delegate recorder:self didRecordWithFile:recFileInfo];
    }
    self.isRecording = NO;
    
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
    if ([self.delegate respondsToSelector:@selector(recorderHasBeInterpurt)]) {
        [self.delegate recorderHasBeInterpurt];
    }
}
@end

@implementation PRNAmrFileInfo @end
