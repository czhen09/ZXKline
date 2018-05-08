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

#import <Foundation/Foundation.h>
#import "MDCalendarYearSelectorViewCell.h"
#import "MDCalendar.h"

@interface MDCalendarYearSelectorViewCell ()

@property(nonatomic) CAShapeLayer *backgroundCurentYearLayer;
@end

@implementation MDCalendarYearSelectorViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    [self setBackgroundColor:[UIColor clearColor]];
    [self.textLabel setTextColor:_titleColors[@(MDCalendarCellStateNormal)]];
  }
  return self;
}

- (void)setCurrentYear:(BOOL)currentYear {
  if (_currentYear != currentYear) {
    _currentYear = currentYear;
  }

  if (_currentYear) {
    if (_backgroundCurentYearLayer == nil) {
      _backgroundCurentYearLayer = [CAShapeLayer layer];
      _backgroundCurentYearLayer.backgroundColor = [UIColor clearColor].CGColor;
      int diameter = self.mdHeight;
      _backgroundCurentYearLayer.frame = CGRectMake(
          (self.bounds.size.width - diameter) / 2, 0, diameter, diameter);
      _backgroundCurentYearLayer.path =
          [UIBezierPath
              bezierPathWithOvalInRect:_backgroundCurentYearLayer.bounds]
              .CGPath;
      _backgroundCurentYearLayer.fillColor =
          ((UIColor *)_backgroundColors[@(MDCalendarCellStateSelected)])
              .CGColor;
      [self.contentView.layer insertSublayer:_backgroundCurentYearLayer
                                     atIndex:0];
    }
    int diameter = self.mdHeight;
    _backgroundCurentYearLayer.frame = CGRectMake(
        (self.bounds.size.width - diameter) / 2, 0, diameter, diameter);

    _backgroundCurentYearLayer.hidden = NO;
    [self.textLabel setTextColor:_titleColors[@(MDCalendarCellStateSelected)]];
  } else {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _backgroundCurentYearLayer.hidden = YES;
    [CATransaction commit];
    [self.textLabel setTextColor:_titleColors[@(MDCalendarCellStateNormal)]];
  }
}
@end
