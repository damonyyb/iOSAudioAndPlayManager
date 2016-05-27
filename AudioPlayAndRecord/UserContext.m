//
//  UserContext.m
//  HeraldleasingWorkAssistant
//
//  Created by Mesada on 15/5/16.
//  Copyright (c) 2015年 mesada. All rights reserved.
//

#import "UserContext.h"
#define SHAREDPREFERENCESKEY  @"com.mesada.heraldleasing.prefs"

@implementation UserContext
+ (instancetype)sharedContext {
    static UserContext *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[UserContext alloc] init];
        UserAccount* defaut = [[UserAccount alloc]init];
        _sharedClient.user = defaut;
        defaut.userId = @"0";
        defaut.account =@"";
    });
    
    return _sharedClient;
}

-(NSString*)getSharedPreferencesKey
{
    return  SHAREDPREFERENCESKEY;
}

-(void)setUser:(UserAccount *)user
{
    _user = user;
}


@end
