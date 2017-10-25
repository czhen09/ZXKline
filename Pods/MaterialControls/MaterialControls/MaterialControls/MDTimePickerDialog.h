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

#ifndef iOSUILib_MDTimerPickerDialog_h
#define iOSUILib_MDTimerPickerDialog_h

#import <UIKit/UIKit.h>

@class MDTimePickerDialog;

typedef NS_ENUM(NSInteger, MDClockMode) { MDClockMode12H, MDClockMode24H };

typedef NS_ENUM(NSInteger, MDTimePickerTheme) {
  MDTimePickerThemeLight = 1,
  MDTimePickerThemeDark,
};

NS_ASSUME_NONNULL_BEGIN
@protocol MDTimePickerDialogDelegate <NSObject>

- (void)timePickerDialog:(MDTimePickerDialog *)timePickerDialog
           didSelectHour:(NSInteger)hour
               andMinute:(NSInteger)minute;

@end

@interface MDTimePickerDialog : UIControl

/// note: these colors are set by the theme
@property(nonatomic, strong) UIColor *titleColor;
@property(nonatomic, strong) UIColor *titleSelectedColor;
@property(nonatomic, strong) UIColor *headerTextColor;
@property(nonatomic, strong) UIColor *headerBackgroundColor;
@property(nonatomic, strong) UIColor *selectionColor;
@property(nonatomic, strong) UIColor *selectionCenterColor;
@property(nonatomic, strong) UIColor *backgroundPopupColor;
@property(nonatomic, strong) UIColor *backgroundClockColor;
@property(nonatomic) MDClockMode clockMode;

@property(nonatomic, assign) MDTimePickerTheme theme;

@property(nonatomic, weak) id<MDTimePickerDialogDelegate> delegate;

- (instancetype)initWithHour:(NSInteger)hour minute:(NSInteger)minute;
- (instancetype)initWithClockMode:(MDClockMode)clockMode;
- (instancetype)initWithHour:(NSInteger)hour
                      minute:(NSInteger)minute
                   clockMode:(MDClockMode)clockMode;
- (void)show;
- (void)setTitleOk:(nonnull NSString *)okTitle
    andTitleCancel:(nonnull NSString *)cancelTitle;
@end
NS_ASSUME_NONNULL_END
#endif
