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

#import <Foundation/Foundation.h>

@interface NSDate (MDExtension)

@property(readonly, nonatomic) NSInteger mdYear;
@property(readonly, nonatomic) NSInteger mdMonth;
@property(readonly, nonatomic) NSInteger mdDay;
@property(readonly, nonatomic) NSInteger mdWeekday;
@property(readonly, nonatomic) NSInteger mdHour;
@property(readonly, nonatomic) NSInteger mdMinute;
@property(readonly, nonatomic) NSInteger mdSecond;

@property(readonly, nonatomic) NSInteger mdNumberOfDaysInMonth;

- (nullable NSDate*)mdDateByAddingMonths:(NSInteger)months;
- (nullable  NSDate*)mdDateBySubtractingMonths:(NSInteger)months;
- (nullable  NSDate*)mdDateByAddingDays:(NSInteger)days;
- (nullable NSDate*)mdDateBySubtractingDays:(NSInteger)days;
- (nonnull NSString*)mdStringWithFormat:(nonnull NSString*)format;

- (NSInteger)mdYearsFrom:(nonnull NSDate*)date;
- (NSInteger)mdMonthsFrom:(nonnull NSDate*)date;
- (NSInteger)mdDaysFrom:(nonnull NSDate*)date;

- (BOOL)mdIsEqualToDateForMonth:(nonnull NSDate*)date;
- (BOOL)mdIsEqualToDateForDay:(nonnull NSDate*)date;
@end
