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

#ifndef iOSUILib_MDCalendarYearSelector_h
#define iOSUILib_MDCalendarYearSelector_h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MDCalendarYearSelectorDelegate<NSObject>
@required
- (void)calendarYearDidSelected:(NSInteger)year;
@optional
@end

@interface MDCalendarYearSelector: UIView<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic) UITableView* tableView;
@property(weak, nonatomic) IBOutlet id<MDCalendarYearSelectorDelegate> delegate;
@property(nonatomic) NSDictionary <NSNumber*, UIColor*>* titleColors UI_APPEARANCE_SELECTOR;
@property(nonatomic) NSDictionary <NSNumber*, UIColor*>* backgroundColors UI_APPEARANCE_SELECTOR;

@property(copy, nonatomic) NSDate* minimumDate;

@property(nonatomic) NSInteger currentYear;

- (instancetype)initWithFrame:(CGRect)frame
              withMiniminDate:(NSDate*)minDate
               andMaximumDate:(NSDate*)maxDate;
- (void)relayout;

@end
NS_ASSUME_NONNULL_END
#endif


