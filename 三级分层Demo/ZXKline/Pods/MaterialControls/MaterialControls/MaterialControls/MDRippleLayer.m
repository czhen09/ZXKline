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

#import "MDRippleLayer.h"
#import "MDTouchGestureRecognizer.h"
#import "UIViewHelper.h"

#define kMDScaleAnimationKey @"scale"
#define kMDPositionAnimationKey @"position"
#define kMDShadowAnimationKey @"shadow"

#define kMDRippleTransparent 0.5f
#define kMDBackgroundTransparent 0.3f
#define kMDElevationOffset 6
#define kMDClearEffectDuration 0.3f;

@interface MDRippleLayer () <MDTouchGestureRecognizerDelegate, CAAnimationDelegate,
                             UIGestureRecognizerDelegate>

@property CALayer *superLayer;
@property CAShapeLayer *rippleLayer;
@property CAShapeLayer *backgroundLayer;
@property CAShapeLayer *maskLayer;
@property BOOL effectIsRunning;
@property BOOL userIsHolding;

@end

@implementation MDRippleLayer {
  UIView *superView;
}

// static float clearEffectDuration = 0.3;

- (instancetype)initWithSuperLayer:(CALayer *)superLayer {
  if (self = [super init]) {
    _superLayer = superLayer;
    [self initContents];
  }
  return self;
}

- (instancetype)initWithSuperView:(UIView *)view {
  if (self = [super init]) {
    superView = view;
    _superLayer = superView.layer;
    MDTouchGestureRecognizer *recognizer =
        [[MDTouchGestureRecognizer alloc] init];
    recognizer.touchDelegate = self;
    recognizer.delegate = self;
    [superView addGestureRecognizer:recognizer];
    [self initContents];
  }
  return self;
}

- (void)initContents {
  _enableRipple = true;
  _enableElevation = true;
  _rippleScaleRatio = 1;
  _effectIsRunning = false;
  _userIsHolding = false;
  _restingElevation = 2.0;
  _effectSpeed = 140;

  _rippleLayer = [[CAShapeLayer alloc] init];
  _rippleLayer.opacity = 0;
  [self addSublayer:_rippleLayer];

  _backgroundLayer = [[CAShapeLayer alloc] init];
  _backgroundLayer.opacity = 0;
  _backgroundLayer.frame = _superLayer.bounds;
  [self addSublayer:_backgroundLayer];

  _maskLayer = [[CAShapeLayer alloc] init];

  [self setMaskLayerCornerRadius:_superLayer.cornerRadius];
  self.mask = _maskLayer;

  self.frame = _superLayer.bounds;

  if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
    [_superLayer insertSublayer:self
                        atIndex:(int)[_superLayer.sublayers count]];
  } else {
    [_superLayer addSublayer:self];
  }

  [_superLayer addObserver:self forKeyPath:@"bounds" options:0 context:nil];
  [_superLayer addObserver:self
                forKeyPath:@"cornerRadius"
                   options:0
                   context:nil];

  [self enableElevation:_enableElevation withResting:true];
  [self superLayerDidResize];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if ([keyPath isEqualToString:@"bounds"]) {
    [self superLayerDidResize];
  } else if ([keyPath isEqualToString:@"cornerRadius"]) {
    [self setMaskLayerCornerRadius:_superLayer.cornerRadius];
  }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  if (anim == [self animationForKey:@"opacityAnim"]) {
    self.opacity = 0;
  } else if (flag) {
    if (_userIsHolding) {
      _effectIsRunning = false;
      if ([self.layerDelegate respondsToSelector:@selector(mdLayer:didFinishEffect:)]) {
        [self.layerDelegate mdLayer:self didFinishEffect:anim.duration];
      }
    } else {
      [self clearEffects];
    }
  }
}

#pragma mark MDTouchGestureRecognizerDelegate methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  CGPoint point = [touches.allObjects[0] locationInView:superView];
  [self startEffectsAtLocation:point];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [self stopEffects];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self stopEffects];
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:
        (UIGestureRecognizer *)otherGestureRecognizer {
  return YES;
}

#pragma mark Setters

- (void)setEffectColor:(UIColor *)color {
  _effectColor = color;
  _rippleLayer.fillColor =
      [[color colorWithAlphaComponent:kMDRippleTransparent] CGColor];
  _backgroundLayer.fillColor =
      [[color colorWithAlphaComponent:kMDBackgroundTransparent] CGColor];
}

- (void)setEffectColor:(UIColor *)color
       withRippleAlpha:(CGFloat)rippleAlpha
       backgroundAlpha:(CGFloat)backgroundAlpha {
  _effectColor = color;
  _rippleLayer.fillColor =
      [[color colorWithAlphaComponent:rippleAlpha] CGColor];
  _backgroundLayer.fillColor =
      [[color colorWithAlphaComponent:backgroundAlpha] CGColor];
}

