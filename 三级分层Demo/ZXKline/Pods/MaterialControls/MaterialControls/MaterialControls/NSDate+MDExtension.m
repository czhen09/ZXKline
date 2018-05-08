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

#import "NSCalendarHelper.h"
#import "NSDate+MDExtension.h"

@implementation NSDate (MDExtension)

- (NSInteger)mdYear {
  NSCalendar *calendar = [NSCalendarHelper mdSharedCalendar];
  NSDateComponents *component =
      [calendar components:NSCalendarUnitYear fromDate:self];
  return component.year;
}

- (NSInteger)mdMonth {
  NSCalendar *calendar = [NSCalendarHelper mdSharedCalendar];
  NSDateComponents *component =
      [calendar components:NSCalendarUnitMonth fromDate:self];
  return component.month;
}

- (NSInteger)mdDay {
  NSCalendar *calendar = [NSCalendarHelper mdSharedCalendar];
  NSDateComponents *component =
      [calendar components:NSCalendarUnitDay fromDate:self];
  return component.day;
}

- (NSInteger)mdWeekday {
  NSCalendar *calendar = [NSCalendarHelper mdSharedCalendar];
  NSDateComponents *component =
      [calendar components:NSCalendarUnitWeekday fromDate:self];
  return component.weekday;
}

- (NSInteger)mdHour {
  NSCalendar *calendar = [NSCalendarHelper mdSharedCalendar];
  NSDateComponents *component =
      [calendar components:NSCalendarUnitHour fromDate:self];
  return component.hour;
}

- (NSInteger)mdMinute {
  NSCalendar *calendar = [NSCalendarHelper mdSharedCalendar];
  NSDateComponents *component =
      [calendar components:NSCalendarUnitMinute fromDate:self];
  return component.minute;
}

- (NSInteger)mdSecond {
  NSCalendar *calendar = [NSCalendarHelper mdSharedCalendar];
  NSDateComponents *component =
      [calendar components:NSCalendarUnitSecond fromDate:self];
  return component.second;
}

- (NSInteger)mdNumberOfDaysInMonth {
  NSCalendar *c = [NSCalendarHelper mdSharedCalendar];
  NSRange days =
      [c rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self];
  return days.length;
}

- (NSString *)mdStringWithFormat:(NSString *)format {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  formatter.dateFormat = format;
  return [formatter stringFromDate:self];
}

- (NSDate *)mdDateByAddingMonths:(NSInteger)months {
  NSCalendar *calendar = [NSCalendarHelper mdSharedCalendar];
  NSDateComponents *components = [[NSDateComponents alloc] init];
  [components setMonth:months];

  return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)mdDateBySubtractingMonths:(NSInteger)months {
  return [self mdDateByAddingMonths:-months];
}

- (NSDate *)mdDateByAddingDays:(NSInteger)days {
  NSCalendar *calendar = [NSCalendarHelper mdSharedCalendar];
  NSDateComponents *components = [[NSDateComponents alloc] init];
  [components setDay:days];
  return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)mdDateBySubtractingDays:(NSInteger)days {
  return [self mdDateByAddingDays:-days];
}

- (NSInteger)mdYearsFrom:(NSDate *)date {
  NSCalendar *calendar = [NSCalendarHelper mdSharedCalendar];
  NSDateComponents *dateComponents = [calendar
      components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
        fromDate:date];
  [dateComponents setDay:1];
  [dateComponents setMonth:1];

  NSDateComponents *myComponents = [calendar
      components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
        fromDate:self];
  [myComponents setDay:1];
  [myComponents setMonth:1];

  NSDateComponents *components =
      [calendar components:NSCalendarUnitYear
                  fromDate:[calendar dateFromComponents:dateComponents]
                    toDate:[calendar dateFromComponents:myComponents]
                   options:0];
  return components.year;
}

- (NSInteger)mdMonthsFrom:(NSDate *)date {
  NSCalendar *calendar = [NSCalendarHelper mdSharedCalendar];
  NSDateComponents *dateComponents = [calendar
      components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
        fromDate:date];
  [dateComponents setDay:1];
    
  NSDateComponents *myComponents = [calendar
      components:NSCalendarUnitDay
 | NSCalendarUnitMonth
 | NSCalendarUnitYear

        fromDate:self];
  [myComponents setDay:1];
    
  NSDateComponents *components =
      [calendar components:NSCalendarUnitMonth
                  fromDate:[calendar dateFromComponents:dateComponents]
                    toDate:[calendar dateFromComponents:myComponents]
                   options:0];
  return components.month;
}

- (NSInteger)mdDaysFrom:(NSDate *)date {
  NSCalendar *calendar = [NSCalendarHelper mdSharedCalendar];
  NSDateComponents *components = [calendar components:NSCalendarUnitDay
                                             fromDate:date
                                               toDate:self
                                              options:0];
  return components.day;
}

- (BOOL)mdIsEqualToDateForMonth:(NSDate *)date {
  return self.mdYear == date.mdYear && self.mdMonth == date.mdMonth;
}

- (BOOL)mdIsEqualToDateForDay:(NSDate *)date {
  return self.mdYear == date.mdYear && self.mdMonth == date.mdMonth &&
         self.mdDay == date.mdDay;
}

@end
