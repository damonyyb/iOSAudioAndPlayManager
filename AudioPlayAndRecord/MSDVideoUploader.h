//
//  MSDVideoUploader.h
//  MyDemo
//
//  Created by ENIAC on 15/12/8.
//  Copyright © 2015年 yyb. All rights reserved.
//  录音上传

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MSDVideoUploader : NSObject
+(NSURLSessionDataTask *)post:(NSURL *)videoURL andOrder:(NSInteger)uploderOrder andFileNameExtension:(NSString *)fileNameExtension complete:(void (^)(NSString* urlString,NSError *error,NSInteger ansOrder))block;

@end
