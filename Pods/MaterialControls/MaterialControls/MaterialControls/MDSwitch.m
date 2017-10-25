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

#import "MDSwitch.h"
#import "MDConstants.h"
#import "MDRippleLayer.h"
#import "UIColorHelper.h"
#import "UIViewHelper.h"

#define kMDControlWidth 40
#define kMDControlHeight 20
#define kMDTrackWidth 34
#define kMDTrackHeight 12
#define kMDTrackCornerRadius 6
#define kMDThumbRadius 10

#define kMDRippleAlpha .1

#define MOVE_ANIMATION @"move_animation"
#define MOVE_ANIM_DURATION 1

@interface ColorPalette : NSObject
@property(nonatomic) UIColor *thumbColor;
@property(nonatomic) UIColor *trackColor;
- (instancetype)initWithThumbColor:(UIColor *)thumbColor
                        trackColor:(UIColor *)trackColor;
@end

@implementation ColorPalette
- (instancetype)initWithThumbColor:(UIColor *)thumbColor
                        trackColor:(UIColor *)trackColor {
  if (self = [super init]) {
    _thumbColor = thumbColor;
    _trackColor = trackColor;
  }
  return self;
}
@end

@interface SwitchLayer : CALayer

@property(nonatomic) BOOL on;
@property(nonatomic) BOOL enabled;

@property(weak, nonatomic) UIControl *parent;

- (void)initLayers;
@end

@implementation SwitchLayer {
  CAShapeLayer *trackLayer;
  CALayer *thumbHolder;
  CAShapeLayer *thumbLayer;
  CALayer *thumbBackground;
  MDRippleLayer *rippleLayer;
  MDRippleLayer *shadowLayer;
  BOOL touchInside;
  CGPoint touchDownLocation;
  CGRect thumbFrame;
  ColorPalette *onColorPalette;
  ColorPalette *offColorPalette;
  ColorPalette *disableColorPalette;
}

- (instancetype)initWithParent:(UIControl *)parent {
  if (self = [super init]) {
    _parent = parent;
    [self initLayers];
  }

  return self;
}

- (void)initLayers {
  trackLayer = [CAShapeLayer layer];
  thumbLayer = [CAShapeLayer layer];
  thumbBackground = [CALayer layer];
  thumbHolder = [CALayer layer];
  shadowLayer = [[MDRippleLayer alloc] initWithSuperLayer:thumbLayer];
  shadowLayer.rippleScaleRatio = 0;

  rippleLayer = [[MDRippleLayer alloc] initWithSuperLayer:thumbBackground];
  rippleLayer.rippleScaleRatio = 1.7;
  rippleLayer.enableMask = false;
  rippleLayer.enableElevation = false;

  [thumbHolder addSublayer:thumbBackground];
  [thumbHolder addSublayer:thumbLayer];

  [self addSublayer:trackLayer];
  [self addSublayer:thumbHolder];
}

#pragma mark setters

- (void)setEnabled:(BOOL)enabled {
  _enabled = enabled;
  [self updateColor];
}

