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

#import "UIView+MDExtension.h"

@implementation UIView (MDExtension)

- (CGFloat)mdWidth {
  return CGRectGetWidth(self.frame);
}

- (void)setMdWidth:(CGFloat)mdWidth {
  self.frame = CGRectMake(self.mdLeft, self.mdTop, mdWidth, self.mdHeight);
}

- (CGFloat)mdHeight {
  return CGRectGetHeight(self.frame);
}

- (void)setMdHeight:(CGFloat)mdHeight {
  self.frame = CGRectMake(self.mdLeft, self.mdTop, self.mdWidth, mdHeight);
}

- (CGFloat)mdTop {
  return CGRectGetMinY(self.frame);
}

- (void)setMdTop:(CGFloat)mdTop {
  self.frame = CGRectMake(self.mdLeft, mdTop, self.mdWidth, self.mdHeight);
}

- (CGFloat)mdBottom {
  return CGRectGetMaxY(self.frame);
}

- (void)setMdBottom:(CGFloat)mdBottom {
  self.mdTop = mdBottom - self.mdHeight;
}

- (CGFloat)mdLeft {
  return CGRectGetMinX(self.frame);
}

- (void)setMdLeft:(CGFloat)mdLeft {
  self.frame = CGRectMake(mdLeft, self.mdTop, self.mdWidth, self.mdHeight);
}

- (CGFloat)mdRight {
  return CGRectGetMaxX(self.frame);
}

- (void)setMdRight:(CGFloat)mdRight {
  self.mdLeft = mdRight - self.mdWidth;
}

- (CGFloat)mdCenterX {
  return self.mdLeft + self.mdWidth / 2;
}

- (void)setMdCenterX:(CGFloat)mdCenterX {
  self.mdLeft = mdCenterX - self.mdWidth / 2;
}

- (CGFloat)mdCenterY {
  return self.mdTop + self.mdHeight / 2;
}

- (void)setMdCenterY:(CGFloat)mdCenterY {
  self.mdTop = mdCenterY - self.mdHeight / 2;
}
@end
