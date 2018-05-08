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

#import "MDCollectionViewCell.h"
#import "MDRippleLayer.h"

@implementation MDCollectionViewCell {
  MDRippleLayer *mdLayer;
}

- (instancetype)init {
  if (self = [super init]) {
    [self initLayer];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self initLayer];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self initLayer];
  }
  return self;
}

- (void)initLayer {
  if (!_rippleColor)
    _rippleColor = [UIColor colorWithWhite:0.5 alpha:1];

  mdLayer = [[MDRippleLayer alloc] initWithSuperLayer:self.layer];
  [mdLayer setEffectColor:_rippleColor];
  mdLayer.enableElevation = false;
  mdLayer.effectSpeed = 300;
}

- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
}

- (void)setRippleColor:(UIColor *)rippleColor {
  _rippleColor = rippleColor;
  [mdLayer setEffectColor:rippleColor];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];
  CGPoint point = [touches.allObjects[0] locationInView:self];
  [mdLayer startEffectsAtLocation:point];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesCancelled:touches withEvent:event];
  [mdLayer stopEffectsImmediately];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event];
  [mdLayer stopEffects];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];
  [mdLayer stopEffects];
}

@end
