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

#import "MDCircularProgressLayer.h"
#import "UIViewHelper.h"
#import <UIKit/UIKit.h>

#define kMDRotateAnimationKey @"rotate"
#define kMDStrokeAnimationKey @"stroke"
#define kMDCirleDiameter 48.f
#define kMDArcsCount 20.f
#define kMDMaxStrokeLength .75f
#define kMDMinStrokeLength .05f

@interface MDCircularProgressLayer ()
@property(nonatomic) CAShapeLayer *progressLayer;
@property(nonatomic) CAShapeLayer *trackLayer;

@end

@implementation MDCircularProgressLayer

float animationDuration = 0.75f;
float rotateAnimationDuration = 2.f;
float anArc = 1.f / kMDArcsCount;
CAMediaTimingFunction *timmingFunction;

- (instancetype)initWithSuperLayer:(CALayer *)superLayer {
  if (self = [super initWithSuperLayer:superLayer]) {
    if (!timmingFunction)
      timmingFunction = [CAMediaTimingFunction
          functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  }

  return self;
}

- (void)initContents {
  _cirleDiameter = kMDCirleDiameter;
  [self updateFrame];

  _progressLayer = [CAShapeLayer layer];
  _progressLayer.strokeColor = self.progressColor.CGColor;
  _progressLayer.fillColor = nil;
  _progressLayer.lineWidth = self.trackWidth;
  _progressLayer.strokeStart = 0.f;
  _progressLayer.strokeEnd = 0.5f;

  _trackLayer = [CAShapeLayer layer];
  _trackLayer.strokeColor = self.trackColor.CGColor;
  _trackLayer.fillColor = nil;
  _trackLayer.lineWidth = self.trackWidth;
  _trackLayer.strokeStart = 0.f;
  _trackLayer.strokeEnd = 1.f;

  _trackLayer.frame = self.bounds;
  _progressLayer.frame = self.bounds;

  [self addSublayer:_trackLayer];
  [self addSublayer:_progressLayer];
  [self updateContents];

  if (!self.drawTrack) {
    _trackLayer.opacity = 0;
  }
}

#pragma mark Setters
- (void)setProgressColor:(UIColor *)progressColor {
  [super setProgressColor:progressColor];
  _progressLayer.strokeColor = self.progressColor.CGColor;
}

- (void)setTrackColor:(UIColor *)trackColor {
  [super setTrackColor:trackColor];
  _trackLayer.strokeColor = self.trackColor.CGColor;
}

- (void)setTrackWidth:(CGFloat)trackWidth {
  [super setTrackWidth:trackWidth];
  _progressLayer.lineWidth = self.trackWidth;
  _trackLayer.lineWidth = self.trackWidth;
}

- (void)setDrawTrack:(BOOL)drawTrack {
  [super setDrawTrack:drawTrack];
  if (drawTrack) {
    _trackLayer.opacity = 1.0f;
  } else {
    _trackLayer.opacity = 0.0f;
  }
}

- (void)setDeterminate:(BOOL)determinate {
  [super setDeterminate:determinate];
  if (self.determinate) {
    [self stopAnimating];
  } else {
    [self startAnimating];
  }
}

- (void)setProgress:(CGFloat)progress {
  [super setProgress:progress];
  if (!self.determinate)
    return;

  _progressLayer.strokeEnd = anArc * self.progress;
  _progressLayer.transform =
      CATransform3DMakeRotation(self.progress * 3 * M_PI_2, 0, 0, 1);
}

- (void)setCirleDiameter:(float)cirleDiameter {
  _cirleDiameter = cirleDiameter;
  [self updateFrame];
  [self updateContents];
}

#pragma mark ProgressLayer's methods 
- (void)superLayerDidResize {
  [self updateFrame];
}

#pragma mark private methods
- (void)updateFrame {
  CGPoint center = CGRectCenter(self.superLayer.bounds);
  self.frame =
      CGRectMake(center.x - _cirleDiameter / 2, center.y - _cirleDiameter / 2,
                 _cirleDiameter, _cirleDiameter);
    _trackLayer.frame = self.bounds;
    _progressLayer.frame = self.bounds;
}

- (void)updateContents {
  CGPoint center = CGRectCenter(self.bounds);
  CGFloat radius =
      MIN(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2) -
      _progressLayer.lineWidth / 2;
  CGFloat startAngle = (CGFloat)(0);
  CGFloat endAngle = (CGFloat)((kMDArcsCount * 2 + 1.5f) * M_PI);
  UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                      radius:radius
                                                  startAngle:startAngle
                                                    endAngle:endAngle
                                                   clockwise:YES];
  _progressLayer.path = path.CGPath;
  _trackLayer.path = path.CGPath;
}

