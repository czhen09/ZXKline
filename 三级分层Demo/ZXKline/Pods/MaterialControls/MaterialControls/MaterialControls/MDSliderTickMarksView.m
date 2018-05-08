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

#import "MDSliderTickMarksView.h"

#define kMDTickSize 2

@implementation MDSliderTickMarksView {
  NSMutableArray *tickLayers;
  NSMutableArray *tickValues;
}

- (instancetype)init {
  if (self = [super init]) {
    self.backgroundColor = [UIColor clearColor];
    tickLayers = [NSMutableArray array];
    tickValues = [NSMutableArray array];
    self.tickColor = [UIColor blackColor];
    [self addObserver:self forKeyPath:@"bounds" options:0 context:nil];
  }
  return self;
}

- (void)arrangeTickMarks {
  for (CALayer *layer in tickLayers) {
    [layer removeFromSuperlayer];
  }
  [tickLayers removeAllObjects];
  [tickValues removeAllObjects];

  CGFloat step = _step;
  if (_maximumValue < _minimumValue) {
    step = -fabs(step);
  }

  if (step != 0) {
    CGFloat space = (CGFloat)self.frame.size.width * fabs(_step) /
                  fabs(_maximumValue - _minimumValue);
    if (space > 0) {
      CGFloat x = 0;
      CGFloat value = _minimumValue;
      while (x < self.frame.size.width) {
        CALayer *tick = [self createTick:x];
        [self.layer addSublayer:tick];
        [tickLayers addObject:tick];
        [tickValues addObject:[NSNumber numberWithFloat:value]];
        x += space;
        value += step;
      }
      x = self.frame.size.width;
      value = _maximumValue;
      CALayer *tick = [self createTick:x];
      [self.layer addSublayer:tick];
      [tickLayers addObject:tick];
      [tickValues addObject:[NSNumber numberWithFloat:value]];
    }
  }
}

- (CALayer *)createTick:(CGFloat)x {
  CALayer *tick = [[CALayer alloc] init];
  tick.frame = CGRectMake(x - kMDTickSize / 2,
                          (self.bounds.size.height - kMDTickSize) / 2,
                          kMDTickSize, kMDTickSize);
  tick.backgroundColor = _tickColor.CGColor;
  return tick;
}

#pragma mark setters
- (void)setStep:(CGFloat)step {
  _step = step;
  [self arrangeTickMarks];
}

- (void)setMinimumValue:(CGFloat)minimumValue {
  _minimumValue = minimumValue;
  [self arrangeTickMarks];
}

- (void)setMaximumValue:(CGFloat)maximumValue {
  _maximumValue = maximumValue;
  [self arrangeTickMarks];
}

- (void)setTickColor:(UIColor *)tickColor {
  _tickColor = tickColor;
  for (CALayer *layer in tickLayers) {
    layer.backgroundColor = tickColor.CGColor;
  }
}

#pragma mark value observer
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if (object == self && [keyPath isEqualToString:@"bounds"]) {
    [self arrangeTickMarks];
  }
}

- (void)dealloc {
  [self removeObserver:self forKeyPath:@"bounds"];
}

#pragma mark public methods
- (CGFloat)theNearestTickValueFromValue:(CGFloat)value {
  for (int i = 0; i < tickLayers.count; i++) {
    CGFloat tickValue = [tickValues[i] floatValue];
    if (_minimumValue < _maximumValue) {
      if (tickValue >= value) {
        if (i == 0) {
          return tickValue;
        }
        CGFloat previousTickValue = [tickValues[i - 1] floatValue];
        if (fabs(value - previousTickValue) > fabs(tickValue - value)) {
          return tickValue;
        } else {
          return previousTickValue;
        }
      }
    } else {
      if (tickValue <= value) {
        if (i == 0) {
          return tickValue;
        }
        CGFloat previousTickValue = [tickValues[i - 1] floatValue];
        if (fabs(value - previousTickValue) > fabs(tickValue - value)) {
          return tickValue;
        } else {
          return previousTickValue;
        }
      }
    }
  }

  return _minimumValue;
}

@end
