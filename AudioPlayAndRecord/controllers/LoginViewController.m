//
//  LoginViewController.m
//  AudioPlayAndRecord
//
//  Created by yyb on 16/5/26.
//  Copyright © 2016年 yyb. All rights reserved.
//

#import "LoginViewController.h"
#import "UserContext.h"
#import "AudioFileInfoModel.h"
#import "AudioListModel.h"



@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UserContext sharedContext].user.userId  = @"YYB";

 //看一下归档是否成功
//    [self test];
 
}
//- (void)test{
//    AudioFileInfoModel *model = [[AudioFileInfoModel alloc] init];
//    model.path = @"AAAAAA";
//    model.url = @"AAAAAA";
//    model.path = @"AAAAAA";
//    model.describe = @"AAAAAA";
//    model.time= @"AAAAAA";
//    model.duration = @"AAAAAA";
//    model.fileTime = @"AAAAAA";
//    model.name = @"AAAAAA";
//    model.state = 1;
//    model.uploaderStatus = 1;
//    model.audioSavePath  = 1;
//    model.fileSize = @"12.34559";
//    
//    
//    
//    AudioListModel *listModel = [[AudioListModel alloc] init];
//    NSMutableArray *array = [NSMutableArray array];
//    [array addObject:model];
//    listModel.dataArray = [array copy];
//    listModel.state = 1;
//    listModel.endTime = @"AAAAAA";
//    listModel.isFinished = 1;
//    
//    NSData *audioWriteModelData = [NSKeyedArchiver archivedDataWithRootObject:listModel];
//    [[NSUserDefaults standardUserDefaults] setObject:audioWriteModelData forKey:@"Ahh"];
//    
//}
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    
//    
//    NSData *audioModelReadData = [[NSUserDefaults standardUserDefaults] objectForKey:@"Ahh"];
//    AudioListModel *listModel =  [NSKeyedUnarchiver unarchiveObjectWithData:audioModelReadData];
//    NSArray *array=listModel.dataArray;
//    [listModel describe];
//    NSMutableArray *modelArray = [NSMutableArray arrayWithArray:array];
//    for (AudioFileInfoModel *model in modelArray) {
//        [model description];
//    }
//    
//}

@end