- (void)startAnimating {
  if (self.isAnimating || self.determinate)
    return;

  CABasicAnimation *rotateAnimation =
      [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
  rotateAnimation.duration = rotateAnimationDuration;
  rotateAnimation.fromValue = @(0.f);
  rotateAnimation.toValue = @(2 * M_PI);
  rotateAnimation.repeatCount = INFINITY;
  rotateAnimation.removedOnCompletion = false;
  rotateAnimation.fillMode = kCAFillModeForwards;

  [self addAnimation:rotateAnimation forKey:kMDRotateAnimationKey];
  [_progressLayer addAnimation:[MDCircularProgressLayer indeterminateAnimation]
                        forKey:kMDStrokeAnimationKey];
  self.isAnimating = true;
}

- (void)stopAnimating {
  if (!self.isAnimating)
    return;

  [self removeAllAnimations];
  [_progressLayer removeAllAnimations];
  self.isAnimating = false;
}

+ (CAAnimationGroup *)indeterminateAnimation {
  static CAAnimationGroup *animationGroups = nil;
  if (!animationGroups) {
    NSMutableArray *animations = [NSMutableArray array];
    float startValue = 0;
    float startTime = 0;

    do {
      [animations
          addObjectsFromArray:[self createAnimationFromStartValue:startValue
                                                     andStartTime:startTime
                                                   withValueScale:anArc]];
      startValue += anArc * (kMDMaxStrokeLength + kMDMinStrokeLength);
      startTime += animationDuration * 2;
    } while (fmodf(floorf(startValue * 1000), 1000) != 0);

    animationGroups = [CAAnimationGroup animation];
    animationGroups.duration = startTime;
    [animationGroups setAnimations:animations];
    [animationGroups setRepeatCount:INFINITY];
    animationGroups.removedOnCompletion = false;
    animationGroups.fillMode = kCAFillModeForwards;
  }

  return animationGroups;
}

+ (NSArray *)createAnimationFromStartValue:(float)beginValue
                              andStartTime:(float)beginTime
                            withValueScale:(float)aCircle {
  CABasicAnimation *headAnimation =
      [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
  headAnimation.duration = animationDuration;
  headAnimation.beginTime = beginTime;
  headAnimation.fromValue = @(beginValue);
  headAnimation.toValue =
      @(beginValue + aCircle * (kMDMaxStrokeLength + kMDMinStrokeLength));
  headAnimation.timingFunction = timmingFunction;

  CABasicAnimation *tailAnimation =
      [CABasicAnimation animationWithKeyPath:@"strokeStart"];
  tailAnimation.duration = animationDuration;
  tailAnimation.beginTime = beginTime;
  tailAnimation.fromValue = @(beginValue - aCircle * kMDMinStrokeLength);
  tailAnimation.toValue = @(beginValue);
  tailAnimation.timingFunction = timmingFunction;

  CABasicAnimation *endHeadAnimation =
      [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
  endHeadAnimation.duration = animationDuration;
  endHeadAnimation.beginTime = beginTime + animationDuration;
  endHeadAnimation.fromValue =
      @(beginValue + aCircle * (kMDMaxStrokeLength + kMDMinStrokeLength));
  endHeadAnimation.toValue =
      @(beginValue + aCircle * (kMDMaxStrokeLength + kMDMinStrokeLength));
  endHeadAnimation.timingFunction = timmingFunction;

  CABasicAnimation *endTailAnimation =
      [CABasicAnimation animationWithKeyPath:@"strokeStart"];
  endTailAnimation.duration = animationDuration;
  endTailAnimation.beginTime = beginTime + animationDuration;
  endTailAnimation.fromValue = @(beginValue);
  endTailAnimation.toValue = @(beginValue + aCircle * kMDMaxStrokeLength);
  endTailAnimation.timingFunction = timmingFunction;
  return @[ headAnimation, tailAnimation, endHeadAnimation, endTailAnimation ];
}

@end
