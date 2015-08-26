//
//  String+Util.m
//  NeweggCNIphone
//
//  Created by cheney on 11-2-10.
//  Copyright 2011 Newegg. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Util)
static NSNumberFormatter  *instanceFormatter;
+ (NSNumberFormatter *) getNumberFormatter{
    if (instanceFormatter == nil) {
        instanceFormatter = [[NSNumberFormatter alloc] init];
        [instanceFormatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
        [instanceFormatter setCurrencySymbol:@"￥"];
        [instanceFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
        [instanceFormatter setDecimalSeparator:@"."];
        [instanceFormatter setGeneratesDecimalNumbers:TRUE];
        [instanceFormatter setMinimumFractionDigits:2];
        [instanceFormatter setMaximumFractionDigits:2];
    }
    
    return instanceFormatter;
}
- (NSString *)stringByTrimming {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)stringByStrippingHTML {
    NSString *str = self;
    NSRange range;
    
    do {
        range = [str rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch];
        
        if (range.location != NSNotFound) {
            str = [str stringByReplacingCharactersInRange:range withString:@""];
        }
    } while (range.location != NSNotFound);
    
    return str;
}


- (NSString *)stringByMatchRegex:(NSString *)regex {
    return [self stringByMatchRegex:regex ignoreCase:YES];
}
- (NSString *)stringByMatchRegex:(NSString *)regex ignoreCase:(BOOL)ignoreCase
{
    NSString *str = nil;
    NSStringCompareOptions compareOptions = NSRegularExpressionSearch;
    
    if (ignoreCase) {
        compareOptions = compareOptions | NSCaseInsensitiveSearch;
    }
    
    NSRange range = [self rangeOfString:regex options:compareOptions];
    
    if (range.location != NSNotFound) {
        str = [self substringWithRange:range];
    }
    
    return str;
}

- (NSString *)urlComponentEncodeUsingUTF8Encoding {
    return [self urlComponentEncodeUsingEncoding:NSUTF8StringEncoding];
}

-(NSString *)urlComponentEncodeUsingEncoding:(NSStringEncoding)encoding {
    NSString *str = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                          (__bridge CFStringRef)self,
                                                                                          NULL,
                                                                                          (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                          CFStringConvertNSStringEncodingToEncoding(encoding));
    return str;
}

- (NSString *)urlComponentDecodeUsingUTF8Encoding {
    return [self urlComponentDecodeUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)urlComponentDecodeUsingEncoding:(NSStringEncoding)encoding {
    NSString *str = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                          (__bridge CFStringRef)self,
                                                                                                          CFSTR(""),
                                                                                                          CFStringConvertNSStringEncodingToEncoding(encoding));
    return str;
}

- (NSString *)urlEncodedUsingUTF8Encoding{
    return (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                (__bridge CFStringRef)self,
                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                NULL,
                                                                                kCFStringEncodingUTF8));
}


- (BOOL)hasNonWhitespaceText {
    return [self stringByTrimming].length > 0;
}

- (BOOL)containsString:(NSString *)string {
    NSRange range = [self rangeOfString:string];
    return range.location != NSNotFound;
}

- (BOOL)isEmailAddress {
    return [self isMatchRegex:@"^[\\w`~!#$%^&*\\-+={}\\\\|:'./?]+@[\\w-]+(\\.[\\w-]+)+$"];
}

- (BOOL)isNumber {
    return [self isMatchRegex:@"^[0-9]+$"];
}

- (BOOL)isMatchRegex:(NSString *)regex {
    NSRange range = [self rangeOfString:regex options:NSRegularExpressionSearch];
    
    return range.location != NSNotFound;
}

+ (NSString *)UUIDString{
    CFUUIDRef UUIDRef = CFUUIDCreate(NULL);
    CFStringRef stringRef = CFUUIDCreateString(NULL, UUIDRef);
    CFRelease(UUIDRef);
    return  (__bridge_transfer NSString *)stringRef;
}

+ (NSString *)stringWithWeiboDateTime:(NSDate *)date {
    static NSTimeInterval tiSecond  = 1;
    static NSTimeInterval tiMinute  = 1 * 60;
    static NSTimeInterval tiHour    = 1 * 60 * 60;
    
    NSString *result = nil;
    NSDate *nowDate = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:(+8 * 60 * 60)];
    
    [dateFormatter setTimeZone:tz];
    
    NSDateComponents *dateComponent = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    NSDateComponents *nowComponent = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:nowDate];
    if ([dateComponent year] != [nowComponent year]) {
        [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
        
        result = [dateFormatter stringFromDate:date];
    } else if ([dateComponent month] != [nowComponent month] || [dateComponent day] != [nowComponent day]) {
        [dateFormatter setDateFormat:@"MM月dd日 HH:mm"];
        
        result = [dateFormatter stringFromDate:date];
    } else {
        NSTimeInterval timespan = [nowDate timeIntervalSinceDate:date];
        if (timespan < 1) {
            result = @"刚刚";
        } else if (timespan < tiMinute) {
            NSInteger second = timespan / tiSecond;
            result = [NSString stringWithFormat:@"%ld秒前", (long)second];
        } else if (timespan < tiHour) {
            NSInteger minute = timespan / tiMinute;
            result = [NSString stringWithFormat:@"%ld分钟前", (long)minute];
        } else {
            [dateFormatter setDateFormat:@"今天 HH:mm"];
            
            result = [dateFormatter stringFromDate:date];
        }
    }
    
    
    return result;
}


