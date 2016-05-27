//
//  RecordAudioView.m
//  MyDemo
//
//  Created by ENIAC on 15/12/22.
//  Copyright © 2015年 yyb. All rights reserved.
//

#import "RecordAudioView.h"
#import "PRNAmrRecorder.h"
#import "XXBRippleView.h"
#import "UserContext.h"
#import "LocialNotificationManager.h"


#define AUDIO_FOBIDDENDELETED_USER_PATH [NSString stringWithFormat:@"%@/Library/Caches/ghost/audio/forbidden/%@/", NSHomeDirectory(),[UserContext sharedContext].user.userId]

UIView              *      recordView           = nil;
UIView              *      myContentView        = nil;
UIButton            *      backbutton           = nil;
static  NSString    *const kTextViewPlaceholder = @"请添加文字备注，限16个字内";
/**
 * 不要使用中文命名、转换amr识别不了
 */
static  NSString    *const kfileName = @"newRecord";


@interface RecordAudioView () <PRNAmrRecorderDelegate,UITextViewDelegate>
{
    PRNAmrRecorder *recorder;
    UITextView *clickTextView;
    CGRect orginFrame;
    NSString *fileAppendUrl;            // 相对路径
}


@property (nonatomic,copy)  NSString *filesign;
@property (weak, nonatomic) IBOutlet XXBRippleView *rippleView;
@property (weak, nonatomic) IBOutlet UILabel *recordTime;
@property (weak, nonatomic) IBOutlet UIButton *startOrStopRecordBtn;
@property (weak, nonatomic) IBOutlet UIView *hiddenView;
@property (weak, nonatomic) IBOutlet UILabel *hiddenTimeLab;
@property (weak, nonatomic) IBOutlet UILabel *hiddenfileSizeLab;
@property (weak, nonatomic) IBOutlet UITextView *hiddenTextView;
@property (weak, nonatomic) IBOutlet UIView *hiddenPlayView;


@end
@implementation RecordAudioView

#pragma mark --- public UI show Or hide
+ (instancetype)initWithDelegate:(id)delegate{
    NSArray *nibs = [[NSBundle mainBundle]loadNibNamed:@"RecordAudioView" owner:self options:nil];
    RecordAudioView * ins = [nibs objectAtIndex:0];
    ins.delegate = delegate;
    [ins initViewData];
    
    return ins;
}

-(void)initViewData{
    
    recorder = [PRNAmrRecorder manager];
    recorder.delegate = self;
    NSString * localPath = [recorder getRelativelyPath];
    if (localPath.length > 0) {
        fileAppendUrl = localPath;
    }else{
        NSString *currentSign = [self returnCurentDataIntoSecond];
        self.filesign = currentSign;
    }
//    NSString *currentSign = [self returnCurentDataIntoSecond];
//    self.filesign = currentSign;
}

- (void)show{
    myContentView = self;
    
    CGRect _appRt = [UIScreen mainScreen].applicationFrame;
    
    CGFloat lowHeight = myContentView.frame.size.height/3;
    
    [myContentView setFrame:CGRectMake(0, _appRt.size.height-(lowHeight*2)+20, _appRt.size.width, myContentView.frame.size.height)];
    
    recordView = [[UIView alloc] init];
    
    recordView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height+lowHeight);
    [recordView setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:.5]];
    recordView.alpha = 0.0;
    
    [recordView addSubview:self];
    backbutton = [[UIButton alloc] initWithFrame:CGRectMake(1, 27+lowHeight,30 , 30)];
    [backbutton setImage:[UIImage imageNamed:@"btn_back_normal"] forState:UIControlStateNormal];
    [backbutton setImage:[UIImage imageNamed:@"btn_back_press"] forState:UIControlStateSelected];
    [backbutton addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    [recordView addSubview:backbutton];
    backbutton.hidden =YES;
    
    
    
    [[UIApplication sharedApplication].keyWindow addSubview:recordView];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        recordView.alpha = 1.0;
        recordView.frame = CGRectMake(0, -lowHeight,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height+lowHeight);

        orginFrame = recordView.frame;
    } completion:^(BOOL finished) {
        UITapGestureRecognizer *_singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
        _singleTap.numberOfTouchesRequired = 1; //手指数
        _singleTap.numberOfTapsRequired = 1; //tap次数
        [recordView addGestureRecognizer:_singleTap];
        [self setIsRecordingUI];

    }];
    
}
- (void)hide{
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        recordView.alpha = 0;
        
        recordView.frame = CGRectMake(0, 0, recordView.frame.size.width, recordView.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            [recordView setUserInteractionEnabled:YES];
            [recordView removeFromSuperview];
            recordView = nil;
            myContentView = nil;
        if ([self.delegate respondsToSelector:@selector(recordHidecomplete:)]){
           [self.delegate recordHidecomplete:YES];
        }
        }
    }];
}
- (void)setIsRecordingUI{
    if (!recorder.isRecording) {
        backbutton.hidden =YES;
        return;
    }
    backbutton.hidden =NO;
    self.rippleView.rippleColor = [UIColor colorWithRed:0/255.0 green:255/255.0 blue:0/255.0 alpha:0.5];
    self.startOrStopRecordBtn.selected = YES;
    self.recordTime.hidden = NO;
    
}
#pragma mark --- handleSingleFingerEvent
- (void)handleSingleFingerEvent:(UITapGestureRecognizer *)sender{
    CGPoint pt =  [sender locationInView:myContentView];
    if (pt.y >= 0  || self.rippleView.hidden == YES) {
        
        return ;
    }
    if (self.startOrStopRecordBtn.selected  == NO ) {
        
        [self hide];
    }
}

