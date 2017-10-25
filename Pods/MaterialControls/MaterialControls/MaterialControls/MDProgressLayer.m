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

#import "MDProgressLayer.h"

#define kMDTrackWidth 5.f

@implementation MDProgressLayer

- (instancetype)initWithSuperLayer:(CALayer *)superLayer {
  if (self = [super init]) {
    _superLayer = superLayer;
    _trackWidth = kMDTrackWidth;
    [self initContents];
    [_superLayer addSublayer:self];
    [_superLayer addObserver:self forKeyPath:@"bounds" options:9 context:nil];
  }
  return self;
}

- (instancetype)initWithSuperView:(UIView *)superView {
  if (self = [super init]) {
    _superView = superView;
    _superLayer = superView.layer;
    _trackWidth = kMDTrackWidth;
    [self initContents];
    [_superLayer addSublayer:self];
    [superView addObserver:self forKeyPath:@"bounds" options:0 context:nil];
  }
  return self;
}

- (void)initContents {
}

- (void)setProgress:(CGFloat)progress {
  if (!_determinate)
    return;

  if (progress > 1)
    _progress = 1;
  else if (progress < 0)
    _progress = 0;
  else
    _progress = progress;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  [self superLayerDidResize];
}

- (void)superLayerDidResize {
}

- (void)startAnimating {
}

- (void)stopAnimating {
}

- (void)dealloc {
  [_superView removeObserver:self forKeyPath:@"bounds"];
  [_superLayer removeObserver:self forKeyPath:@"bounds"];
}

@end
