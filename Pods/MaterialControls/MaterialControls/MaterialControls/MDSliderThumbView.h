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

#import "MDBubbleLabel.h"
#import "MDSlider.h"
#import <UIKit/UIKit.h>

#define kMDThumbRadius 8
#define kMDThumbDisabledRadius 6
#define kMDThumbForcusedRadius 12

typedef NS_ENUM(NSInteger, MDSliderThumbState) {
  MDSliderThumbStateNormal,
  MDSliderThumbStateFocused,
  MDSliderThumbStateDisabled
};

NS_ASSUME_NONNULL_BEGIN
@interface MDSliderThumbView : UIView

@property(nonatomic) MDBubbleLabel *bubble;
@property(nonatomic) UIView *node;
@property(nonatomic) MDSliderThumbState state;
@property(nonatomic, weak) MDSlider *slider;
@property(nonatomic) BOOL enableBubble;

- (instancetype)initWithMDSlider:(MDSlider *)MDSlider;
- (void)focused:(nullable void (^)(BOOL finished))completion;
- (void)lostFocused:(nullable void (^)(BOOL finished))completion;
- (void)enabled:(nullable void (^)(BOOL finished))completion;
- (void)disabled:(nullable void (^)(BOOL finished))completion;
- (void)changeThumbShape:(BOOL)animated withValue:(CGFloat)rawValue;
@end
NS_ASSUME_NONNULL_END