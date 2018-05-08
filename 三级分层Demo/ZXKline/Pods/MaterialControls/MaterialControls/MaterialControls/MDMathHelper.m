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

#import "MDMathHelper.h"

@implementation MDMathHelper

+ (CGFloat)distanceBetweenPoint:(CGPoint)p1 andPoint:(CGPoint)p2 {
  float dx = p1.x - p2.x;
  float dy = p1.y - p2.y;
  return sqrtf(dx * dx + dy * dy);
}

+ (NSArray <NSValue*>*)findIntersectionsBetweenCircleCenter:(CGPoint)c1
                                           radius:(CGFloat)r1
                                  andCircleCenter:(CGPoint)c2
                                           radius:(CGFloat)r2 {

  CGFloat d = [MDMathHelper distanceBetweenPoint:c1 andPoint:c2];
  if ((d > r1 + r2) || (d <= fabs(r1 - r2)))
    return nil;
  CGFloat a = (r1 * r1 - r2 * r2 + d * d) / (2 * d);
  CGFloat h = sqrtf(r1 * r1 - a * a);
  CGFloat cx = c1.x + a * (c2.x - c1.x) / d;
  CGFloat cy = c1.y + a * (c2.y - c1.y) / d;
  CGPoint i1 = CGPointZero;
  CGPoint i2 = CGPointZero;
  i1.x = cx + h * (c2.y - c1.y) / d;
  i1.y = cy - h * (c2.x - c1.x) / d;
  i2.x = cx - h * (c2.y - c1.y) / d;
  i2.y = cy + h * (c2.x - c1.x) / d;

  return @[ [NSValue valueWithCGPoint:i1], [NSValue valueWithCGPoint:i2] ];
}

+ (NSArray <NSValue*>*)findTangentsWithCircle:(CGPoint)c
                             radius:(CGFloat)r
                          fromPoint:(CGPoint)p {
  CGFloat dx = c.x - p.x;
  CGFloat dy = c.y - p.y;
  CGFloat dSquared = dx * dx + dy * dy;

  if (dSquared <= r * r) {
    return nil;
  }

  float r2 = sqrtf(dSquared - r * r);
  return [MDMathHelper findIntersectionsBetweenCircleCenter:c
                                                   radius:r
                                          andCircleCenter:p
                                                   radius:r2];
}
@end
