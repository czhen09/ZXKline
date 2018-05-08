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

#import "MDSlider.h"
#import "MDSliderThumbView.h"
#import "UIViewHelper.h"

#define kMDThumbBorderWidth 2

#define kMDHideThumbAnimationKey @"hideThumb"
#define kMDShowThumbAnimationKey @"showThumb"
#define kMDHideBubbleAnimationKey @"hideBubble"
#define kMDShowBubbleAnimationKey @"showBubble"

@interface MDSliderThumbView () <CAAnimationDelegate>

@end

@implementation MDSliderThumbView {
  NSLayoutConstraint *nodeWidthConstraint;
  NSDictionary *viewsDictionary;
  NSDictionary *metricsDictionary;
}

- (instancetype)initWithMDSlider:(MDSlider *)slider {
  if (self = [super init]) {
    _slider = slider;
    _bubble = [[MDBubbleLabel alloc] init];
    _node = [[UIView alloc] init];
    _node.layer.cornerRadius = kMDThumbRadius;
    [self addSubview:_node];
    [self setupConstraints];
    _state = MDSliderThumbStateNormal;
  }
  return self;
}

- (void)setupConstraints {
  _bubble.translatesAutoresizingMaskIntoConstraints = NO;
  _node.translatesAutoresizingMaskIntoConstraints = NO;
  viewsDictionary = NSDictionaryOfVariableBindings(_bubble, _node);

  metricsDictionary = @{
    @"bubblePaddingBottom" : @(kMDThumbRadius + kMDThumbForcusedRadius)
  };

  [UIViewHelper addConstraintWithItem:_node
                            attribute:NSLayoutAttributeCenterY
                            relatedBy:NSLayoutRelationEqual
                               toItem:self
                            attribute:NSLayoutAttributeBottom
                           multiplier:1
                             constant:-kMDThumbForcusedRadius
                               toView:self];
  [UIViewHelper addConstraintWithItem:_node
                            attribute:NSLayoutAttributeCenterY
                            relatedBy:NSLayoutRelationGreaterThanOrEqual
                               toItem:self
                            attribute:NSLayoutAttributeTop
                           multiplier:1
                             constant:kMDThumbForcusedRadius
                               toView:self];
  [UIViewHelper addConstraintWithItem:_node
                            attribute:NSLayoutAttributeCenterX
                            relatedBy:NSLayoutRelationEqual
                               toItem:self
                            attribute:NSLayoutAttributeCenterX
                           multiplier:1
                             constant:0
                               toView:self];

  nodeWidthConstraint =
      [UIViewHelper addConstraintWithItem:_node
                                attribute:NSLayoutAttributeWidth
                                relatedBy:NSLayoutRelationEqual
                                   toItem:nil
                                attribute:NSLayoutAttributeNotAnAttribute
                               multiplier:1
                                 constant:kMDThumbRadius * 2
                                   toView:self];

  [UIViewHelper addConstraintWithItem:_node
                            attribute:NSLayoutAttributeHeight
                            relatedBy:NSLayoutRelationEqual
                               toItem:_node
                            attribute:NSLayoutAttributeWidth
                           multiplier:1
                             constant:0
                               toView:self];
}

