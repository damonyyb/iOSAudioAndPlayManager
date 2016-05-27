//
//  RecordView.m
//  LayoutDemo
//
//  Created by 科比 布莱恩特 on 15/12/16.
//  Copyright © 2015年 mesada. All rights reserved.
//

#import "RecordView.h"
#import "PRNAmrPlayer.h"
#import "amr_wav_converter.h"
#import "AFNetworking.h"

#define AUDIO_DELETED_PATH [NSString stringWithFormat:@"%@/Library/Caches/ghost/audio/deleted", NSHomeDirectory()]
#define GHOSTPLAYSTART @"ghostTask.amrpaly.start"

typedef void(^CompletedBlock)(NSError* error);

typedef NS_ENUM(NSInteger, RECORDPLAYSTATUS) {
    RECORDPLAYSTATUS_Unknown = 0,
    RECORDPLAYSTATUS_Prepared,
    RECORDPLAYSTATUS_Playing,
    RECORDPLAYSTATUS_Stop,
    RECORDPLAYSTATUS_Pause
};

static RecordView *_instance;




@interface RecordView() {
    CAShapeLayer *_shapeLayer;
    RECORDPLAYSTATUS status;
    BOOL _isPlay;
    NSTimer *_timer;
    NSInteger _totalTime;
    NSInteger _playNum;
    AVAudioPlayer *_audioPlayer;
}
@property (copy,nonatomic)  NSString *bundleFilePath;
@end

@implementation RecordView


- (void)awakeFromNib{
    //创建出CAShapeLayer
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.frame = CGRectMake(0, 0, 35, 35);//设置shapeLayer的尺寸和位置
    _shapeLayer.position = _playStateImg.center;
    _shapeLayer.fillColor = [UIColor clearColor].CGColor;//填充颜色为ClearColor
    
    //设置线条的宽度和颜色
    _shapeLayer.lineWidth = 2.5f;
    _shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
//    _shapeLayer.strokeStart = 0;
    _shapeLayer.strokeEnd = 0;
    
    //创建出圆形贝塞尔曲线
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 35, 35)];
    
    //让贝塞尔曲线与CAShapeLayer产生联系
    _shapeLayer.path = circlePath.CGPath;
    
    //添加并显示
    [self.layer addSublayer:_shapeLayer];
    
    [self showBgImage:FALSE];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

+(void)stopAllPlay
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GHOSTPLAYSTART object:nil];
}

-(void)otherPlay:(NSNotification*)notify
{
    if (notify.object != self) {
      
        [self stopPlay];

        if (_audioPlayer) {
            [_audioPlayer stop];
            _audioPlayer = nil;
            _isPlay = NO;
        }
        

        
        if ([_timer isValid]) {
            [_timer invalidate];
            _timer = nil;
        }
        [self stopshapeLayer];
        status  = RECORDPLAYSTATUS_Stop;
//        _shapeLayer.strokeEnd = 0;
        
//        _playStateImg.image = [UIImage imageNamed:@"icon_record_play"];
    }
}

#pragma mark -ui

+(instancetype)initWithUrl:(NSString*)url
{
    NSArray *nibs = [[NSBundle mainBundle]loadNibNamed:@"RecordView" owner:self options:nil];
    RecordView *recordPlayView = [nibs objectAtIndex:0];
    recordPlayView.bundleFilePath = url;
    return recordPlayView;
}
+(instancetype)initWithStaticUrl:(NSString*)url
{
    NSArray *nibs = [[NSBundle mainBundle]loadNibNamed:@"RecordView" owner:self options:nil];
    RecordView *recordPlayView = [nibs objectAtIndex:1];
    recordPlayView.bundleFilePath = url;
    return recordPlayView;
}
-(void)showBgImage:(BOOL)bshow
{
    _bgImage.hidden = !bshow;
       _defaultPlayStateImg.hidden = bshow;
    _timeLabel.hidden = !bshow;
    
}

- (void)prepareAndPlay{

    if ( [_bundleFilePath hasPrefix:@"http"]) {
        [self downloadFile:^(NSError* error)
         {
             if (!error) {
                return [self prepareAndPlay];
             }
         }];
    }else{
       [self cacluateTotalTime];
       _bundleFilePath= [self changeAudioFormToWav];
        [self playBundle];
    }
}