- (void)setRippleScaleRatio:(CGFloat)rippleScaleRatio {
  _rippleScaleRatio = rippleScaleRatio;
  [self calculateRippleSize];
}

- (void)setEnableMask:(BOOL)enableMask {
  _enableMask = enableMask;
  self.mask = _enableMask ? _maskLayer : nil;
}

- (void)setEnableElevation:(BOOL)enableElevation {
  _enableElevation = enableElevation;
  [self enableElevation:enableElevation withResting:true];
}

- (void)setRestingElevation:(CGFloat)restingElevation {
  _restingElevation = restingElevation;
  [self enableElevation:_enableElevation withResting:true];
}

#pragma mark Public methods

- (void)superLayerDidResize {
  [CATransaction begin];
  [CATransaction setDisableActions:true];
  self.frame = _superLayer.bounds;
  [self setMaskLayerCornerRadius:_superLayer.cornerRadius];
  [self calculateRippleSize];
  [CATransaction commit];
}

- (void)startEffectsAtLocation:(CGPoint)touchLocation {
  _userIsHolding = true;
  _rippleLayer.timeOffset = 0;
  _rippleLayer.speed = 1;
  if (_enableRipple) {
    [self startRippleEffect:[self nearestInnerPoint:touchLocation]];
  }

  if (_enableElevation) {
    [self startShadowEffect];
  }
}