- (void)setOn:(BOOL)on {
  _on = on;
  [self switchState:on];
  [_parent sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setOnColorPalette:(ColorPalette *)colorPalette {
  onColorPalette = colorPalette;
  [self updateColor];
}

- (void)setOffColorPalette:(ColorPalette *)colorPalette {
  offColorPalette = colorPalette;
  [self updateColor];
}

- (void)setDisableColorPalette:(ColorPalette *)colorPalette {
  disableColorPalette = colorPalette;
  [self updateColor];
}

- (void)setThumbOn:(UIColor *)thumbOnColor {
  onColorPalette.thumbColor = thumbOnColor;
  [self updateColor];
}

- (void)setTrackOn:(UIColor *)trackOnColor {
  onColorPalette.trackColor = trackOnColor;
  [self updateColor];
}

- (void)setThumbOff:(UIColor *)thumbOffColor {
  offColorPalette.thumbColor = thumbOffColor;
  [self updateColor];
}

- (void)setTrackOff:(UIColor *)trackOffColor {
  offColorPalette.trackColor = trackOffColor;
  [self updateColor];
}

- (void)setThumbDisabled:(UIColor *)thumbDisabledColor {
  disableColorPalette.thumbColor = thumbDisabledColor;
  [self updateColor];
}

- (void)setTrackDisabled:(UIColor *)trackDisabledColor {
  disableColorPalette.trackColor = trackDisabledColor;
  [self updateColor];
}

#pragma mark private methods
- (void)updateSuperBounds:(CGRect)bounds {

  CGPoint center = CGRectCenter(bounds);
  CGFloat subX = center.x - kMDControlWidth / 2;
  CGFloat subY = center.y - kMDControlHeight / 2;
  [self setFrame:CGRectMake(subX, subY, kMDControlWidth, kMDControlHeight)];
  [self updateTrackLayer];
  [self updateThumbLayer];
}

- (void)updateTrackLayer {
  CGPoint center = CGRectCenter(self.bounds);
  CGFloat subX = center.x - kMDTrackWidth / 2;
  CGFloat subY = center.y - kMDTrackHeight / 2;
  [trackLayer setFrame:CGRectMake(subX, subY, kMDTrackWidth, kMDTrackHeight)];

  UIBezierPath *path =
      [UIBezierPath bezierPathWithRoundedRect:trackLayer.bounds
                            byRoundingCorners:UIRectCornerAllCorners
                                  cornerRadii:CGSizeMake(kMDTrackCornerRadius,
                                                         kMDTrackCornerRadius)];

  trackLayer.path = path.CGPath;
}

- (void)updateColor {
  if (!_enabled) {
    trackLayer.fillColor = disableColorPalette.trackColor.CGColor;
    thumbLayer.fillColor = disableColorPalette.thumbColor.CGColor;
  } else if (_on) {
    trackLayer.fillColor = onColorPalette.trackColor.CGColor;
    thumbLayer.fillColor = onColorPalette.thumbColor.CGColor;
    [rippleLayer setEffectColor:onColorPalette.thumbColor
                withRippleAlpha:kMDRippleAlpha
                backgroundAlpha:kMDRippleAlpha];
  } else {
    trackLayer.fillColor = offColorPalette.trackColor.CGColor;
    thumbLayer.fillColor = offColorPalette.thumbColor.CGColor;
    [rippleLayer setEffectColor:offColorPalette.thumbColor
                withRippleAlpha:kMDRippleAlpha
                backgroundAlpha:kMDRippleAlpha];
  }
}

- (void)updateThumbLayer {
  CGFloat subX = 0;
  if (_on) {
    subX = kMDControlWidth - kMDThumbRadius * 2;
  }

  thumbFrame = CGRectMake(subX, 0, kMDThumbRadius * 2, kMDThumbRadius * 2);

  [thumbHolder setFrame:thumbFrame];

  [thumbBackground setFrame:thumbHolder.bounds];
  [thumbLayer setFrame:thumbHolder.bounds];

  UIBezierPath *path =
      [UIBezierPath bezierPathWithOvalInRect:thumbLayer.bounds];
  thumbLayer.path = path.CGPath;
}

- (void)switchState:(BOOL)on {
  if (on) {
    thumbFrame = CGRectMake(kMDControlWidth - kMDThumbRadius * 2, 0,
                            kMDThumbRadius * 2, kMDThumbRadius * 2);
  } else {
    thumbFrame = CGRectMake(0, 0, kMDThumbRadius * 2, kMDThumbRadius * 2);
  }

  thumbHolder.frame = thumbFrame;

  [self updateColor];
}

#pragma mark Touch events
- (void)onTouchDown:(CGPoint)touchLocation {
  if (_enabled) {
    [rippleLayer startEffectsAtLocation:[self convertPoint:touchLocation
                                                   toLayer:thumbBackground]];
    [shadowLayer startEffectsAtLocation:[self convertPoint:touchLocation
                                                   toLayer:thumbLayer]];

    touchInside = [self containsPoint:touchLocation];

    touchDownLocation = touchLocation;
  }
}

- (void)onTouchMoved:(CGPoint)moveLocation {
  if (_enabled) {
    if (touchInside) {
      float x = thumbFrame.origin.x + (moveLocation.x - touchDownLocation.x);
      if (x < 0) {
        x = 0;
      } else if (x > self.bounds.size.width - thumbFrame.size.width) {
        x = self.bounds.size.width - thumbFrame.size.width;
      }

      CGRect frame = CGRectMake(x, thumbFrame.origin.y, thumbFrame.size.width,
                                thumbFrame.size.height);
      thumbHolder.frame = frame;
    }
  }
}

- (void)onTouchUp:(CGPoint)touchLocation {
  if (_enabled) {
    [rippleLayer stopEffects];
    [shadowLayer stopEffects];
    if (!touchInside ||
        [self checkPoint:touchDownLocation equal:touchLocation]) {
      self.on = !self.on;
    } else {
      if (_on && touchLocation.x < touchDownLocation.x) {
        self.on = NO;
      } else if (!_on && touchLocation.x > touchDownLocation.x) {
        self.on = YES;
      }
    }
    touchInside = NO;
  }
}

- (BOOL)checkPoint:(CGPoint)p1 equal:(CGPoint)p2 {
  return (fabs(p1.x - p2.x) <= 5) && (fabs(p1.y - p2.y) <= 5);
}

@end

@implementation MDSwitch {
  SwitchLayer *switchLayer;
}

- (instancetype)init {
  if (self = [super init]) {
    [self initContent];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self initContent];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self initContent];
  }

  return self;
}

