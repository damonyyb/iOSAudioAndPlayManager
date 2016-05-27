//
//  MSDVideoUploader.m
//  MyDemo
//
//  Created by ENIAC on 15/12/8.
//  Copyright © 2015年 yyb. All rights reserved.
//

#import "MSDVideoUploader.h"
#import "AFNetworking.h"
#import "UserContext.h"
#import "MD5.h"
#import "AFFileAPiClient.h"


static AFHTTPSessionManager *_afHTTPSessionManager;
static NSString * const MD5_KEY = @"abcdefg";

@implementation MSDVideoUploader

+(NSURLSessionDataTask *)post:(NSURL *)videoURL andOrder:(NSInteger)uploderOrder andFileNameExtension:(NSString *)fileNameExtension complete:(void (^)(NSString* urlString,NSError *error,NSInteger ansOrder))block{
        NSString *userString = @"SH006";
        NSString *md5Sign    = [[NSString stringWithFormat:@"%@%@",userString,MD5_KEY]MD5];
        NSString *videoTyeString = @"t_video";
        NSMutableDictionary *parameters= [NSMutableDictionary dictionary];
        parameters[@"fid"]   = videoTyeString;
        parameters[@"uid"]   = userString;
        parameters[@"sign"]  = md5Sign;
    
    return [[AFFileAPIClient sharedClient]POST:@"fileService/upload.action" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSString *fileName = [NSString stringWithFormat:@"xxxx%@",fileNameExtension];
        if (fileNameExtension) {
            fileName = [NSString stringWithFormat:@"xxxX%@",fileNameExtension];
        }
        [formData appendPartWithFileURL:videoURL name:@"f" fileName:fileName mimeType:@"application/octet-stream" error:NULL];
        
        
    } success:^(NSURLSessionDataTask *task, id JSON) {
        NSString *retCodeNum = [JSON valueForKey:@"retCode"];
        int retCode = [retCodeNum intValue];
        if (0 == retCode) {
            NSString *urlString = [JSON valueForKey:@"url"];
            NSInteger ansOrder = uploderOrder;
            
            if (block) {
                block(urlString,nil,ansOrder);
            }
        }
        else{
            NSDictionary *NSErrorDic =@{@"retCode":@(retCode),
                                        @"message":@""};
            NSInteger ansOrder = uploderOrder;
            if (block) {
                block(nil,[[NSError alloc] initWithDomain:@"" code:0 userInfo:NSErrorDic],ansOrder);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSInteger ansOrder = uploderOrder;
             block(nil,error,ansOrder);
    }];
}

@end





