- (IBAction)playClick:(UIButton *)sender {
   
    switch (status) {
        case RECORDPLAYSTATUS_Unknown:
        case RECORDPLAYSTATUS_Stop:
        {
            [self showBgImage:YES];
            _playStateImg.image = [UIImage imageNamed:@"icon_record_stop"];
            [self prepareAndPlay];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(otherPlay:) name:GHOSTPLAYSTART object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:GHOSTPLAYSTART object:self];
        }
            break;
        case RECORDPLAYSTATUS_Playing:
        {
            [self pause];
            _playStateImg.image = [UIImage imageNamed:@"icon_record_play"];
        }
         break;
        case RECORDPLAYSTATUS_Pause:{
            _playStateImg.image = [UIImage imageNamed:@"icon_record_stop"];
            [self resume];
        }
            break;
            default:
            break;
    }
    

}


- (void)stopPlay{

    [self showBgImage:FALSE];
    if (_audioPlayer) {
        [_audioPlayer stop];
        _audioPlayer = nil;
        
    }
    if ([_timer isValid]) {
//        _timer = nil;
       [_timer setFireDate:[NSDate distantFuture]];
    }
    _shapeLayer.strokeEnd = 0;
}




- (void)downloadFile:(CompletedBlock)block{
    //TODO BOBO,下载前请确定本地目录是否存在，不存在就创建一个
    [self createAduioFolder];
    _timeLabel.text = @"正在缓冲";
    
    //初始化队列
    NSOperationQueue *queue = [[NSOperationQueue alloc ]init];
    //下载地址
    NSURL *url = [NSURL URLWithString:_bundleFilePath];
    //保存路径
    //        NSString *rootPath = [self dirDoc];
    NSString *_timeSign=[NSString stringWithFormat:@"NewRecord%@.amr",[self returnCurentDataIntoSecond]];
    NSString * _filePath= [AUDIO_DELETED_PATH  stringByAppendingPathComponent:_timeSign];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc]initWithRequest:[NSURLRequest requestWithURL:url]];
    op.outputStream = [NSOutputStream outputStreamToFileAtPath:_filePath append:NO];
    // 根据下载量设置进度条的百分比
    [op setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        CGFloat precent = (CGFloat)totalBytesRead / totalBytesExpectedToRead;
        //            HUD.progress = precent;
        NSLog(@"%g",precent);
    }];
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        _bundleFilePath = _filePath ;
        if (block) {
            block(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"下载失败");
        //            [HUD removeFromSuperview];
        
        _timeLabel.text = @"缓冲失败。请检查网络";
        if (block) {
            block(error);
        }
    }];
    //开始下载
    [queue addOperation:op];

}

//TODO BOBO
- (NSString *)createAduioFolder {
    NSFileManager *filemgr = [NSFileManager new];
    static NSString *cacheFolder ;
    
    if (!cacheFolder) {
        cacheFolder = AUDIO_DELETED_PATH;
    }
    
    // ensure all cache directories are there
    NSError *error = nil;
    if(![filemgr createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"Failed to create cache directory at %@", cacheFolder);
        cacheFolder = nil;
    }
    return cacheFolder;
}


- (NSString *)returnCurentDataIntoSecond{
    
    //获得系统日期的精确值
    NSDate * senddate=[NSDate date];
    NSCalendar * cal=[NSCalendar currentCalendar];
    NSUInteger unitFlags=kCFCalendarUnitSecond|kCFCalendarUnitMinute|kCFCalendarUnitHour|kCFCalendarUnitDay|kCFCalendarUnitMonth|kCFCalendarUnitYear;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:senddate];
    NSInteger year     =[conponent year];
    NSInteger month    =[conponent month];
    NSInteger day      =[conponent day];
    NSInteger hour     =[conponent hour];
    NSInteger minitues =[conponent minute];
    NSInteger second   =[conponent second];
    NSString * nstr= [NSString stringWithFormat:@"%4ld%2ld%2ld%2ld%2ld%2ld",(long)year,(long)month,(long)day,(long)hour,(long)minitues,(long)second];
    
    NSString * nsDateString =[nstr stringByReplacingOccurrencesOfString:@" " withString:@"0"];
    //    NSLog(@"nsDateString====%@",nsDateString);
    return nsDateString;
}



//更新播放的时间进度
- (void)reflushTimeUI:(NSInteger)minute sec:(NSInteger)second{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *seco = second < 10 ? [NSString stringWithFormat:@"0%ld",(long)second] : [NSString stringWithFormat:@"%ld",(long)second];
        NSString *min = minute < 10 ? [NSString stringWithFormat:@"0%ld",(long)minute] : [NSString stringWithFormat:@"%ld",(long)minute];
        _timeLabel.text = [NSString stringWithFormat:@"00:%@:%@",min,seco];
        if (seco == 0 && min == 0) {
            _playStateImg.image = [UIImage imageNamed:@"icon_record_play"];
        }
    });
}