#pragma mark --- buttonClick
- (IBAction)audioBtnSelected:(UIButton *)sender {
    
    self.startOrStopRecordBtn.selected = !self.startOrStopRecordBtn.selected;
    
    if (self.startOrStopRecordBtn.selected ) {
         //开始录音
        [self startRecord];
    }else{
        //结束录音
        [self audioFinished];
    }
}

- (void)startRecord{
    if (recorder.isRecording) {
        backbutton.hidden =NO;
        return;
    }
    self.rippleView.rippleColor = [UIColor colorWithRed:0/255.0 green:255/255.0 blue:0/255.0 alpha:0.5];
    [ [LocialNotificationManager manager] registerLocalNotification:30*60 key:@"超时"];
    NSString *recordFile = [self recordFilePath];
    [recorder setSpeakMode:NO];
    [recorder recordWithURL:[NSURL URLWithString:recordFile] RelativelyPath:fileAppendUrl];
    self.recordTime.hidden = NO;
    backbutton.hidden = NO;
    
}
- (void)audioFinished{
    backbutton.hidden = YES;
    
    
    [[LocialNotificationManager manager]  cancelLocalNotificationWithKey:@"超时"];
    
    [self.rippleView stopRippleAnimation];
    
    [recorder stop];
    
    
    
    //弹出填写录音名称框
    [self hiddenViewShow];
    
}
- (IBAction)completedFinished:(UIButton *)sender {
    //点击到录音完成按钮
    [self completedFinished];
}
- (void)hiddenViewShow{
    
    self.rippleView.hidden = YES;
    
    self.hiddenView.hidden = NO;
    
    self.hiddenPlayView.hidden = NO;
    self.hiddenTextView.delegate = self;
    self.hiddenTextView.tintColor = [UIColor colorWithRed:36.0/255.0f green:114.0/255.0f blue:186.0f/255.0f alpha:1.0f];
    
    
    [self registerKeyBoard];
    _hiddenPlayView.alpha = 0;
    _hiddenView.alpha = 0;
    
    [UIView animateWithDuration:1 animations:^{
        
        _hiddenPlayView.alpha = 1;
        _hiddenView.alpha = 1;
        _recordTime.alpha = 0;
        _startOrStopRecordBtn.alpha = 0;
        self.recordTime.hidden = YES;
        self.startOrStopRecordBtn.hidden = YES;
    }];
    
}
- (void)completedFinished{
    [clickTextView resignFirstResponder];
    self.hiddenTextView.text=[self saveTextViewInfo:self.hiddenTextView.text];
    // 返回完成文件信息
    [self didRecordedCompleted];
    
}
- (void)didRecordedCompleted{
    
    if ([self.delegate respondsToSelector:@selector(recorderdidRecordWithFile:)]) {
        
        AudioFileInfo *recFileInfo = [[AudioFileInfo alloc] init];
        
        recFileInfo.audioName     = _hiddenTextView.text;
        recFileInfo.audiofileSize = _hiddenfileSizeLab.text;
        recFileInfo.audioduration = _hiddenTimeLab.text;
        recFileInfo.audioUrl      =  fileAppendUrl;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        NSString *dateStr= [dateFormatter stringFromDate:[NSDate date]];
        
        recFileInfo.time      = dateStr;
        
        
        
        [self.delegate recorderdidRecordWithFile:recFileInfo];
    }
    
}
- (void)backClick:(UIButton *)sender{
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        recordView.alpha = 0;
        
        recordView.frame = CGRectMake(0, 0, recordView.frame.size.width, recordView.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            [recordView setUserInteractionEnabled:YES];
            [recordView removeFromSuperview];
            recordView = nil;
            myContentView = nil;
            if ([self.delegate respondsToSelector:@selector(recordingPopToViewController)]) {
                [self.delegate recordingPopToViewController];
            }
        }
    }];

}
#pragma mark - PRNAmrRecorderDelegate
//录音结束后文件信息回传
- (void)recorder:(PRNAmrRecorder *)aRecorder
                 didRecordWithFile:(PRNAmrFileInfo *)fileInfo{
    NSLog(@"==================================================================");
    NSLog(@"record with file : %@", fileInfo.fileUrl);
    NSLog(@"file size: %llu", fileInfo.fileSize);
    NSLog(@"file duration : %f", fileInfo.duration);
    NSLog(@"==================================================================");
    
    double size = (double)fileInfo.fileSize;
    NSInteger durationT = (NSInteger)fileInfo.duration;
    
    self.hiddenfileSizeLab.text = [self calculateSize:size];
    self.hiddenTimeLab.text = [self calculateTime:durationT andRun:NO];
    
    
}
//录音中断
- (void)recorderHasBeInterpurt{
    __block __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        //回调或者说是通知主线程刷新，
        [weakSelf audioFinished];
    });
    
}
//获取到录音器的时间
- (void)recorder:(PRNAmrRecorder *)aRecorder
                 didPickSpeakPower:(float)power andTime:(double)currentTime{
    [self.rippleView startRippleAnimationWithPower:power];
    
    NSString *currentTimeLabel= [NSString stringWithFormat: @"%02d:%02d",
                                 (int) currentTime/60,(int) currentTime%60];
//    NSLog(@"%@",currentTimeLabel);
    self.recordTime.text  =currentTimeLabel;
    
    
}
#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    clickTextView = textView;
    if ([_hiddenTextView.text isEqualToString:kTextViewPlaceholder]) {
         self.hiddenTextView.text = @"";
    }
}
- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length > 16) {
        NSString * str = [textView.text substringToIndex:16];
        textView.text = str;
    }
}
- (BOOL)textView:(UITextView *)textView
                 shouldChangeTextInRange:(NSRange)range
                 replacementText:(NSString *)text{
    
    if ([text isEqualToString:@""]) {
        return YES;
    }
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    if (textView.text.length >= 16) {
        return NO;
    }
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return [textView resignFirstResponder];
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        self.hiddenTextView.text = kTextViewPlaceholder;
    }
}
#pragma mark - keyBoardNotification
- (void)registerKeyBoard{
    //注册键盘弹起的通知中心  UIKeyboardWillShowNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHidden:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)keyBoardShow:(NSNotification *)no{
    NSDictionary *info = no.userInfo;
    //NSValue
    id objFrame = info[@"UIKeyboardFrameEndUserInfoKey"];
    
    CGRect keyBoardFrame = {0};
    //获取键盘的高度
    [objFrame getValue:&keyBoardFrame];
    
    //判断键盘能否把控件遮挡住
    CGRect tempFrame = recordView.frame;
    
    
    tempFrame.origin.y = [[UIScreen mainScreen] bounds].size.height- keyBoardFrame.size.height- tempFrame.size.height;
    recordView.frame = tempFrame;
    
}
- (void)keyBoardHidden:(NSNotification *)no{
    //当键盘隐藏的时候 把frame还原
    recordView.frame  = orginFrame;
}
- (void)dealloc{
    //注销通知中心
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark - other Uility
/**
 *   获得系统日期的精确值
 */
- (NSString *)returnCurentDataIntoSecond{
    
   
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
/**
 *   文件保存路径
 */
- (NSString *)recordFilePath{
    if (fileAppendUrl.length == 0) {
        NSString *fileAppend = [NSString stringWithFormat:@"%@%@.amr",kfileName,_filesign];
        fileAppendUrl = fileAppend;
    }
   
    NSString *recordFile = [AUDIO_FOBIDDENDELETED_USER_PATH stringByAppendingPathComponent:fileAppendUrl];
    NSLog(@"%@",recordFile);
    return recordFile;
}
/**
 *   备注信息
 */
- (NSString *)saveTextViewInfo:(NSString *)text{
    NSString *currentString = text;
    NSString *saveName = [NSString stringWithFormat:@"%@%@",kfileName,_filesign];
    if ([currentString isEqualToString:kTextViewPlaceholder] || [currentString isEqualToString:@""]) {
        return saveName;
    }
    return text;
}
/**
 *   计算时间
 */
- (NSString *)calculateTime:(NSInteger )countT andRun:(BOOL)isRun{
    NSString  *timeString ;
    NSInteger second  = (countT+1)%60;
    NSInteger mintiue = countT/60;
    if (isRun) {
        timeString = [NSString stringWithFormat:@"%02ld:%02ld",(long)mintiue,(long)second];
    }else{
        timeString = [NSString stringWithFormat:@"%02ld分%02ld秒",(long)mintiue,(long)second];
    }
    return timeString;
}
/**
 *   计算文件大小
 */
- (NSString *)calculateSize:(double)size{
    NSString *audiofileSize = @"0";
    if (size>1024.0*1024.0) {
        double Mb = size / 1024.0 /1024.0;
        audiofileSize = [NSString stringWithFormat:@"%.2fMB",Mb];
    }else{
        double kb = size / 1024.0;
        audiofileSize = [NSString stringWithFormat:@"%.0fKB",kb];
    }
    return audiofileSize;
}

@end
@implementation AudioFileInfo @end
