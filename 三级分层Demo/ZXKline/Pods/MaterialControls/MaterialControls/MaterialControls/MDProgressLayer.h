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

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface MDProgressLayer : CALayer

@property(nullable, nonatomic) UIColor *progressColor;
@property(nullable, nonatomic) UIColor *trackColor;
@property(nonatomic) CGFloat trackWidth;
@property(nonatomic) BOOL drawTrack;
@property(nonatomic) BOOL determinate;
@property(nonatomic) CGFloat progress;
@property(nonatomic) CALayer *superLayer;
@property(nullable, nonatomic) UIView *superView;

@property(nonatomic) BOOL isAnimating;

- (instancetype)initWithSuperLayer:(CALayer *)superLayer;
- (instancetype)initWithSuperView:(UIView *)superView;
- (void)superLayerDidResize;
- (void)startAnimating;
- (void)stopAnimating;
- (void)initContents;

@end
NS_ASSUME_NONNULL_END
