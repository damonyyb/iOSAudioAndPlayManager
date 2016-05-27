//
//  AFTsiApiClient.m
//  HeraldleasingWorkAssistant
//
//  Created by bobo on 15/8/13.
//  Copyright (c) 2015年 mesada. All rights reserved.
//

#import "AFTsiApiClient.h"
#import "PCHHeader.h"

@implementation AFTsiApiClient

+ (instancetype)sharedClient {
    static AFTsiApiClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFTsiApiClient alloc] initWithBaseURL:[NSURL URLWithString:API_TSISERVER_4S]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    
    return _sharedClient;
}

@end
