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

typedef NS_OPTIONS(NSInteger, MDGravity) {
  MDGravityNone = 0,
  MDGravityTop = 1 << 0,
  MDGravityBottom = 1 << 1,
  MDGravityLeft = 1 << 2,
  MDGravityRight = 1 << 3,
  MDGravityCenterHorizontal = 1 << 4,
  MDGravityCenterVertical = 1 << 5,
};

@interface UIView (MDExtension)

@property(nonatomic) CGFloat mdWidth;
@property(nonatomic) CGFloat mdHeight;

@property(nonatomic) CGFloat mdTop;
@property(nonatomic) CGFloat mdLeft;
@property(nonatomic) CGFloat mdBottom;
@property(nonatomic) CGFloat mdRight;

@property(nonatomic) CGFloat mdCenterX;
@property(nonatomic) CGFloat mdCenterY;

@end
