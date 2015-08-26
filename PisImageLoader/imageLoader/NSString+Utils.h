//
//  String+Util.h
//  NeweggCNIphone
//
//  Created by cheney on 11-2-10.
//  Copyright 2011 Newegg. All rights reserved.
//
#import <Foundation/Foundation.h>

#define STRING_EMPTY        @""
#define STRING_TEXT(text)   (text != nil ? [text stringByTrimming] : STRING_EMPTY)

@interface NSString (Util)

- (NSString *)stringByTrimming;

- (NSString *)stringByStrippingHTML;

- (NSString *)stringByEncodeHTML;
- (NSString *)stringByDecodeHTML;

- (NSString *)stringByMatchRegex:(NSString *)regex;
- (NSString *)stringByMatchRegex:(NSString *)regex ignoreCase:(BOOL)ignoreCase;

- (NSString *)urlComponentEncodeUsingUTF8Encoding;
- (NSString *)urlComponentEncodeUsingEncoding:(NSStringEncoding)encoding;

- (NSString *)urlComponentDecodeUsingUTF8Encoding;
- (NSString *)urlComponentDecodeUsingEncoding:(NSStringEncoding)encoding;

- (NSString *)urlEncodedUsingUTF8Encoding;

- (BOOL)hasNonWhitespaceText;
- (BOOL)containsString:(NSString *)string;

- (BOOL)isNumber;
- (BOOL)isEmailAddress;
- (BOOL)isMatchRegex:(NSString *)regex;

+ (NSString *)UUIDString;
+ (NSString *)stringWithWeiboDateTime:(NSDate *)date;
- (NSString *)stringBySafeLoginName;

+ (NSString *) currencyWithDecimal:(NSDecimalNumber *) aValue;
+ (NSString *) neweggPointWithDecimal:(NSDecimalNumber *) aValue;


/*!
 * 格式化字符串（除了开头@bbLen个字符和结尾@beLen个字符，其余用*代替）
 */
- (NSString *)encrptWithBeginingLeftPartLength:(NSInteger)bLen
                          endingLeftPartLength:(NSInteger)eLen;

@end
