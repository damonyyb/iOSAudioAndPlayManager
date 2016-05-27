//
//  WaterDropAudioViewController.m
//  MyDemo
//
//  Created by ENIAC on 15/12/22.
//  Copyright © 2015年 yyb. All rights reserved.
//
#import "PCHHeader.h"

#import "WaterDropAudioViewController.h"
#import "RecordAudioView.h"
#import "AudioListCell.h"
#import "AudioFileInfoModel.h"
#import "MSDVideoUploader.h"
#import "UserContext.h"
#import "NilDataTipView.h"
#import "AudioListModel.h"
#import "NSDate+Ldate.h"
#import "MBProgressHUD.h"
#import "PRNAmrRecorder.h"
#define RECVICE_KEY @"recvice_key_V1B2"

@interface WaterDropAudioViewController () <RecordAudioDelegate,UITableViewDataSource,UITableViewDelegate,AudioListCellDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *finishedView;

@property (weak, nonatomic) IBOutlet UIButton *addNewRecordView;

@property (nonatomic,strong) NilDataTipView *nilView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) RecordAudioView *audioView;
@end

#define AUDIO_PATH        [NSString stringWithFormat:@"%@/Library/Caches/ghost/audio", NSHomeDirectory()]

#define PATH_OF_FILE      [AUDIO_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",@"audio.text"]]

#define AUDIO_DELETED_PATH [NSString stringWithFormat:@"%@/Library/Caches/ghost/audio/deleted", NSHomeDirectory()]

#define AUDIO_FOBIDDENDELETED_USER_PATH [NSString stringWithFormat:@"%@/Library/Caches/ghost/audio/forbidden/%@/", NSHomeDirectory(),[UserContext sharedContext].user.userId]

static  NSString    *const  kfileName   = @"newRecord";
static  double       const  kcellheight = 75.0;

@implementation WaterDropAudioViewController

#pragma mark --- lifetime of VC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    self.title = @"录音记录";
    [self filePathNeedCreate];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView:) name:@"reloadTableView" object:nil];
}
- (void)selfCheckRecordingStatus{
    BOOL bRecord = [PRNAmrRecorder manager].isRecording;
    if (bRecord) {
        [self showRecordView];
    }
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self showOrhideView];
    [self selfCheckRecordingStatus];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeRecordView];
    [RecordView stopAllPlay];
}

- (void)showOrhideView{
    NSArray *array= [self readFromFile];
   
    if (array.count>0 ) {
        self.finishedView.hidden = NO;

        NSData *audioModelReadData = [[NSUserDefaults standardUserDefaults] objectForKey:RECVICE_KEY];
         AudioListModel *audioModel =  [NSKeyedUnarchiver unarchiveObjectWithData:audioModelReadData];
        if (!audioModel) {
            audioModel = [[AudioListModel alloc] init];
        }
        
       
        if (array.count>=5 || audioModel.isFinished == YES) {
            self.addNewRecordView.hidden = YES;
        }else{
            self.addNewRecordView.hidden = NO;
        }
        [self hideNoRecord];
        self.dataArray = [array mutableCopy];
        [self.tableView reloadData];
    }else{
        self.finishedView.hidden = YES;
        [self showNoRecord];
        if (![PRNAmrRecorder manager].isRecording) {
        [self showRecordView];
        }
    }
    
}
- (void)showNoRecord{
    self.nilView = [NilDataTipView getInstance];
    _nilView.frame =CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    [self.view addSubview:self.nilView];
    
}
- (void)hideNoRecord{
    if (self.nilView) {
        [self.nilView removeFromSuperview];
    }
}
- (void)showRecordView{
    self.audioView = [RecordAudioView initWithDelegate:self];
    self.audioView.delegate = self;
    [self.audioView show];

}
- (void)removeRecordView{
    if (self.audioView) {
        [self.audioView removeFromSuperview];
        self.audioView = nil;
    }
}