- (void)focused:(void (^)(BOOL finished))completion {
  _state = MDSliderThumbStateFocused;
  [UIView animateWithDuration:kMDAnimationDuration
                   animations:^{
                     nodeWidthConstraint.constant = kMDThumbForcusedRadius * 2;
                     [self layoutIfNeeded];
                   }
                   completion:completion];

  CABasicAnimation *animation =
      [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
  animation.timingFunction =
      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
  animation.fromValue = [NSNumber numberWithFloat:_node.layer.cornerRadius];
  animation.toValue = [NSNumber numberWithFloat:kMDThumbForcusedRadius];
  animation.duration = kMDAnimationDuration;
  _node.layer.cornerRadius = kMDThumbForcusedRadius;
  [_node.layer addAnimation:animation forKey:@"cornerRadius"];

  if (_enableBubble) {
    [self showBubble];
    [self hideNode];
  }
}

- (void)lostFocused:(void (^)(BOOL finished))completion {
  _state = MDSliderThumbStateNormal;
  [UIView animateWithDuration:kMDAnimationDuration
                   animations:^{
                     nodeWidthConstraint.constant = kMDThumbRadius * 2;
                     [self layoutIfNeeded];
                   }
                   completion:completion];

  CABasicAnimation *animation =
      [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
  animation.timingFunction =
      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
  animation.fromValue = [NSNumber numberWithFloat:_node.layer.cornerRadius];
  animation.toValue = [NSNumber numberWithInt:kMDThumbRadius];
  animation.duration = kMDAnimationDuration;
  _node.layer.cornerRadius = kMDThumbRadius;
  [_node.layer addAnimation:animation forKey:@"cornerRadius"];

  if (_enableBubble) {
    [self hideBubble];
    [self showNode];
  }
}

- (void)enabled:(void (^)(BOOL finished))completion {
  _state = MDSliderThumbStateNormal;
  [UIView animateWithDuration:kMDAnimationDuration
                   animations:^{
                     nodeWidthConstraint.constant = kMDThumbRadius * 2;
                     [self layoutIfNeeded];
                   }
                   completion:completion];

  CABasicAnimation *animation =
      [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
  animation.timingFunction =
      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
  animation.fromValue = [NSNumber numberWithFloat:_node.layer.cornerRadius];
  animation.toValue = [NSNumber numberWithInt:kMDThumbRadius];
  animation.duration = kMDAnimationDuration;
  _node.layer.cornerRadius = kMDThumbRadius;
  [_node.layer addAnimation:animation forKey:@"cornerRadius"];
}

- (void)disabled:(void (^)(BOOL finished))completion {
  _state = MDSliderThumbStateDisabled;
  [UIView animateWithDuration:kMDAnimationDuration
                   animations:^{
                     nodeWidthConstraint.constant = kMDThumbDisabledRadius * 2;
                     [self layoutIfNeeded];
                   }
                   completion:completion];

  CABasicAnimation *animation =
      [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
  animation.timingFunction =
      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
  animation.fromValue = [NSNumber numberWithFloat:_node.layer.cornerRadius];
  animation.toValue = [NSNumber numberWithFloat:kMDThumbDisabledRadius];
  animation.duration = kMDAnimationDuration;
  _node.layer.cornerRadius = kMDThumbDisabledRadius;
  [_node.layer addAnimation:animation forKey:@"cornerRadius"];
}

- (void)changeThumbShape:(BOOL)animated withValue:(CGFloat)rawValue {
  CAAnimationGroup *changeShape;
  if (animated) {
    changeShape = [CAAnimationGroup animation];
  }
  UIColor *thumbOnColor =
      _slider.enabled ? _slider.thumbOnColor : _slider.disabledColor;
  UIColor *thumbOffColor =
      _slider.enabled ? _slider.thumbOffColor : _slider.disabledColor;

  if (rawValue == _slider.minimumValue) {
    if (animated) {
      CABasicAnimation *background =
          [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
      background.fromValue = (id)_node.layer.backgroundColor;
      background.toValue = (id)[UIColor whiteColor].CGColor;

      CABasicAnimation *width =
          [CABasicAnimation animationWithKeyPath:@"borderWidth"];
      width.fromValue = @(_node.layer.borderWidth);
      width.toValue = @kMDThumbBorderWidth;

      CABasicAnimation *borderColor =
          [CABasicAnimation animationWithKeyPath:@"borderColor"];
      borderColor.fromValue = (id)_node.layer.borderColor;
      borderColor.toValue = (id)_slider.thumbOffColor.CGColor;

      changeShape.animations = @[ background, width, borderColor ];
    }

    _node.layer.backgroundColor = [UIColor whiteColor].CGColor;
    _node.layer.borderWidth = kMDThumbBorderWidth;
    _node.layer.borderColor = thumbOffColor.CGColor;
    [self changeBubbleColor:thumbOffColor animated:animated];
  } else {
    if (animated) {
      CABasicAnimation *background =
          [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
      background.fromValue = (id)_node.layer.backgroundColor;
      background.toValue = (id)thumbOnColor.CGColor;

      CABasicAnimation *width =
          [CABasicAnimation animationWithKeyPath:@"borderWidth"];
      width.fromValue = @(_node.layer.borderWidth);
      width.toValue = @0;

      CABasicAnimation *borderColor =
          [CABasicAnimation animationWithKeyPath:@"borderColor"];
      borderColor.fromValue = (id)_node.layer.borderColor;
      borderColor.toValue = (id)[UIColor clearColor].CGColor;
      changeShape.animations = @[ background, width, borderColor ];
    }

    _node.layer.backgroundColor = thumbOnColor.CGColor;
    _node.layer.borderWidth = 0;
    _node.layer.borderColor = [UIColor clearColor].CGColor;
    [self changeBubbleColor:thumbOnColor animated:animated];
  }

  if (animated) {
    changeShape.delegate = self;
    changeShape.duration = kMDAnimationDuration;
    [_node.layer addAnimation:changeShape forKey:@"changeShape"];
  }
}

- (void)changeBubbleColor:(UIColor *)color animated:(BOOL)animated {
  if (animated) {
    [UIView animateWithDuration:kMDAnimationDuration
                     animations:^{
                       _bubble.backgroundColor = color;
                     }];
  } else {
    _bubble.backgroundColor = color;
  }
}

- (void)setEnableBubble:(BOOL)enabled {
  _enableBubble = enabled;
  if (enabled) {
    if (!_bubble.superview) {
      [self addSubview:_bubble];
      // keep node on top off bubble
      [self bringSubviewToFront:_node];
      [UIViewHelper addConstraintsWithVisualFormat:
                        @"V:|-(0)-[_bubble]-(bubblePaddingBottom)-|"
                                           options:0
                                           metrics:metricsDictionary
                                             views:viewsDictionary
                                            toView:self];
      [UIViewHelper
          addConstraintsWithVisualFormat:@"H:|-(>=0)-[_bubble]-(>=0)-|"
                                 options:0
                                 metrics:metricsDictionary
                                   views:viewsDictionary
                                  toView:self];

      [UIViewHelper addConstraintWithItem:_bubble
                                attribute:NSLayoutAttributeCenterX
                                relatedBy:NSLayoutRelationEqual
                                   toItem:self
                                attribute:NSLayoutAttributeCenterX
                               multiplier:1
                                 constant:0
                                   toView:self];
      _bubble.hidden = YES;
    }
  } else {
    [_bubble removeFromSuperview];
  }
}

#pragma mark bubble behaviour
- (void)showBubble {
  [_bubble.layer removeAnimationForKey:kMDHideBubbleAnimationKey];
  if (_bubble.hidden) {
    _bubble.hidden = NO;

    CGRect r = _bubble.layer.frame;
    r.origin.y = r.size.height / 2 + 8;
    CABasicAnimation *scaleAnim =
        [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnim.fromValue = [NSNumber numberWithFloat:0];
    scaleAnim.toValue = [NSNumber numberWithFloat:1];

    CABasicAnimation *moveAnim =
        [CABasicAnimation animationWithKeyPath:@"position"];
    moveAnim.fromValue = [NSValue valueWithCGPoint:CGRectCenter(r)];
    moveAnim.toValue =
        [NSValue valueWithCGPoint:CGRectCenter(_bubble.layer.frame)];

    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.timingFunction =
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animGroup.duration = kMDAnimationDuration;
    animGroup.animations = @[ scaleAnim, moveAnim ];

    [_bubble.layer addAnimation:animGroup forKey:kMDShowBubbleAnimationKey];
  }
}

- (void)hideBubble {
  [_bubble.layer removeAnimationForKey:kMDShowBubbleAnimationKey];
  CGRect r = _bubble.layer.frame;
  r.origin.y = r.size.height / 2 + 8;
  CABasicAnimation *scaleAnim =
      [CABasicAnimation animationWithKeyPath:@"transform.scale"];
  scaleAnim.fromValue = [NSNumber numberWithFloat:1];
  scaleAnim.toValue = [NSNumber numberWithFloat:0];

  CABasicAnimation *moveAnim =
      [CABasicAnimation animationWithKeyPath:@"position"];
  moveAnim.fromValue =
      [NSValue valueWithCGPoint:CGRectCenter(_bubble.layer.frame)];
  moveAnim.toValue = [NSValue valueWithCGPoint:CGRectCenter(r)];

  CAAnimationGroup *animGroup = [CAAnimationGroup animation];
  animGroup.timingFunction =
      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
  animGroup.animations = @[ scaleAnim, moveAnim ];
  animGroup.duration = kMDAnimationDuration;
  animGroup.delegate = self;
  [animGroup setValue:kMDHideBubbleAnimationKey forKey:@"id"];
  animGroup.removedOnCompletion = NO;
  animGroup.fillMode = kCAFillModeForwards;

  [_bubble.layer addAnimation:animGroup forKey:kMDHideBubbleAnimationKey];
}

- (void)showNode {
  [_node.layer removeAnimationForKey:kMDHideThumbAnimationKey];
  _node.hidden = NO;

  CABasicAnimation *scaleAnim =
      [CABasicAnimation animationWithKeyPath:@"transform.scale"];
  scaleAnim.fromValue = [NSNumber numberWithFloat:0];
  scaleAnim.toValue = [NSNumber numberWithFloat:1];

  scaleAnim.timingFunction =
      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
  scaleAnim.duration = kMDAnimationDuration;

  [_node.layer addAnimation:scaleAnim forKey:kMDShowThumbAnimationKey];
}

- (void)hideNode {
  [_node.layer removeAnimationForKey:kMDShowThumbAnimationKey];
  CABasicAnimation *scaleAnim =
      [CABasicAnimation animationWithKeyPath:@"transform.scale"];
  scaleAnim.fromValue = [NSNumber numberWithFloat:1];
  scaleAnim.toValue = [NSNumber numberWithFloat:0];

  scaleAnim.timingFunction =
      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
  scaleAnim.duration = kMDAnimationDuration;
  scaleAnim.delegate = self;
  [scaleAnim setValue:kMDHideThumbAnimationKey forKey:@"id"];
  scaleAnim.removedOnCompletion = NO;
  scaleAnim.fillMode = kCAFillModeForwards;

  [_node.layer addAnimation:scaleAnim forKey:kMDHideThumbAnimationKey];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  NSString *animationKey = [anim valueForKey:@"id"];
  if (flag) {
    if ([animationKey isEqual:kMDHideBubbleAnimationKey]) {
      _bubble.hidden = YES;
    } else if ([animationKey isEqual:kMDHideThumbAnimationKey]) {
      _node.hidden = YES;
    }
  }
}

@end