- (NSString *)encrptWithBeginingLeftPartLength:(NSInteger)bLen
                          endingLeftPartLength:(NSInteger)eLen{
    NSMutableString *result = [NSMutableString string];
    
    
    for(int i = 0; i < self.length; i++){
        if(i < bLen || self.length - i <= eLen){
            [result appendFormat:@"%c", [self characterAtIndex:i]];
        }
        else{
            [result appendString:@"*"];
        }
    }
    
    return result;
}

- (NSString *)stringBySafeLoginName {
    NSMutableString *customerName = [NSMutableString stringWithString:self];
    
    NSRange replaceRange = NSMakeRange(0, 1);
    NSInteger stringLength = customerName.length;
    
    for (int i = 0; i < 2; i++) {
        replaceRange.location += 1;
        
        if (stringLength > replaceRange.location) {
            [customerName replaceCharactersInRange:replaceRange withString:@"*"];
        }
    }
    
    return customerName;
}

+ (NSString *) currencyWithDecimal:(NSDecimalNumber *) aValue
                    currencySymbol:(NSString *)symbol
                 minFractionDigits:(NSInteger) min
                 maxFractionDigits:(NSInteger)max
{
    NSNumberFormatter * formatter  = [NSString getNumberFormatter];
    
    //[formatter setNumberStyle: NSNumberFormatterCurrencyStyle]; // Performance Issue
    //[formatter setDecimalSeparator:@"."];
    [formatter setPositiveFormat:[NSString stringWithFormat:@"%@#0.00",symbol]];
    [formatter setNegativeFormat:[NSString stringWithFormat:@"－%@#0.00",symbol]];
    [formatter setDecimalSeparator:@"."];
    [formatter setGeneratesDecimalNumbers:TRUE];
    [formatter setMinimumFractionDigits:min];
    [formatter setMaximumFractionDigits:max];
    //[formatter setCurrencySymbol:symbol];
    
    return [formatter stringFromNumber:aValue];
}


+ (NSString *) currencyWithDecimal:(NSDecimalNumber *) aValue{
    return [NSString currencyWithDecimal:aValue
                          currencySymbol:@"￥"
                       minFractionDigits:2
                       maxFractionDigits:2];
}

+ (NSString *) neweggPointWithDecimal:(NSDecimalNumber *) aValue{
    
    if ([aValue compare:[NSDecimalNumber zero]] == NSOrderedSame) {
        return @"0";
    }
    
    NSDecimalNumber *pointDecNumber = [aValue decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"10"]];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    [formatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    [formatter setMinimumFractionDigits:0];
    [formatter setMaximumFractionDigits:2];
    [formatter setGeneratesDecimalNumbers:TRUE];
    [formatter setDecimalSeparator:@"."];
    [formatter setGroupingSeparator:@""];
    
    return [formatter stringFromNumber:pointDecNumber];
}

@end



