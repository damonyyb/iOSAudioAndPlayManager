//
//  AFHeraldCacheClient.h
//  HeraldleasingWorkAssistant
//
//  Created by Mesada on 15/6/12.
//  Copyright (c) 2015年 mesada. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface AFGhostCacheClient : AFHTTPSessionManager<NSURLSessionDelegate>
+ (instancetype)sharedClient;
@end
