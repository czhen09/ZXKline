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
#define kMDAnimationDuration .2f

NS_ASSUME_NONNULL_BEGIN
IB_DESIGNABLE
@interface MDSlider : UIControl

@property(nonatomic) IBInspectable CGFloat value;
@property(nonatomic) IBInspectable CGFloat maximumValue;
@property(nonatomic) IBInspectable CGFloat minimumValue;
@property(nonatomic) IBInspectable UIColor *thumbOnColor;
@property(nonatomic) IBInspectable UIColor *trackOnColor;
@property(nonatomic) IBInspectable UIColor *thumbOffColor;
@property(nonatomic) IBInspectable UIColor *trackOffColor;
@property(nonatomic) IBInspectable UIColor *disabledColor;
@property(nullable, nonatomic) IBInspectable UIColor *tickMarksColor;
@property(nullable, nonatomic) IBInspectable UIImage *leftImage;
@property(nullable, nonatomic) IBInspectable UIImage *rightImage;
@property(nonatomic, getter=isEnabled) IBInspectable BOOL enabled;
@property(nonatomic) IBInspectable CGFloat step;
@property(nonatomic) IBInspectable BOOL enabledValueLabel;
@property(nonatomic) IBInspectable NSUInteger precision;

@end
NS_ASSUME_NONNULL_END
