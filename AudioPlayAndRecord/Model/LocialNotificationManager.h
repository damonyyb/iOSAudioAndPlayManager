//
//  LocialNotificationManager.h
//  MyDemo
//
//  Created by yyb on 16/1/14.
//  Copyright © 2016年 yyb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocialNotificationManager : NSObject

+ (instancetype)manager;

/**
 *    注册本地通知
 *    @alertTime 延迟通知时间
 *    @key       用于后面取消通知
 **/
- (void)registerLocalNotification:(NSInteger)alertTime key:(NSString*)key;
/**
 *   取消某个本地推送通知
 **/
- (void)cancelLocalNotificationWithKey:(NSString *)key;

@end
