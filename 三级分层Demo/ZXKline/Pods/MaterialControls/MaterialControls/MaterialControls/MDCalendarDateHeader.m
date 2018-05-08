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

#import "MDCalendarDateHeader.h"
#import "MDCalendar.h"
#import "UIView+MDExtension.h"
#import "UIColorHelper.h"
#import "UIFontHelper.h"

@implementation MDCalendarDateHeader {
  NSDictionary *viewsDictionary;
  NSMutableArray *constraintPortrait;
  NSArray *constraintLandscape;
  NSDictionary *metrics;

  CALayer *_backgroundLayer;
  UIFont *fontDatePortrait;
  UIFont *fontDateLandscape;
}

@synthesize monthFormat = _monthFormat;
@synthesize date = _date;

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _dateFormatter = [[NSDateFormatter alloc] init];
    _textColor = [UIColor whiteColor];
    _headerColor = [UIColorHelper colorWithRGBA:@"#00796b"]; //	Teal
    _headerBackgroundColor = [UIColorHelper colorWithRGBA:@"#009688"];

    _labelDayName = [[UILabel alloc] initWithFrame:CGRectZero];
    _labelDayName.textAlignment = NSTextAlignmentCenter;
    _labelDayName.font = [UIFontHelper robotoFontOfSize:13];
    [_labelDayName setTextColor:_textColor];
    [_labelDayName setBackgroundColor:_headerColor];

    _labelMonthName = [[UILabel alloc] initWithFrame:CGRectZero];
    _labelMonthName.textAlignment = NSTextAlignmentCenter;
    _labelMonthName.font = [UIFontHelper robotoFontOfSize:25];
    [_labelMonthName setTextColor:_textColor];
    [_labelMonthName setBackgroundColor:[UIColor clearColor]];

    fontDatePortrait = [UIFontHelper robotoFontOfSize:55];
    fontDateLandscape = [UIFontHelper robotoFontOfSize:75];

    _labelDate = [[UILabel alloc] initWithFrame:CGRectZero];
    _labelDate.textAlignment = NSTextAlignmentCenter;
    _labelDate.font = fontDatePortrait;
    [_labelDate setTextColor:_textColor];
    [_labelDate setBackgroundColor:[UIColor clearColor]];

    _labelYear = [[UILabel alloc] initWithFrame:CGRectZero];
    _labelYear.textAlignment = NSTextAlignmentCenter;
    _labelYear.font = [UIFontHelper robotoFontOfSize:25];
    [_labelYear setBackgroundColor:[UIColor clearColor]];
    _labelYear.textColor = [_textColor colorWithAlphaComponent:0.5];

    _monthFormat = MDCalendarMonthSymbolsFormatShortUppercase;

    _labelDayName.translatesAutoresizingMaskIntoConstraints = NO;
    _labelMonthName.translatesAutoresizingMaskIntoConstraints = NO;
    _labelDate.translatesAutoresizingMaskIntoConstraints = NO;
    _labelYear.translatesAutoresizingMaskIntoConstraints = NO;

    [self setBackgroundColor:_headerBackgroundColor];

    [self addSubview:_labelDayName];
    [self addSubview:_labelMonthName];
    [self addSubview:_labelDate];
    [self addSubview:_labelYear];

    // label interaction
    [self.labelDate setUserInteractionEnabled:NO];
    [self.labelMonthName setUserInteractionEnabled:NO];

    UITapGestureRecognizer *showYearSelectorGesture =
        [[UITapGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(showYearSelector)];
    UITapGestureRecognizer *showCalendarSelectorGestureForLabelDate =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(showCalendar)];
    UITapGestureRecognizer *showCalendarSelectorGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(showCalendar)];

    [self.labelDate
        addGestureRecognizer:showCalendarSelectorGestureForLabelDate];
    [self.labelMonthName addGestureRecognizer:showCalendarSelectorGesture];

    [self.labelYear setUserInteractionEnabled:YES];
    [self.labelYear addGestureRecognizer:showYearSelectorGesture];

    if ([[[UIDevice currentDevice] systemVersion] intValue] < 8) {

    } else {
      [self setLayoutMargins:UIEdgeInsetsZero];
    }
    //    viewsDictionary = @{
    //      @"labelDayName" : self.labelDayName,
    //      @"labelMonthName" : self.labelMonthName,
    //      @"labelDate" : self.labelDate,
    //      @"labelYear" : self.labelYear
    //    };

    viewsDictionary = NSDictionaryOfVariableBindings(
        _labelDayName, _labelMonthName, _labelDate, _labelYear);

    NSArray *constraintHorizontalString = [NSArray
        arrayWithObjects:@"H:|[_labelDayName]|", @"H:|-[_labelMonthName]-|",
                         @"H:|-[_labelDate]-|", @"H:|-[_labelYear]-|", nil];

    NSArray *constraint_H;
    for (int i = 0; i < [constraintHorizontalString count]; i++) {
      constraint_H = [NSLayoutConstraint
          constraintsWithVisualFormat:[constraintHorizontalString
                                          objectAtIndex:i]
                              options:0
                              metrics:nil
                                views:viewsDictionary];
      [self addConstraints:constraint_H];
    }
  };
  [self layoutSubviews];
  return self;
}

