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
#import "MDConstants.h"
#import "MDMathHelper.h"
#import "UIColorHelper.h"
#import "UIFontHelper.h"
#import "UIViewHelper.h"
#import <math.h>

#define kMDTextSize 12

@implementation MDBubbleLabel {
  UILabel *label;
  NSLayoutConstraint *labelWithConstraint;
}

- (instancetype)init {
  if (self = [super init]) {
    [self initialize];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self initialize];
  }
  return self;
}

- (void)initialize {
  label = [[UILabel alloc] init];
  label.font = [UIFontHelper robotoFontOfSize:kMDTextSize];
  label.textColor = [UIColor whiteColor];
  label.textAlignment = NSTextAlignmentCenter;
  [self addSubview:label];

  [self setupConstraints];
  self.backgroundColor = [UIColorHelper colorWithRGBA:kMDColorPrimary500];
  self.layer.masksToBounds = YES;
  [self updateMark];
  [self addObserver:self forKeyPath:@"bounds" options:0 context:nil];
}

- (void)setupConstraints {
  self.translatesAutoresizingMaskIntoConstraints = NO;
  label.translatesAutoresizingMaskIntoConstraints = NO;
  NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(label);

  [UIViewHelper addConstraintWithItem:self
                            attribute:NSLayoutAttributeHeight
                            relatedBy:NSLayoutRelationEqual
                               toItem:self
                            attribute:NSLayoutAttributeWidth
                           multiplier:1.2f
                             constant:0
                               toView:self];
  labelWithConstraint =
      [UIViewHelper addConstraintWithItem:label
                                attribute:NSLayoutAttributeWidth
                                relatedBy:NSLayoutRelationEqual
                                   toItem:nil
                                attribute:NSLayoutAttributeNotAnAttribute
                               multiplier:0
                                 constant:0
                                   toView:label];
  [UIViewHelper addConstraintsWithVisualFormat:@"H:|-8-[label]-8-|"
                                       options:0
                                       metrics:nil
                                         views:viewsDictionary
                                        toView:self];
  [UIViewHelper addConstraintWithItem:label
                            attribute:NSLayoutAttributeCenterY
                            relatedBy:NSLayoutRelationEqual
                               toItem:self
                            attribute:NSLayoutAttributeBottom
                           multiplier:.45f
                             constant:0
                               toView:self];
}

- (void)updateMark {
  CGRect bounds = self.bounds;
  CGPoint arcCenter = CGPointMake(bounds.size.width / 2, bounds.size.width / 2);
  CGPoint bottom = CGPointMake(bounds.size.width / 2, bounds.size.height);
  UIBezierPath *path = [UIBezierPath bezierPath];

  float d = [MDMathHelper distanceBetweenPoint:arcCenter andPoint:bottom];
  float angle = acosf((bounds.size.width / 2) / d);

  [path moveToPoint:bottom];
  [path addArcWithCenter:arcCenter
                  radius:bounds.size.width / 2
              startAngle:M_PI_2 - angle
                endAngle:M_PI_2 + angle
               clockwise:NO];
  [path closePath];

  CAShapeLayer *markLayer = [[CAShapeLayer alloc] init];
  markLayer.path = path.CGPath;
  self.layer.mask = markLayer;
}

- (NSString *)valueFormatString {
  return [NSString stringWithFormat:@"%%.%luf", (unsigned long)_precision];
}

- (void)calculateLabelWidth {
  NSString *maxValue =
      [NSString stringWithFormat:[self valueFormatString], _maxValue];
  NSDictionary *attributes = @{NSFontAttributeName : label.font};

  labelWithConstraint.constant =
      [maxValue sizeWithAttributes:attributes].width + 1;
}

#pragma mark public methods
- (void)setValue:(CGFloat)value {
  [label setText:[NSString stringWithFormat:[self valueFormatString], value]];
}

- (void)setTextColor:(UIColor *)textColor {
  [label setTextColor:textColor];
}

- (void)setFont:(UIFont *)font {
  [label setFont:font];
  [self calculateLabelWidth];
}

- (void)setPrecision:(NSUInteger)precision {
  _precision = precision;
  [self calculateLabelWidth];
}

- (void)setMaxValue:(CGFloat)maxValue {
  _maxValue = maxValue;
  [self calculateLabelWidth];
}

#pragma mark value observer
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if (object == self && [keyPath isEqualToString:@"bounds"]) {
    [self updateMark];
  }
}

- (void)dealloc {
  [self removeObserver:self forKeyPath:@"bounds"];
}
@end
