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

#ifndef MDUILIB_MDBUTTONTYPE
#define MDUILIB_MDBUTTONTYPE

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MDButtonType) {
  MDButtonTypeRaised,
  MDButtonTypeFlat,
  MDButtonTypeFloatingAction,
  MDButtonTypeFloatingActionRotation
};
NS_ASSUME_NONNULL_BEGIN
@protocol MDButtonDelegate <NSObject>

@optional
- (void)rotationStarted:(id)sender;
- (void)rotationCompleted:(id)sender;
@end

IB_DESIGNABLE
@interface MDButton : UIButton
@property(null_unspecified, nonatomic) IBInspectable UIColor *rippleColor;
@property(nonatomic) IBInspectable NSInteger type;
@property(nonatomic, getter=isEnabled) IBInspectable BOOL enabled;
@property(nonatomic) IBInspectable UIImage *imageNormal;
@property(nonatomic) IBInspectable UIImage *imageRotated;
@property(nonatomic) IBInspectable CGFloat imageSize;

@property(nonatomic) MDButtonType mdButtonType;
@property(nonatomic, getter=isRotated) BOOL rotated;
;

@property(nonatomic, weak) id<MDButtonDelegate> mdButtonDelegate;

- (instancetype)initWithFrame:(CGRect)frame
                         type:(MDButtonType)buttonType
                  rippleColor:(nullable UIColor *)rippleColor;

@end
NS_ASSUME_NONNULL_END
#endif