- (void)stopEffects {
  _userIsHolding = false;
  if (!_effectIsRunning) {
    [self clearEffects];
  } else {
    _rippleLayer.timeOffset =
        [_rippleLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    _rippleLayer.beginTime = CACurrentMediaTime();
    _rippleLayer.speed = 4;
  }
}

- (void)stopEffectsImmediately {
  _userIsHolding = false;
  _effectIsRunning = false;
  if (_enableRipple) {
    [_rippleLayer removeAllAnimations];
    [_backgroundLayer removeAllAnimations];
    _rippleLayer.opacity = 0;
    _backgroundLayer.opacity = 0;
  }
  if (_enableElevation) {
    [_superLayer removeAnimationForKey:kMDShadowAnimationKey];
    _superLayer.shadowRadius = _restingElevation / 4;
#if !TARGET_INTERFACE_BUILDER
    _superLayer.shadowOffset = CGSizeMake(0, _restingElevation / 4 + 0.5);
#else
    _superLayer.shadowOffset = CGSizeMake(0, -(_restingElevation / 4 + 0.5));
#endif
  }
}

#pragma mark Private Methods
- (CGPoint)nearestInnerPoint:(CGPoint)point {
  CGFloat centerX = CGRectGetMidX(self.bounds);
  CGFloat centerY = CGRectGetMidY(self.bounds);
  double dx = (point.x - centerX);
  double dy = (point.y - centerY);
  double dist = sqrt(dx * dx + dy * dy);
  if (dist <= _backgroundLayer.bounds.size.width / 2) {
    return point;
  } else {
    CGFloat d = _backgroundLayer.bounds.size.width / (2 * dist);
    CGFloat x = centerX + d * (point.x - centerX);
    CGFloat y = centerY + d * (point.y - centerY);
    return CGPointMake(x, y);
  }
}

- (void)enableElevation:(BOOL)enable withResting:(BOOL)resting {
  if (enable) {
    CGFloat elevation =
        resting ? _restingElevation : (_restingElevation + kMDElevationOffset);
    _superLayer.shadowOpacity = 0.5;
    _superLayer.shadowRadius = elevation / 4;
    _superLayer.shadowColor = [[UIColor blackColor] CGColor];
#if !TARGET_INTERFACE_BUILDER
    _superLayer.shadowOffset = CGSizeMake(0, _restingElevation / 4 + 0.5);
#else
    _superLayer.shadowOffset = CGSizeMake(0, -(_restingElevation / 4 + 0.5));
#endif
  } else {
    _superLayer.shadowRadius = 0;
    _superLayer.shadowColor = [[UIColor clearColor] CGColor];
    _superLayer.shadowOffset = CGSizeMake(0, 0);
  }
}

- (void)clearEffects {
  _rippleLayer.timeOffset = 0;
  _rippleLayer.speed = 1;

  if (_enableRipple) {
    [_rippleLayer removeAllAnimations];
    [_backgroundLayer removeAllAnimations];
    [self removeAllAnimations];

    CABasicAnimation *opacityAnim =
        [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue = @(1.0f);
    opacityAnim.toValue = @(0.0f);
    opacityAnim.duration = kMDClearEffectDuration;
    opacityAnim.timingFunction =
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    opacityAnim.removedOnCompletion = false;
    opacityAnim.fillMode = kCAFillModeForwards;
    opacityAnim.delegate = self;

    [self addAnimation:opacityAnim forKey:@"opacityAnim"];
  }

  if (_enableElevation) {
    CABasicAnimation *radiusAnimation =
        [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    radiusAnimation.fromValue = @((_restingElevation + kMDElevationOffset) / 4);
    radiusAnimation.toValue = @(_restingElevation / 4);

    CABasicAnimation *offsetAnimation =
        [CABasicAnimation animationWithKeyPath:@"shadowOffset"];
    offsetAnimation.fromValue = [NSValue
        valueWithCGSize:CGSizeMake(0, (_restingElevation + kMDElevationOffset) /
                                          4)];
    offsetAnimation.toValue =
        [NSValue valueWithCGSize:CGSizeMake(0, _restingElevation / 4 + 0.5)];

    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.duration = kMDClearEffectDuration;
    groupAnimation.timingFunction =
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    groupAnimation.removedOnCompletion = false;
    groupAnimation.fillMode = kCAFillModeForwards;

    groupAnimation.animations =
        [NSArray arrayWithObjects:radiusAnimation, offsetAnimation, nil];
    [_superLayer addAnimation:groupAnimation forKey:kMDShadowAnimationKey];
  }
}

- (void)startRippleEffect:(CGPoint)touchLocation {
  [self removeAllAnimations];
  self.opacity = 1;
  CGFloat time = (_rippleLayer.bounds.size.width) / _effectSpeed;
  [_rippleLayer removeAllAnimations];
  [_backgroundLayer removeAllAnimations];
  [_superLayer removeAnimationForKey:kMDShadowAnimationKey];

  CABasicAnimation *scaleAnim =
      [CABasicAnimation animationWithKeyPath:@"transform.scale"];
  scaleAnim.fromValue = [NSNumber numberWithFloat:0];
  scaleAnim.toValue = [NSNumber numberWithFloat:1];
  scaleAnim.duration = time;
  scaleAnim.timingFunction =
      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  CABasicAnimation *moveAnim =
      [CABasicAnimation animationWithKeyPath:@"position"];
  moveAnim.fromValue = [NSValue valueWithCGPoint:touchLocation];
  moveAnim.toValue =
      [NSValue valueWithCGPoint:CGRectCenter(_superLayer.bounds)];
  moveAnim.duration = time;
  moveAnim.timingFunction =
      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

  scaleAnim.delegate = self;
  _effectIsRunning = true;
  _rippleLayer.opacity = 1;
  _backgroundLayer.opacity = 1;

  [_rippleLayer addAnimation:moveAnim forKey:kMDPositionAnimationKey];
  [_rippleLayer addAnimation:scaleAnim forKey:kMDScaleAnimationKey];
}

- (void)startShadowEffect {
  CABasicAnimation *radiusAnimation =
      [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
  radiusAnimation.fromValue = [NSNumber numberWithFloat:_restingElevation / 4];
  radiusAnimation.toValue =
      [NSNumber numberWithFloat:(_restingElevation + kMDElevationOffset) / 4];

  CABasicAnimation *offsetAnimation =
      [CABasicAnimation animationWithKeyPath:@"shadowOffset"];
  offsetAnimation.fromValue =
      [NSValue valueWithCGSize:CGSizeMake(0, _restingElevation / 4 + 0.5)];
  offsetAnimation.toValue = [NSValue
      valueWithCGSize:CGSizeMake(0,
                                 (_restingElevation + kMDElevationOffset) / 4)];

  CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
  groupAnimation.duration = kMDClearEffectDuration;
  groupAnimation.timingFunction =
      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  groupAnimation.removedOnCompletion = false;
  groupAnimation.fillMode = kCAFillModeForwards;

  groupAnimation.animations =
      [NSArray arrayWithObjects:radiusAnimation, offsetAnimation, nil];
  [_superLayer addAnimation:groupAnimation forKey:kMDShadowAnimationKey];
}

- (void)setMaskLayerCornerRadius:(CGFloat)cornerRadius {
  UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                  cornerRadius:cornerRadius];
  _maskLayer.path = path.CGPath;
}

- (void)calculateRippleSize {
  CGFloat superLayerWidth = CGRectGetWidth(_superLayer.bounds);
  CGFloat superLayerHeight = CGRectGetHeight(_superLayer.bounds);
  CGPoint center = CGRectCenter(_superLayer.bounds);
  CGFloat circleDiameter =
      sqrtf(powf(superLayerWidth, 2) + powf(superLayerHeight, 2)) *
      _rippleScaleRatio;
  CGFloat subX = center.x - circleDiameter / 2;
  CGFloat subY = center.y - circleDiameter / 2;

  _rippleLayer.frame = CGRectMake(subX, subY, circleDiameter, circleDiameter);
  _backgroundLayer.frame = _rippleLayer.frame;
  _rippleLayer.path =
      [UIBezierPath bezierPathWithOvalInRect:_rippleLayer.bounds].CGPath;
  _backgroundLayer.path = _rippleLayer.path;
}

@end
