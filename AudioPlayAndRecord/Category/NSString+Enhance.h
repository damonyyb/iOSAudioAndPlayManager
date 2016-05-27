//
//  NSString+Enhance.h
//  SmartboxRefact
//
//  Created by TszFung D. Lam on 15/7/24.
//  Copyright (c) 2015年 Shenzhen mesada technology co., LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Enhance)

/**
 *  是否为空
 *
 *  @return
 */
+ (BOOL)isEmptyOrNull:(NSString *)string;

/**
 *  去除空白
 *
 *  @return
 */
- (NSString *)trim;

/**
 *  获取当前时间戳
 *
 *  @return
 */
+ (NSString *)timestamp;

/**
 *  根据日期格式获取时间戳
 *
 *  @param isPhone
 *  @param phone
 *
 *  @return
 */
+ (NSString *)timestampWithDateStr:(NSString *)dateStr withFormat:(NSString *)format;

/**
 *  是否手机号码
 *
 *  @param phone
 *
 *  @return
 */
+ (BOOL)isPhone:(NSString *)phone;

- (BOOL)isPhoneNum;

/**
 *  是否车牌号码
 *
 *  @param formate
 *
 *  @return
 */
- (BOOL)isCarNumber;

/**
 *  一个时间字符串获取date
 *
 *  @param formate
 *
 *  @return
 */
- (NSDate *)createDateByFormatter:(NSString *)formate;

/**
 *  获取字符串在一定宽度内以及指定字体后的高度
 *
 *  @param width
 *  @param font
 *
 *  @return 
 */
- (CGSize)getHeightByWidth:(float)width font:(UIFont *)font;

/**
 *  检查扫描的数据
 *
 *  @return
 */
- (BOOL)isSnWithCheckCode;
/**
 *  匹配密码
 *
 *  @param pwd
 *
 *  @return
 */
- (BOOL)isPasswordNumber;

/**
 *  限制汉字最大长度
 *
 *  @param length
 *
 *  @return 
 */
- (BOOL)isRightChineseWithLength:(NSInteger)length;

/**
 *  限制字符串最大长度
 *
 *  @param length
 *
 *  @return
 */
- (BOOL)isRightStrWithLength:(NSInteger)length;

/**
 *  计算时间间隔
 *
 *  @param dateString
 *
 *  @return 
 */
- (NSDictionary *)cacluateTimeToNow;

/**
 * 验证非负整数
 *
 *
 *  @return
 */
-(BOOL)isDigital;


/**手机号码，限制长度11位*/
- (BOOL)isPhoneNumber;

- (BOOL)isPhoneNumberEx;
    
/**住宅电话*/
- (BOOL)isHomePhoneNumber;

/**姓名*/
- (BOOL)isName;

/**居住地址*/
- (BOOL)isAddress;

/**单位电话*/
- (BOOL)isCompanyPhoneNumber;

@end