- (void)cacluateTotalTime{

        NSData *data = [[NSData alloc] initWithContentsOfFile:self.bundleFilePath];
        AVAudioPlayer *audio = [[AVAudioPlayer alloc] initWithData:data error:nil];
        NSInteger minute = 0, second = 0;
        if (audio.duration > 60) {
            NSInteger index = audio.duration / 60;
            minute = index;
            second = audio.duration - index * 60;
        }else{
            second = audio.duration;
        }
        
        [self reflushTimeUI:minute sec:second];
//    }
}
- (NSString *)changeAudioFormToWav{
    
    NSString *amrFileUrlString = _bundleFilePath;
    if (![_bundleFilePath hasSuffix:@".wav"]) {
    NSString *wavFileUrlString = [amrFileUrlString stringByAppendingString:@".wav"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:wavFileUrlString]) {
        amr_file_to_wave_file([amrFileUrlString cStringUsingEncoding:NSASCIIStringEncoding],
                              [wavFileUrlString cStringUsingEncoding:NSASCIIStringEncoding]);
    }
          return wavFileUrlString;
    }else{
        return amrFileUrlString;
    }
  
}

- (BOOL)playBundle{
    if (![self fileUrlisExist:_bundleFilePath]) return  NO;
      NSData *data = [[NSData alloc] initWithContentsOfFile:_bundleFilePath];
    if (!_audioPlayer) {
        _audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
        _audioPlayer.delegate = self;
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);

        
        [[AVAudioSession sharedInstance] setActive:YES error:nil];

    }
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
    status = RECORDPLAYSTATUS_Playing;
    //开始循环
    if(!_timer){
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                  target:self
                                                selector:@selector(bundleTimeObserver)
                                                userInfo:nil
                                                 repeats:YES];
    }
    else{
        [_timer setFireDate:[NSDate date]];
    }
    [self.layer addSublayer:_shapeLayer];
    return YES;
    
}

- (void)bundleTimeObserver{
//    NSLog(@"bundleTimeObserver status = %ld",status);
//    if(status != RECORDPLAYSTATUS_Stop)
//    {
        float progress = _audioPlayer.currentTime/_audioPlayer.duration;
//        dispatch_async(dispatch_get_main_queue(), ^{
            _shapeLayer.strokeEnd = progress;
//            NSLog(@"bobobo ==%f",progress);
            NSInteger lastTime = _audioPlayer.duration - _audioPlayer.currentTime;
            NSInteger minute = 0,second = 0;
            if (lastTime > 60) {
                NSInteger index = lastTime / 60;
                minute = index;
                second = lastTime - index * 60;
            }else{
                second = lastTime;
            }
            [self reflushTimeUI:minute sec:second];
//        });
//    }
}

- (BOOL)fileUrlisExist:(NSString *)fileUrl{
    return [[NSFileManager defaultManager] fileExistsAtPath:fileUrl];
}

- (void)pause{

    [_audioPlayer pause];
    status = RECORDPLAYSTATUS_Pause;
    if (![_timer isValid]) return;
    [_timer setFireDate:[NSDate distantFuture]];
}

- (void)resume{
//    if (_isWebVideo) {
//        [_playerController play];
//    }else{
    [_audioPlayer play];
    status = RECORDPLAYSTATUS_Playing;
    if (![_timer isValid]) return;
    [_timer setFireDate:[NSDate date]];
}

#pragma mark - audioPlayer delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (flag) {
        NSLog(@"本地音乐播放完毕");
        [_timer setFireDate:[NSDate distantFuture]];
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        [self stopshapeLayer];
        [self showBgImage:NO];
        
        status  = RECORDPLAYSTATUS_Stop;
        
        [self deleteWavFile];
        if ([self.delegate respondsToSelector:@selector(finishedPlay)]) {
            [self.delegate finishedPlay];
        }
        
    }
}
- (void)deleteWavFile{
    if ([_bundleFilePath hasSuffix:@".wav"]) {
        NSInteger length = _bundleFilePath.length;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager removeItemAtPath:_bundleFilePath error:nil]) {
            NSLog(@"wav file remove success");
            _bundleFilePath = [_bundleFilePath substringToIndex:length-4];
            
        }
        
    }
}
- (void)stopshapeLayer{
    if (_audioPlayer) {
        [_audioPlayer stop];
    }

        _playStateImg.image = [UIImage imageNamed:@"icon_record_play"];

       [_shapeLayer removeFromSuperlayer];
       [CATransaction begin];
       [CATransaction setDisableActions:YES];

       _shapeLayer.strokeEnd = 0.0f;
       [CATransaction commit];



}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"播放故障");

}

@end
