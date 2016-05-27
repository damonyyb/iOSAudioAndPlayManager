//
//  AFFileAPIClien.m
//  VehicleBone
//
//  Created by bobo on 15/8/12.
//  Copyright (c) 2015年 mesada. All rights reserved.
//
// 针对支援服务器

#import "AFFileAPIClient.h"
#import "PCHHeader.h"

@implementation AFFileAPIClient

+ (instancetype)sharedClient {
    static AFFileAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFFileAPIClient alloc] initWithBaseURL:[NSURL URLWithString:FileServPrefix]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:3];
        _sharedClient.responseSerializer.acceptableContentTypes = [_sharedClient.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
        _sharedClient.responseSerializer.acceptableContentTypes = [_sharedClient.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    });
    
    
    return _sharedClient;
}
@end