#pragma mark --- TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kcellheight;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseIdetify = @"AudioListCell";
    AudioListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify forIndexPath:indexPath];
    AudioFileInfoModel *fileInfo = self.dataArray[self.dataArray.count-indexPath.row-1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setValueWithfileInfo:fileInfo];
    __weak __typeof(&*self)weakSelf = self;
    cell.delegate = weakSelf;
    
    cell.reuploderBlock = ^(BOOL reuploderOrNot){
        if (reuploderOrNot) {
                [weakSelf uploaderFile:fileInfo andInteger:weakSelf.dataArray.count-indexPath.row-1];
        }
    };
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark --- RecordAudioDelegate
- (void)recorderdidRecordWithFile:(AudioFileInfo *)fileInfo{
  NSLog(@"==================================================================");
    NSLog(@"record audioUrl file : %@", fileInfo.audioUrl);
    NSLog(@"file audioduration: %@", fileInfo.audioduration);
    NSLog(@"file audiofileSize : %@", fileInfo.audiofileSize);
    NSLog(@"file audioName : %@", fileInfo.audioName);
  NSLog(@"==================================================================");
    
    [self.audioView hide];
    [self hideNoRecord];
    
    
    AudioFileInfoModel *model=  [self setAudioFileInfoModel:fileInfo];
    
    [self insertTableViewCell:model];
    

    NSData *audioModelReadData = [[NSUserDefaults standardUserDefaults] objectForKey:RECVICE_KEY];
    AudioListModel *audioModel =  [NSKeyedUnarchiver unarchiveObjectWithData:audioModelReadData];
    if (!audioModel) {
        audioModel = [[AudioListModel alloc] init];
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:audioModel.dataArray];
    [array addObject:model];

    audioModel.dataArray = [array copy];
    audioModel.state =   MSDAudio_ALLEND;
    NSString *endtime =  [NSDate currentDate];
    audioModel.endTime = endtime;
     NSData *audioWriteModelData = [NSKeyedArchiver archivedDataWithRootObject:audioModel];
     [[NSUserDefaults standardUserDefaults] setObject:audioWriteModelData forKey:RECVICE_KEY];
     [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([[[NSUserDefaults standardUserDefaults] dictionaryRepresentation].allKeys containsObject:@"keyForNonMandatoryObject"]) {
        
    }
    
    
    NSInteger order =self.dataArray.count-1;

    [self uploaderFile:model andInteger:order];
}
- (AudioFileInfoModel *)setAudioFileInfoModel:(AudioFileInfo *)fileInfo{
    
    AudioFileInfoModel *model = [[AudioFileInfoModel alloc] init];
    model.path      = fileInfo.audioUrl;
    model.duration = fileInfo.audioduration;
    model.fileTime = fileInfo.time;
    model.fileSize = fileInfo.audiofileSize;
    NSString *name      = fileInfo.audioName;
    
    if ([name hasPrefix:kfileName]) {
        name = [@"新录音 " stringByAppendingString:[NSString stringWithFormat:@"%lu",self.dataArray.count+1]];
    }
    model.name       = name;
    model.describe   = name;
    model.time       = fileInfo.time;
    model.url          = @"";
    model.uploaderStatus  = MSDAudioDidNotUploader;
    model.audioSavePath   = MSDAudio_FOBIDDENDELETED_USER_PATH;
    
    return model;
}
- (void)recordHidecomplete:(BOOL)success{
    if (self.dataArray.count>0) {
        self.finishedView.hidden = NO;
    }else{
        self.finishedView.hidden = YES;
    }
    
    
    if (self.dataArray.count<5) {
        self.addNewRecordView.hidden = NO;
    }else{
        self.addNewRecordView.hidden = YES;
    }
}
- (void)insertTableViewCell:(AudioFileInfoModel *)fileInfo{
    
    [self.dataArray insertObject:fileInfo atIndex:self.dataArray.count];
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)recordingPopToViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --- uploaderAudio
- (void)uploaderFile:(AudioFileInfoModel *)fileInfo
          andInteger:(NSInteger)order{
    NSString *recordFile = [AUDIO_FOBIDDENDELETED_USER_PATH stringByAppendingPathComponent:fileInfo.path];
    NSURL *url = [NSURL fileURLWithPath:recordFile];
     NSArray *array= [self readFromFile];
    
    __block NSArray * aryTmp = [NSArray arrayWithArray:array];
    
    [MSDVideoUploader post:url andOrder:order andFileNameExtension:@".amr" complete:^(NSString *urlString, NSError *error, NSInteger ansOrder) {
        
        AudioFileInfoModel *model = aryTmp[ansOrder];
        
        if (error == nil) {
            model.uploaderStatus  = MSDAudioUploaderSuccess;
            model.url          = urlString;
            NSLog(@"uploader suceess%@",urlString);
            //start  move recordAudio file to other cashes file and save the newpath and current status.
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *filefromPath = [AUDIO_FOBIDDENDELETED_USER_PATH stringByAppendingPathComponent:model.path];
            NSString *filetoPath   = [AUDIO_DELETED_PATH stringByAppendingPathComponent:model.path];
            if ([fileManager copyItemAtPath:filefromPath toPath:filetoPath error:NULL]) {
                if ([fileManager removeItemAtPath:filefromPath error:nil]) {
                   NSLog(@"file remove success,file can be  deleted now");
                    model.audioSavePath   = MSDAudio_AUDIO_DELETED_PATH;
                }
            }
        }else{
            model.uploaderStatus  = MSDAudioUploaderFailed;
            NSLog(@"upload failed , please upload again.%@",error);
        }
        
        NSData *audioModelReadData = [[NSUserDefaults standardUserDefaults] objectForKey:RECVICE_KEY];
        AudioListModel *audioModel =  [NSKeyedUnarchiver unarchiveObjectWithData:audioModelReadData];
        
        
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:audioModel.dataArray ];
        
        [array replaceObjectAtIndex:ansOrder withObject:model];
        
        audioModel.dataArray = [array copy];
            audioModel.state =   MSDAudio_ALLEND;
        NSString *endtime =  [NSDate currentDate];
        audioModel.endTime = endtime;
        
        
        NSData *audioWriteModelData = [NSKeyedArchiver archivedDataWithRootObject:audioModel];
        [[NSUserDefaults standardUserDefaults] setObject:audioWriteModelData forKey:RECVICE_KEY];
        
        NSDictionary * datadic = [NSDictionary dictionaryWithObject:model forKey:[NSNumber numberWithInteger:ansOrder]];

        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadTableView" object:datadic];

    }];
}
- (void)reloadTableView:(NSNotification *)no{
    NSLog(@"notification the uploder");
    NSData *audioModelReadData = [[NSUserDefaults standardUserDefaults] objectForKey:RECVICE_KEY];
    AudioListModel *audioModel =  [NSKeyedUnarchiver unarchiveObjectWithData:audioModelReadData];
    if (audioModel) {
        self.dataArray = [NSMutableArray arrayWithArray:audioModel.dataArray];
        
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    }

    
}
#pragma mark --- btnClick
- (IBAction)addNewAudio {
//    [self cleanRecordView];
    [RecordView stopAllPlay];
    [self showRecordView];
//    self.addRecordView.hidden = YES;
}
- (IBAction)addNewRecord:(id)sender {
    self.finishedView.hidden = YES;
    if (self.dataArray.count==4) {
        MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        HUD.mode = MBProgressHUDModeText;
        HUD.margin = 10.f;
        HUD.yOffset = 15.f;
        HUD.removeFromSuperViewOnHide = YES;
        HUD.detailsLabelText = @"本任务最后一次录音，请不要在未完成时中断录音";
        HUD.labelFont = [UIFont systemFontOfSize:13];
        [HUD hide:YES afterDelay:1.5];
    }

    
    [RecordView stopAllPlay];
    [self showRecordView];
}
#pragma mark --- createFile
- (void)filePathNeedCreate{
    [self createDir:AUDIO_DELETED_PATH];
    [self createDir:AUDIO_FOBIDDENDELETED_USER_PATH];
    
}
- (void)createDir:(NSString *)filePath{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        BOOL success=  [fileManager
                        createDirectoryAtPath:filePath
                        withIntermediateDirectories:YES
                        attributes:nil error:nil];
        if (success) {
            NSLog(@"create the file path success%@",filePath);
        }
    }
}

- (NSArray *)readFromFile{
    NSMutableArray *readArray = [NSMutableArray array];
    
    NSData *audioModelReadData = [[NSUserDefaults standardUserDefaults] objectForKey:RECVICE_KEY];
    AudioListModel *audioModel =  [NSKeyedUnarchiver unarchiveObjectWithData:audioModelReadData];

    if (audioModel) {
        readArray   =[audioModel.dataArray mutableCopy];
        
        if (readArray.count>0) {
            NSLog(@"read from file success");
        }

    }
    
    
    return readArray;
    
}
- (IBAction)finishedTap:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)dealloc{
    NSLog(@"dealloc and remove the notification");
    [[NSNotificationCenter defaultCenter] removeObserver:@"reloadTableView"];
    
}

@end
