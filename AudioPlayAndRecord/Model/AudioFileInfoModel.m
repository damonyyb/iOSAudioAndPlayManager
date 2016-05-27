//
//  AudioFileInfoModel.m
//  MyDemo
//
//  Created by ENIAC on 15/12/25.
//  Copyright © 2015年 yyb. All rights reserved.
//

#import "AudioFileInfoModel.h"
#import "NSString+Enhance.h"

@implementation AudioFileInfoModel

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.url forKey:@"url"];
    [encoder encodeObject:self.path forKey:@"path"];
    [encoder encodeObject:self.describe forKey:@"describe"];
    [encoder encodeObject:self.time forKey:@"time"];
    [encoder encodeObject:self.duration forKey:@"duration"];
    [encoder encodeObject:self.fileTime forKey:@"fileTime"];
    [encoder encodeObject:self.fileSize forKey:@"fileSize"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeInteger:self.state forKey:@"state"];
    [encoder encodeInteger:self.uploaderStatus forKey:@"uploaderStatus"];
    [encoder encodeInteger:self.audioSavePath forKey:@"audioSavePath"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.url = [decoder decodeObjectForKey:@"url"];
        self.path = [decoder decodeObjectForKey:@"path"];
        self.describe = [decoder decodeObjectForKey:@"describe"];
        self.time = [decoder decodeObjectForKey:@"time"];
        self.duration = [decoder decodeObjectForKey:@"duration"];
        self.fileTime = [decoder decodeObjectForKey:@"fileTime"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.state = [decoder decodeIntegerForKey:@"state"];
        self.uploaderStatus = [decoder decodeIntegerForKey:@"uploaderStatus"];
        self.audioSavePath  = [decoder decodeIntegerForKey:@"audioSavePath"];
        self.fileSize = [decoder decodeObjectForKey:@"fileSize"];
    }
    return self;
}
- (id)description{
    
    NSLog(@"%@\n %@\n %@\n %@\n %@\n %@\n %@\n %lu\n  %ld\n %ld\n %@\n",self.url ,
                                              self.path ,
                                              self.describe ,
                                              self.time ,
                                              self.duration ,
                                              self.fileTime,
                                              self.name,
                                              (unsigned long)self.state,
                                              (long)self.uploaderStatus,
                                              (long)self.audioSavePath,
                                              self.fileSize);
    return nil;
    
    
}
@end