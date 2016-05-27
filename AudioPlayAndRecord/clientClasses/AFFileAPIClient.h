//
//  AFFileAPIClien.h
//  VehicleBone
//
//  Created by bobo on 15/8/12.
//  Copyright (c) 2015年 mesada. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface AFFileAPIClient : AFHTTPSessionManager
+ (instancetype)sharedClient;
@end
