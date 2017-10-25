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

#import "UIViewHelper.h"

@implementation UIViewHelper

+ (NSLayoutConstraint *)addConstraintWithItem:(id)view1
                                    attribute:(NSLayoutAttribute)attr1
                                    relatedBy:(NSLayoutRelation)relation
                                       toItem:(id)view2
                                    attribute:(NSLayoutAttribute)attr2
                                   multiplier:(CGFloat)multiplier
                                     constant:(CGFloat)c
                                       toView:(UIView *)view {
  NSLayoutConstraint *constraint =
      [NSLayoutConstraint constraintWithItem:view1
                                   attribute:attr1
                                   relatedBy:relation
                                      toItem:view2
                                   attribute:attr2
                                  multiplier:multiplier
                                    constant:c];
  constraint.priority = UILayoutPriorityRequired;
  [view addConstraint:constraint];
  return constraint;
}

+ (NSLayoutConstraint *)addConstraintWithItem:(id)view1
                                    attribute:(NSLayoutAttribute)attr1
                                    relatedBy:(NSLayoutRelation)relation
                                       toItem:(id)view2
                                    attribute:(NSLayoutAttribute)attr2
                                   multiplier:(CGFloat)multiplier
                                     constant:(CGFloat)c
                                     priority:(UILayoutPriority)priority
                                       toView:(UIView *)view {
  NSLayoutConstraint *constraint =
      [NSLayoutConstraint constraintWithItem:view1
                                   attribute:attr1
                                   relatedBy:relation
                                      toItem:view2
                                   attribute:attr2
                                  multiplier:multiplier
                                    constant:c];
  constraint.priority = priority;
  [view addConstraint:constraint];
  return constraint;
}

+ (NSArray<NSLayoutConstraint *> *)
addConstraintsWithVisualFormat:(NSString *)format
                       options:(NSLayoutFormatOptions)opts
                       metrics:(NSDictionary<NSString *, id> *)metrics
                         views:(NSDictionary<NSString *, id> *)views
                        toView:(UIView *)view {
  NSArray<NSLayoutConstraint *> *constraints =
      [NSLayoutConstraint constraintsWithVisualFormat:format
                                              options:opts
                                              metrics:metrics
                                                views:views];
  [view addConstraints:constraints];
  return constraints;
}
@end
