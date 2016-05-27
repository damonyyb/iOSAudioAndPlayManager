//
//  MD5.m
//  inCarTime
//
//  Created by zhu xian on 11-8-5.
//  Copyright 2011 z. All rights reserved.
//
//使用方法
//NSString *myString = @"test";
//NSString *md5 = [myString MD5]; //returns NSString of the MD5 of test
#import "MD5.h"

@implementation NSString (md5)


- (NSString*)MD5
{
	// Create pointer to the string as UTF8
	const char *ptr = [self UTF8String];
	
	// Create byte array of unsigned chars
	unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
	
	// Create 16 byte MD5 hash value, store in buffer
	CC_MD5(ptr, strlen(ptr), md5Buffer);
	
	// Convert MD5 value in the buffer to NSString of hex values
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
	for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) 
		[output appendFormat:@"%02x",md5Buffer[i]];
	
	return output;
}
/*- (NSString *) MD5 
{
	const char *cStr = [self UTF8String];
	unsigned char result[32];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat: 
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15],
			result[16], result[17], result[18], result[19],
			result[20], result[21], result[22], result[23],
			result[24], result[25], result[26], result[27],
			result[28], result[29], result[30], result[31]
			];  
}*/

 /*- (NSString *)MD5;
{
    CC_MD5_CTX digestCtx;
    unsigned char digestBytes[CC_MD5_DIGEST_LENGTH];
    char digestChars[CC_MD5_DIGEST_LENGTH * 2 + 1];
    NSRange stringRange = NSMakeRange(0, [self length]);
    unsigned char buffer[128];
    NSUInteger usedBufferCount;
    CC_MD5_Init(&digestCtx);
    while ([self getBytes:buffer
                maxLength:sizeof(buffer)
               usedLength:&usedBufferCount
                 encoding:NSUnicodeStringEncoding
                  options:NSStringEncodingConversionAllowLossy
                    range:stringRange
           remainingRange:&stringRange])
        CC_MD5_Update(&digestCtx, buffer, usedBufferCount);
    CC_MD5_Final(digestBytes, &digestCtx);
    for (int i = 0;
         i < CC_MD5_DIGEST_LENGTH;
         i++)
        sprintf(&digestChars[2 * i], "%02x", digestBytes[i]);
    return [NSString stringWithUTF8String:digestChars];
}

*/
@end
