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
#import "MDConstants.h"
#import "MDLinearProgressLayer.h"
#import "MDProgress.h"
#import "UIColorHelper.h"

@implementation MDProgress {
  MDProgressLayer *drawingLayer;
}

- (instancetype)init {
  if (self = [super init])
    [self initLayer];
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder])
    [self initLayer];
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame])
    [self initLayer];
  return self;
}

- (id)initWithFrame:(CGRect)frame type:(enum MDProgressType)progressType {
  if (self = [super initWithFrame:frame]) {
    [self initLayer];
    _type = progressType;
  }
  return self;
}

- (void)initLayer {
  _progressColor = [UIColorHelper colorWithRGBA:kMDProgressColor];
  _trackColor = [UIColorHelper colorWithRGBA:kMDProgressTrackColor];

  drawingLayer =
      [[MDCircularProgressLayer alloc] initWithSuperLayer:self.layer];
  drawingLayer.progressColor = _progressColor;
  drawingLayer.trackColor = _trackColor;
  if (_progressType == MDProgressTypeIndeterminate)
    [drawingLayer startAnimating];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [drawingLayer superLayerDidResize];
}

#pragma mark setters
- (void)setProgressColor:(UIColor *)progressColor {
  _progressColor = progressColor;
  drawingLayer.progressColor = progressColor;
}

- (void)setTrackColor:(UIColor *)trackColor {
  _trackColor = trackColor;
  drawingLayer.trackColor = trackColor;
}

- (void)setEnableTrackColor:(BOOL)enableTrackColor {
  _enableTrackColor = enableTrackColor;
  drawingLayer.drawTrack = enableTrackColor;
}

- (void)setTrackWidth:(CGFloat)trackWidth {
  _trackWidth = trackWidth;
  drawingLayer.trackWidth = trackWidth;
}

- (void)setType:(NSInteger)type {
  switch (type) {
  case 1:
    [self setProgressType:MDProgressTypeDeterminate];
    break;
  //  case 2:
  //    [self setProgressType:Buffer];
  //    break;
  //  case 3:
  //    [self setProgressType:QueryIndeterminateAndDeterminate];
  //    break;
  default:
    [self setProgressType:MDProgressTypeIndeterminate];
  }
}

- (void)setStyle:(NSInteger)style {
  switch (style) {
  case 1:
    [self setProgressStyle:MDProgressStyleLinear];
    break;
  default:
    [self setProgressStyle:MDProgressStyleCircular];
    break;
  }
}

- (void)setProgressStyle:(MDProgressStyle)progressStyle {

  if (_progressStyle != progressStyle) {
    _progressStyle = progressStyle;
    [drawingLayer removeFromSuperlayer];
    switch (progressStyle) {
    case MDProgressStyleCircular:
      drawingLayer =
          [[MDCircularProgressLayer alloc] initWithSuperLayer:self.layer];
      //      drawingLayer =
      //          [[MDCircularProgressLayer alloc]
      //          initWithSuperLayer:self.layer];
      drawingLayer.progressColor = _progressColor;
      drawingLayer.trackColor = _trackColor;
      break;
    case MDProgressStyleLinear:
      drawingLayer =
          [[MDLinearProgressLayer alloc] initWithSuperLayer:self.layer];
      drawingLayer.progressColor = _progressColor;
      drawingLayer.trackColor = _trackColor;
      break;

    default:
      break;
    }

    drawingLayer.determinate = (_progressType == MDProgressTypeDeterminate);
    if (_progressType == MDProgressTypeIndeterminate) {
      [drawingLayer startAnimating];
    }
  }
}

- (void)setProgressType:(MDProgressType)progressType {
  _progressType = progressType;
  switch (progressType) {
  case MDProgressTypeIndeterminate:
    drawingLayer.determinate = NO;
    break;
  case MDProgressTypeDeterminate:
    drawingLayer.determinate = YES;
    drawingLayer.progress = _progress;
    break;
  //  case Buffer:
  //    break;
  //  case QueryIndeterminateAndDeterminate:
  //    break;

  default:
    break;
  }
}

- (void)setProgress:(CGFloat)progress {
  _progress = progress;
  drawingLayer.progress = progress;
}

- (void)setCircularSize:(CGFloat)circularSize {
  _circularSize = circularSize;
  if ([drawingLayer isKindOfClass:[MDCircularProgressLayer class]]) {
    ((MDCircularProgressLayer *)drawingLayer).cirleDiameter = circularSize;
  }
}

@end
