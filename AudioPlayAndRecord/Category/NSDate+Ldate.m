//
//  NSDate+Ldate.m
//  GhostTask
//
//  Created by bobo on 16/1/5.
//  Copyright © 2016年 美赛达. All rights reserved.
//

#import "NSDate+Ldate.h"

@implementation NSDate(LDate)

- (NSDate*)tDate
{
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    
    NSInteger interval = [zone secondsFromGMTForDate: self];
    
    NSDate *localeDate = [self  dateByAddingTimeInterval: interval];
    
    NSLog(@"%@", localeDate);
    
    return localeDate;
}

+(NSDate *)dateFromString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    return destDate;
}

-(NSString*)dateToString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr= [dateFormatter stringFromDate:self];
    return dateStr;
}

+(NSString*)currentDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr= [dateFormatter stringFromDate:[NSDate date]];
    return dateStr;
}
@end
