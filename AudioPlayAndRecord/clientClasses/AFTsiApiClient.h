//
//  AFTsiApiClient.h
//  HeraldleasingWorkAssistant
//
//  Created by bobo on 15/8/13.
//  Copyright (c) 2015年 mesada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface AFTsiApiClient : AFHTTPSessionManager
+ (instancetype)sharedClient;
@end
