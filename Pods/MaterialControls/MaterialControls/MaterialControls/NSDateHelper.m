// The MIT License (MIT)
//
// Copyright (c) 2015 FPT Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NSDateHelper.h"
#import "NSCalendarHelper.h"

@implementation NSDateHelper
+ (NSDate *)mdDateFromString:(NSString *)string format:(NSString *)format {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  formatter.dateFormat = format;
  return [formatter dateFromString:string];
}

+ (NSDate *)mdDateWithYear:(NSInteger)year
                     month:(NSInteger)month
                       day:(NSInteger)day {
  NSCalendar *calendar = [NSCalendarHelper mdSharedCalendar];
  NSDateComponents *components = [[NSDateComponents alloc] init];
  components.year = year;
  components.month = month;
  components.day = day;
  return [calendar dateFromComponents:components];
}

+ (BOOL)prefers24Hour {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setLocale:[NSLocale currentLocale]];
  [formatter setDateStyle:NSDateFormatterNoStyle];
  [formatter setTimeStyle:NSDateFormatterShortStyle];
  NSString *dateString = [formatter stringFromDate:[NSDate date]];
  NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
  NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
  BOOL is24h =
      (amRange.location == NSNotFound && pmRange.location == NSNotFound);
  //[formatter release];
  return is24h;
}
@end
