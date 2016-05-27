//
//  NSString+Enhance.m
//  SmartboxRefact
//
//  Created by TszFung D. Lam on 15/7/24.
//  Copyright (c) 2015年 Shenzhen mesada technology co., LTD. All rights reserved.
//

#import "NSString+Enhance.h"


@implementation NSString (Enhance)

+ (BOOL) isEmptyOrNull:(NSString *)string {
    if (!string) {
        return YES;
    } else if ([string isEqual:[NSNull null]]) {
        return YES;
    } else {
        if (string.length == 0 || [string isEqualToString:@""]) {
            return YES;
        }
        NSString *trimedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([trimedString length] == 0) {
            return YES;
        } else {
            return NO;
        }
    }
}


- (BOOL)match:(NSString *)pattern
{
    NSRegularExpression  *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    NSArray *results  =[regex matchesInString:self options:0 range:NSMakeRange(0,self.length)];
    return results.count > 0;
}

- (NSString *)trim {
    NSString *temp = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableString *string = [temp mutableCopy];
    CFStringTrimWhitespace((CFMutableStringRef)string);
    NSString *result = [string copy];
    return result;
}

+ (NSString *)timestamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeInterval = [date timeIntervalSince1970] * 1000;
    NSString *timestamp = [NSString stringWithFormat:@"%f", timeInterval];
    return timestamp;
}

+ (NSString *)timestampWithDateStr:(NSString *)dateStr withFormat:(NSString *)format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];//yyyy-MM-dd HH:mm:ss
    NSDate *date = [dateFormatter dateFromString:dateStr];
    NSTimeInterval timeInterval = [date timeIntervalSince1970] * 1000;
    NSString *timestamp = [NSString stringWithFormat:@"%f",timeInterval];
    return timestamp;
}



+ (BOOL)isPhone:(NSString *)phone
{
    NSString *reg = @"^(13[0-9]|15[012356789]|17[3678]|18[0-9]|14[57])[0-9]{8}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",reg];
    if ([predicate evaluateWithObject:phone]) {
        return YES;
    }
    return NO;
}

- (BOOL)isPhoneNum
{
    NSString *reg = @"^(13[0-9]|15[012356789]|17[3678]|18[0-9]|14[57])[0-9]{8}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",reg];
    if ([predicate evaluateWithObject:self]) {
        return YES;
    }
    return NO;
}

- (BOOL)isCarNumber
{
    
    NSArray *provinces = @[@"京",@"津",@"渝",@"沪",@"冀",@"晋",@"辽",@"吉",@"黑",
                           @"苏",@"浙",@"皖",@"闽",@"赣",@"鲁",@"豫",@"鄂",@"湘",
                           @"粤",@"琼",@"川",@"贵",@"云",@"陕",@"甘",@"青",@"台",@"蒙",@"桂",@"宁",@"新",@"藏",@"港",@"澳"];
    
    NSString *Regex = @"^[\u4e00-\u9fa5]{1}[A-Z_a-z]{1}[A-Z_a-z_0-9]{5}";
    NSPredicate *p = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",Regex];
    BOOL istrue = [p evaluateWithObject:self];
    if (istrue) {
        NSString *str = [self substringToIndex:1];
        return [provinces containsObject:str];
    }
    return NO;
}

- (BOOL)isRightChineseWithLength:(NSInteger)length{
    NSString *Regex = [NSString stringWithFormat:@"^[\u4e00-\u9fa5]{1,%ld}",(long)length];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",Regex];
    BOOL istrue = [p evaluateWithObject:self];
    return istrue;
}

- (BOOL)isRightStrWithLength:(NSInteger)length{
    NSString *Regex = [NSString stringWithFormat:@"^[A-Z_a-z]{1,%ld}",(long)length];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",Regex];
    BOOL istrue = [p evaluateWithObject:self];
    return istrue;
}

- (BOOL)isSnWithCheckCode{
    NSString *Regex = @"^[0-9]{15}\\|[A-Z_0-9]{6}";
    NSPredicate *p = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",Regex];
    BOOL istrue = [p evaluateWithObject:self];
    return istrue;
}

- (BOOL)isPasswordNumber{
    NSString *Regex = @"^[A-Z_0-9_a-z]{6,16}";
    NSPredicate *p = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",Regex];
    BOOL istrue = [p evaluateWithObject:self];
    return istrue;
}

- (NSDate *)createDateByFormatter:(NSString *)formate {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:formate];
    return [dateFormatter dateFromString:self];
}

- (CGSize)getHeightByWidth:(float)width font:(UIFont *)font {
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self];
    NSRange range = [self rangeOfString:self];
    [attrStr addAttribute:NSFontAttributeName
                    value:font
                    range:range];
    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize btnSize = [attrStr boundingRectWithSize:CGSizeMake(width, 0)
                                           options:options
                                           context:nil].size;
    btnSize.height = ceilf(btnSize.height);
    return btnSize;
}

- (NSDictionary *)cacluateTimeToNow{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSDate *date = [dateFormatter dateFromString:self];
    
    NSDate *deadLineDate = [date dateByAddingTimeInterval:10*24*60*60];
    if (!date) return nil;
    NSString *state = [deadLineDate compare:[NSDate date]] == NSOrderedAscending ? @"1": @"0";  //0:过期  1:剩余

    
    NSCalendar *cal = [NSCalendar currentCalendar];
    int initFlags =  NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    NSDateComponents *d = [cal components:initFlags fromDate:deadLineDate toDate:[NSDate date] options:0];
    NSDictionary *dic = @{@"day":@(d.day),
                          @"state":state};
    NSLog(@"%@",dic);
    return dic;
}

-(BOOL)isDigital
{
    NSString *Regex = @"^\\d+$";
    NSPredicate *p = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",Regex];
    BOOL istrue = [p evaluateWithObject:self];
    return istrue;
}

- (BOOL)isName{
    //1.2位以上中英文和∙•・●各种大小的点还有空格
    return [self match:@"^[\u4E00-\u9FA5a-zA-Z∙•・●· ]{2,}$"];
}

- (BOOL)isPhoneNumber{
    //1.全部是数字
    //2.11位
    //3.以13\15\17\18开头
    return [self match:@"^1[3578]\\d{9}$"];
}

- (BOOL)isPhoneNumberEx{
    //1.全部是数字
    //2.11位
    //3.以13\15\17\18开头
    return [self match:@"^1[3578]\\d{9}$"];
}
- (BOOL)isCompanyPhoneNumber{
    //手机号，电话号码都行
    return [self match:@"^1[3578]\\d{9}$|^(0[1-9]{2})\\d{8}$|^(0[1-9]{3}(\\d{7,8}))$"];
}

- (BOOL)isAddress{
    // 2.一位以上的汉字英文数字，不限长度
    return [self match:@"^[\u4E00-\u9FA5a-zA-Z0-9]{1,}"];
}

- (BOOL)isHomePhoneNumber{
    //电话区号都是0开头，3位或者4位
    //3位区号后边电话号码应该都是8位，4位区号的后边电话号码7位8位都有
    //-设置成为有或者没有都行，改了 不要 - 了
    //    return [self match:@"^(0[1-9]{2})-?\\d{8}$|^(0[1-9]{3}-?(\\d{7,8}))$"];
    return [self match:@"^(0[1-9]{2})\\d{7,8}$|^(0[1-9]{3}(\\d{7,8}))$"];
}
@end
