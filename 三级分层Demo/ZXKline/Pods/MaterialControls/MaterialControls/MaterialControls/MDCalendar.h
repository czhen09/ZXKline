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

#import <UIKit/UIKit.h>
#import "MDCalendarDateHeader.h"

@class MDCalendar;

typedef NS_OPTIONS(NSInteger, MDCalendarCellStyle) {
  MDCalendarCellStyleCircle = 0,
  MDCalendarCellStyleRectangle = 1
};

typedef NS_OPTIONS(NSInteger, MDCalendarCellState) {
  MDCalendarCellStateNormal = 0,
  MDCalendarCellStateSelected = 1,
  MDCalendarCellStatePlaceholder = 1 << 1,
  MDCalendarCellStateDisabled = 1 << 2,
  MDCalendarCellStateToday = 1 << 3,
  MDCalendarCellStateWeekend = 1 << 4,
  // TODO tach thang nay ra khoi cell state - later
  MDCalendarCellStateWeekTitle = 1 << 5,
  MDCalendarCellStateMonthTitle = 1 << 6,
  MDCalendarCellStateButton = 1 << 7
};

typedef NS_ENUM(NSInteger, MDCalendarTheme) {
  MDCalendarThemeLight = 1,
  MDCalendarThemeDark = 2
};

NS_ASSUME_NONNULL_BEGIN
@protocol MDCalendarDelegate <NSObject>
@required
- (void)calendar:(MDCalendar *)calendar didSelectDate:(nullable NSDate *)date;
@end

@interface MDCalendar : UIView <UIAppearance>

@property(weak, nonatomic) IBOutlet MDCalendarDateHeader *dateHeader;
@property(weak, nonatomic) IBOutlet id<MDCalendarDelegate> delegate;
@property(assign, nonatomic) BOOL showPlaceholder;

@property(copy, nonatomic) NSDate *currentDate;
@property(copy, nonatomic) NSDate *selectedDate;
@property(copy, nonatomic) NSDate *minimumDate;
@property(copy, nonatomic) NSDate *currentMonth;

@property(assign, nonatomic) MDCalendarTheme theme;
@property(assign, nonatomic) NSUInteger firstWeekday;

@property(strong, nonatomic) NSMutableDictionary *backgroundColors;
@property(strong, nonatomic) NSMutableDictionary *titleColors;
- (void)reloadData;

@end
NS_ASSUME_NONNULL_END