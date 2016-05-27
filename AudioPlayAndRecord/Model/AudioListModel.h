//
//  AuidoListModel.h
//  LayoutDemo
//
//  Created by 科比 布莱恩特 on 16/1/6.
//  Copyright © 2016年 mesada. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, MSDAudioALLStatus)
{
    MSDAudio_ALLDIDNOTEND=1,    //有未上传的录音文件
    MSDAudio_ALLEND,            //所有录音文件上传成功
    MSDAudio_ALLNOTSTART,       //录音文件
};

typedef void (^AudioListComplete)(NSError*);

@interface AudioListModel : NSObject<NSCoding>

@property (nonatomic,strong) NSArray *dataArray;//audioFileInfoModel
@property (nonatomic,assign) MSDAudioALLStatus state;
@property (nonatomic,strong) NSString *endTime;  //记录最后操作的时间
@property (nonatomic,assign) BOOL isFinished;    //任务结束标记


- (id)describe;


@end
