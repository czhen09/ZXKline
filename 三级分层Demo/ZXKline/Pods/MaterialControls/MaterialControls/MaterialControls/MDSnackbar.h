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

#define kMDSnackbarDurationLong 3.5f
#define kMDSnackbarDurationShort 2

@class MDSnackbar;
NS_ASSUME_NONNULL_BEGIN
@protocol MDSnackbarDelegate <NSObject>

@optional
- (void)snackbarWillAppear:(MDSnackbar *)snackbar;
- (void)snackbarDidAppear:(MDSnackbar *)snackbar;
- (void)snackbarWillDisappear:(MDSnackbar *)snackbar;
- (void)snackbarDidDisappear:(MDSnackbar *)snackbar;
- (void)actionTouched:(MDSnackbar *)snackbar;
@end

IB_DESIGNABLE
@interface MDSnackbar : UIControl

@property(nonatomic) NSString *text;
@property(nonatomic) NSString *actionTitle;
@property(nonatomic) UIColor *textColor;
@property(nonatomic) UIColor *actionTitleColor;
@property(nonatomic) double duration;
@property(nonatomic) double bottomPadding;
@property(nonatomic) BOOL swipeable;
@property(nonatomic) BOOL multiline;
@property(nonatomic) CGFloat maxWidth;
@property(nonatomic, readonly) BOOL isShowing;

- (instancetype)initWithText:(NSString *)text actionTitle:(NSString *)action;
- (instancetype)initWithText:(NSString *)text
                 actionTitle:(nullable NSString *)action
                    duration:(double)duration;

- (void)show;
- (void)dismiss;
- (void)addTarget:(id)target action:(SEL)aSelector;
- (void)addDelegate:(id<MDSnackbarDelegate>)delegate;
- (void)removeDelegate:(id<MDSnackbarDelegate>)delegate;

@end
NS_ASSUME_NONNULL_END
