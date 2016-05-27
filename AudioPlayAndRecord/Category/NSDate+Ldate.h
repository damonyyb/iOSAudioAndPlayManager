//
//  NSDate+Ldate.h
//  GhostTask
//
//  Created by bobo on 16/1/5.
//  Copyright © 2016年 美赛达. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate(LDate)
- (NSDate*)tDate;
+(NSDate *)dateFromString:(NSString *)dateString;//yyyy-MM-dd HH:mm:ss
+(NSString*)currentDate;
-(NSString*)dateToString;
@end

