//
//  UserContext.h
//  HeraldleasingWorkAssistant
//
//  Created by Mesada on 15/5/16.
//  Copyright (c) 2015年 mesada. All rights reserved.
//
//用户账号上下文
#import <Foundation/Foundation.h>
#import "UserAccount.h"
#define  LOGINACCOUNT          @"LASTLOGINACCOUNT"
#define  LOGINPWD              @"LASTLOGINPWD"
#define  LOGINSTATE            @"LASTLOGIN"
#define  FIRSTSTATE            @"ISFIRSTLOGIN"

@interface UserContext : NSObject
@property (nonatomic,readonly,strong) NSString* sharedPreferencesKey;
@property (nonatomic,strong) UserAccount* user;


+ (instancetype)sharedContext;
-(void)setUser:(UserAccount *)user;


@end
