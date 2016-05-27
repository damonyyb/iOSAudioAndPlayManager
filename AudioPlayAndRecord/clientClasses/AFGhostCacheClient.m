//
//  AFHeraldCacheClient.m
//  HeraldleasingWorkAssistant
//
//  Created by Mesada on 15/6/12.
//  Copyright (c) 2015年 mesada. All rights reserved.
//
#import "PCHHeader.h"
#import "AFGhostCacheClient.h"
#import "UIKit+AFNetworking.h"
@implementation AFGhostCacheClient
+ (instancetype)sharedClient {
    static AFGhostCacheClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        //设置我们的缓存大小 其中内存缓存大小设置10M  磁盘缓存5M
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024 diskCapacity:50 * 1024 * 1024 diskPath:[[self class] cacheFolder]];
        [config setURLCache:cache];
        _sharedClient = [[AFGhostCacheClient alloc] initWithBaseURL:[NSURL URLWithString:API_SERVER_4S] sessionConfiguration:config];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    NSLog(@"self %@ deleagte = %@",_sharedClient,_sharedClient.session.delegate);
    
    return _sharedClient;
}

//下载的目录
+ (NSString *)cacheFolder {
    NSFileManager *filemgr = [NSFileManager new];
    static NSString *cacheFolder;
    
    if (!cacheFolder) {
        NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
        cacheFolder = [cacheDir stringByAppendingPathComponent:@"mycache"];
    }
    
    // ensure all cache directories are there
    NSError *error = nil;
    if(![filemgr createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"Failed to create cache directory at %@", cacheFolder);
        cacheFolder = nil;
    }
    return cacheFolder;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSURLResponse *response,
                                                        id responseObject,
                                                        NSError *error))completionHandler
{
    NSMutableURLRequest *modifiedRequest = request.mutableCopy;
    AFNetworkReachabilityManager *reachability = self.reachabilityManager;
    if (!reachability.isReachable)
    {
        modifiedRequest.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    }
    return [super dataTaskWithRequest:modifiedRequest
                    completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    NSURLResponse *response = proposedResponse.response;
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse*)response;
    NSDictionary *headers = HTTPResponse.allHeaderFields;
    
    if (headers[@"Cache-Control"])
    {
        NSMutableDictionary *modifiedHeaders = headers.mutableCopy;
        modifiedHeaders[@"Cache-Control"] = @"max-age=60";
        NSHTTPURLResponse *modifiedHTTPResponse = [[NSHTTPURLResponse alloc]
                                                   initWithURL:HTTPResponse.URL
                                                   statusCode:HTTPResponse.statusCode
                                                   HTTPVersion:@"HTTP/1.1"
                                                   headerFields:modifiedHeaders];
        
        proposedResponse = [[NSCachedURLResponse alloc] initWithResponse:modifiedHTTPResponse
                                                                    data:proposedResponse.data
                                                                userInfo:proposedResponse.userInfo
                                                           storagePolicy:proposedResponse.storagePolicy];
    }
    
    [super URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
}
@end