- (void)initContent {
  switchLayer = [[SwitchLayer alloc] initWithParent:self];
  self.enabled = YES;
  self.thumbDisable = [UIColorHelper colorWithRGBA:kMDSwitchThumbDisabledColor];

  [switchLayer
      setOnColorPalette:
          [[ColorPalette alloc]
              initWithThumbColor:[UIColorHelper
                                     colorWithRGBA:kMDSwitchThumbOnColor]
                      trackColor:[UIColorHelper
                                     colorWithRGBA:kMDSwitchTrackOnColor]]];
  [switchLayer
      setOffColorPalette:
          [[ColorPalette alloc]
              initWithThumbColor:[UIColorHelper
                                     colorWithRGBA:kMDSwitchThumbOffColor]
                      trackColor:[UIColorHelper
                                     colorWithRGBA:kMDSwitchTrackOnColor]]];
  [switchLayer
      setDisableColorPalette:
          [[ColorPalette alloc]
              initWithThumbColor:[UIColorHelper
                                     colorWithRGBA:kMDSwitchThumbDisabledColor]
                      trackColor:
                          [UIColorHelper
                              colorWithRGBA:kMDSwitchTrackDisabledColor]]];

  [self.layer addSublayer:switchLayer];
}

- (void)setOn:(BOOL)on {
  [switchLayer setOn:on];
}

- (BOOL)isOn {
  return switchLayer.on;
}

- (void)setEnabled:(BOOL)enabled {
  [super setEnabled:enabled];
  [switchLayer setEnabled:enabled];
}

- (void)setThumbOn:(UIColor *)thumbOnColor {
  _thumbOn = thumbOnColor;
  [switchLayer setThumbOn:_thumbOn];
}

- (void)setTrackOn:(UIColor *)trackOnColor {
  _trackOn = trackOnColor;
  [switchLayer setTrackOn:_trackOn];
}

- (void)setThumbOff:(UIColor *)thumbOffColor {
  _thumbOff = thumbOffColor;
  [switchLayer setThumbOff:_thumbOff];
}

- (void)setTrackOff:(UIColor *)trackOffColor {
  _trackOff = trackOffColor;
  [switchLayer setTrackOff:_trackOff];
}

- (void)setThumbDisable:(UIColor *)thumbDisableColor {
  _thumbDisabled = thumbDisableColor;
  [switchLayer setThumbDisabled:_thumbDisabled];
}

- (void)setTrackDisabled:(UIColor *)trackDisabledColor {
  _trackDisabled = trackDisabledColor;
  [switchLayer setTrackDisabled:_trackDisabled];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [switchLayer updateSuperBounds:self.bounds];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];
  CGPoint point = [touches.allObjects[0] locationInView:self];
  [switchLayer onTouchDown:[self.layer convertPoint:point toLayer:switchLayer]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event];
  CGPoint point = [touches.allObjects[0] locationInView:self];
  [switchLayer onTouchUp:[self.layer convertPoint:point toLayer:switchLayer]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];
  CGPoint point = [touches.allObjects[0] locationInView:self];
  [switchLayer
      onTouchMoved:[self.layer convertPoint:point toLayer:switchLayer]];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesCancelled:touches withEvent:event];
  CGPoint point = [touches.allObjects[0] locationInView:self];
  [switchLayer onTouchUp:[self.layer convertPoint:point toLayer:switchLayer]];
}

@end