- (void)layoutSubviews {
  UIInterfaceOrientation orientation =
      [[UIApplication sharedApplication] statusBarOrientation];

  switch (orientation) {
  case UIInterfaceOrientationPortrait:
  case UIInterfaceOrientationPortraitUpsideDown: {
    // load the portrait view
    _labelDate.font = fontDatePortrait;
  }

  break;
  case UIInterfaceOrientationLandscapeLeft:
  case UIInterfaceOrientationLandscapeRight: {
    // load the landscape view
    _labelDate.font = fontDateLandscape;
  } break;
  case UIInterfaceOrientationUnknown:
    break;
  }

  int h = self.mdHeight - _labelDayName.font.lineHeight * 2;
  int spacing = (h - _labelMonthName.font.lineHeight -
                 _labelDate.font.lineHeight - _labelYear.font.lineHeight) /
                4;
  if (!constraintPortrait) {
    constraintPortrait = [[NSMutableArray alloc] init];
    spacing = 8;
  } else {
    [self removeConstraints:constraintPortrait];
  }

  [constraintPortrait removeAllObjects];
  metrics = @{ @"spacing" : @(spacing) };
  NSArray *constraintVerticalString = [NSArray
      arrayWithObjects:
          [NSString
              stringWithFormat:@"V:|[_labelDayName(%i)]-spacing-["
                               @"_labelMonthName]-spacing-[_labelDate(%i)]",
                               (int)ceil(_labelDayName.font.lineHeight * 2),
                               (int)ceil(_labelDate.font.lineHeight)],
          [NSString stringWithFormat:@"V:[_labelYear(%i)]-spacing-|",
                                     (int)ceil(_labelYear.font.lineHeight)],
          nil];

  NSArray *constraint_V;
  for (int i = 0; i < [constraintVerticalString count]; i++) {
    constraint_V = [NSLayoutConstraint
        constraintsWithVisualFormat:[constraintVerticalString objectAtIndex:i]
                            options:0
                            metrics:metrics
                              views:viewsDictionary];
    [constraintPortrait addObjectsFromArray:constraint_V];
  }

  [self addConstraints:constraintPortrait];
  [super layoutSubviews];
}

- (void)setTheme:(MDCalendarTheme)theme {
  if (_theme != theme) {
    _theme = theme;

    if (_theme == MDCalendarThemeDark) {
      _headerBackgroundColor = [UIColorHelper colorWithRGBA:@"#374248"];
      _headerColor = [UIColorHelper colorWithRGBA:@"#80CBC4"];
    } else if (_theme == MDCalendarThemeLight) {
      _headerBackgroundColor = [UIColorHelper colorWithRGBA:@"#009688"];
      _headerColor = [UIColorHelper colorWithRGBA:@"#00796B"];
    }

    [self setBackgroundColor:_headerBackgroundColor];
    [_labelDayName setBackgroundColor:_headerColor];
  }
}
- (void)setDate:(NSDate *)date {
  if (_date != date) {
    _date = date;
  }

  _dateFormatter.dateFormat = @"EEEE";
  _labelDayName.text = [_dateFormatter stringFromDate:date];

  _dateFormatter.dateFormat = @"MM";
  NSString *monthName = @"";
  if (_monthFormat == MDCalendarMonthSymbolsFormatShort ||
      _monthFormat == MDCalendarMonthSymbolsFormatShortUppercase) {
    monthName = [[_dateFormatter shortMonthSymbols]
        objectAtIndex:([[_dateFormatter stringFromDate:date] intValue] - 1)];
    if (_monthFormat == MDCalendarMonthSymbolsFormatShortUppercase) {
      monthName = [monthName uppercaseString];
    }
  } else {
    if (_monthFormat == MDCalendarMonthSymbolsFormatFull) {
      monthName = [[_dateFormatter monthSymbols]
          objectAtIndex:([[_dateFormatter stringFromDate:date] intValue] - 1)];
    }
  }
  _labelMonthName.text = monthName;

  _dateFormatter.dateFormat = @"dd";
  _labelDate.text = [_dateFormatter stringFromDate:date];

  _dateFormatter.dateFormat = @"yyyy";
  _labelYear.text = [_dateFormatter stringFromDate:date];
}

- (void)setMonthFormat:(MDCalendarMonthSymbolsFormat)monthFormat {
  if (_monthFormat != monthFormat) {
    _monthFormat = monthFormat;
  }
}

- (void)showYearSelector {
  [self.labelDate setUserInteractionEnabled:YES];
  [self.labelMonthName setUserInteractionEnabled:YES];
  [self.labelYear setUserInteractionEnabled:NO];

  [self.labelDate
      setTextColor:[self.labelDate.textColor colorWithAlphaComponent:0.5]];
  [self.labelMonthName
      setTextColor:[self.labelMonthName.textColor colorWithAlphaComponent:0.5]];
  [self.labelYear
      setTextColor:[self.labelYear.textColor colorWithAlphaComponent:1.0]];

  if (_delegate) {
    [_delegate didSelectYear];
  }
}

- (void)showCalendar {
  [self.labelDate setUserInteractionEnabled:NO];
  [self.labelMonthName setUserInteractionEnabled:NO];
  [self.labelYear setUserInteractionEnabled:YES];

  [self.labelDate
      setTextColor:[self.labelDate.textColor colorWithAlphaComponent:1.0]];
  [self.labelMonthName
      setTextColor:[self.labelMonthName.textColor colorWithAlphaComponent:1.0]];
  [self.labelYear
      setTextColor:[self.labelYear.textColor colorWithAlphaComponent:0.5]];

  if (_delegate) {
    [_delegate didSelectCalendar];
  }
}
@end