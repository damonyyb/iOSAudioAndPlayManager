//
//  UserAccount.h
//  HeraldleasingWorkAssistant
//
//  Created by Mesada on 15/5/16.
//  Copyright (c) 2015年 mesada. All rights reserved.
//

//用户账号信息
#import <Foundation/Foundation.h>


@interface UserAccount : NSObject
@property (nonatomic,strong) NSString* account;
@property (nonatomic,strong) NSString* password;
@property (nonatomic,strong) NSString* userId;


@end
