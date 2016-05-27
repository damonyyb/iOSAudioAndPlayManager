//
//  AuidoListModel.m
//  LayoutDemo
//
//  Created by 科比 布莱恩特 on 16/1/6.
//  Copyright © 2016年 mesada. All rights reserved.
//

#import "AudioListModel.h"
#import "AudioFileInfoModel.h"



@implementation AudioListModel

- (void)encodeWithCoder:(NSCoder *)aCoder{
    if (_dataArray.count >0) {
        [aCoder encodeObject:_dataArray forKey:@"dataArray"];
    }else{
        [aCoder encodeObject:@[] forKey:@"dataArray"];
    }

    [aCoder encodeInteger:_state forKey:@"state"];
    [aCoder encodeObject:_endTime forKey:@"time"];
    [aCoder encodeBool:_isFinished forKey:@"finished"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.dataArray = [aDecoder decodeObjectForKey:@"dataArray"];
        self.state = [aDecoder decodeIntegerForKey:@"state"];
        self.endTime = [aDecoder decodeObjectForKey:@"time"];
        self.isFinished = [aDecoder decodeBoolForKey:@"finished"];
    }
    return self;
}
- (id)describe{
    NSLog(@"%@\n",self.dataArray);
    NSLog(@"%ld\n",(long)self.state);
    NSLog(@"%@\n",self.endTime);
    NSLog(@"%@\n",@(self.isFinished));
    return nil;
}
@end
