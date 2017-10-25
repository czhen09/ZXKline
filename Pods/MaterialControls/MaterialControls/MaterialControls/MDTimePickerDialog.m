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

#import "MDButton.h"
#import "MDDeviceHelper.h"
#import "MDTimePickerDialog.h"
#import "NSDate+MDExtension.h"
#import "NSDateHelper.h"
#import "UIColorHelper.h"
#import "UIFontHelper.h"
#import "UIView+MDExtension.h"

#define DEGREES_TO_RADIANS(degrees) ((M_PI * degrees) / 180)

#define kCalendarHeaderHeight                                                  \
  (([[UIScreen mainScreen] bounds].size.width > 320) ? 120 : 70)
#define kCalendarTimerModeHeight 60
#define kCalendarActionBarHeight 50
#define kCalendarClockHeight                                                   \
  (MAX(popupHolder.mdWidth, popupHolder.mdHeight) / 2 * 4.5 / 6.0)

#define kMainCircleRadius 15
#define kSmallCircleRadius 2
#define kHourItemSize 30
#define kClockPadding 5

@interface MDTimePickerDialog ()

@property(nonatomic) CAShapeLayer *backgroundClock;

@property(nonatomic) UILabel *labelTimeModeAM;
@property(nonatomic) UILabel *labelTimeModePM;
@property(nonatomic) CAShapeLayer *backgroundTimeMode;

@property(nonatomic) UIView *clockHour;
@property(nonatomic) UIView *clockMinute;
@property(nonatomic) UIView *clockHandView;
@property(nonatomic) CAShapeLayer *maskVisibleIndexLayer;
@property(nonatomic) CAShapeLayer *maskInvisibleIndexLayer;

@property(nonatomic, strong) CAShapeLayer *smallInvisibleIndexCircleLayer;
@property(nonatomic, strong) CAShapeLayer *centerInvisibleIndexCircleLayer;
@property(nonatomic, strong) CAShapeLayer *selectorInvisibleIndexCircleLayer;
@property(nonatomic, strong) CAShapeLayer *centerCircleLayer;

@property(nonatomic) UIView *header;
@property(nonatomic) UILabel *headerLabelHour;
@property(nonatomic) UILabel *headerLabelMinute;
@property(nonatomic) UILabel *headerLabelTimeMode;

@property(nonatomic) MDButton *buttonOk;
@property(nonatomic) MDButton *buttonCancel;

@property(nonatomic) UIFont *buttonFont;

@property(nonatomic) NSString *okTitle;
@property(nonatomic) NSString *cancelTitle;

@property(nonatomic) NSInteger currentHour;
@property(nonatomic) NSInteger currentMinute;
@end

@implementation MDTimePickerDialog {
  UIView *popupHolder;

  NSInteger preHourTag;
  NSInteger preMinuteTag;

  CAShapeLayer *selectorCircleLayer;
  UIBezierPath *selectorCirclePath;
  UIBezierPath *selectorMinCirclePath;
  NSInteger visiblePanel;
  BOOL animating;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [self initDefaultTime];
    [self initialize];
  }

  return self;
}

- (instancetype)initWithHour:(NSInteger)hour minute:(NSInteger)minute {
  self = [super init];
  if (self) {
    self.currentHour = (int)hour % 24;
    self.currentMinute = (int)minute % 60;
    [self initialize];
  }

  return self;
}

- (instancetype)initWithClockMode:(MDClockMode)clockMode {
  if (self = [super init]) {
    [self initDefaultTime];
    [self initialize];
    self.clockMode = clockMode;
  }

  return self;
}

- (instancetype)initWithHour:(NSInteger)hour
                      minute:(NSInteger)minute
                   clockMode:(MDClockMode)clockMode {
  if (self = [super init]) {
    self.currentHour = (int)hour % 24;
    self.currentMinute = (int)minute % 60;
    [self initialize];
    self.clockMode = clockMode;
  }

  return self;
}

- (void)initialize {
  self.theme = MDTimePickerThemeDark;

  [self initDefaultValues];

  preHourTag = -1;
  preMinuteTag = -1;
  [self initComponents];
  [self initClockHandView];
  [self initClock];

  [self updateColors];
  [self updateContent];

  UIPanGestureRecognizer *panGesture =
      [[UIPanGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(rotateHand:)];
  [panGesture setMaximumNumberOfTouches:1];
  [self addGestureRecognizer:panGesture];

  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(tapGestureHandler:)];
  [popupHolder addGestureRecognizer:tapGesture];
  [popupHolder bringSubviewToFront:_labelTimeModeAM];
  [popupHolder bringSubviewToFront:_labelTimeModePM];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(deviceOrientationDidChange:)
             name:UIDeviceOrientationDidChangeNotification
           object:nil];
}

- (void)initDefaultTime {
  NSDate *currentDate = [NSDate date];
  _currentHour = (int)currentDate.mdHour;
  _currentMinute = (int)currentDate.mdMinute;

  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setLocale:[NSLocale currentLocale]];
  [formatter setDateStyle:NSDateFormatterNoStyle];
  [formatter setTimeStyle:NSDateFormatterShortStyle];
}

- (void)initDefaultValues {
  if ([NSDateHelper prefers24Hour]) {
    self.clockMode = MDClockMode24H;
  } else {
    self.clockMode = MDClockMode12H;
  }
}

- (void)setClockMode:(MDClockMode)clockMode {
  if (_clockMode != clockMode) {
    _clockMode = clockMode;
    [self updateContent];
  }
}

- (void)setCurrentHour:(NSInteger)currentHour {
  if (_currentHour != currentHour) {
    _currentHour = currentHour;
  }
}

- (void)setCurrentMinute:(NSInteger)currentMinute {
  if (_currentMinute != currentMinute) {
    _currentMinute = currentMinute;
  }
}

- (void)setTheme:(MDTimePickerTheme)theme {
  if (_theme == theme)
    return;
  _theme = theme;

  _headerTextColor = [UIColor whiteColor];
  _titleSelectedColor = [UIColor whiteColor];

  if (theme == MDTimePickerThemeLight) {

    _headerBackgroundColor = [UIColorHelper colorWithRGBA:@"#009688"];
    _titleColor = [UIColorHelper colorWithRGBA:@"#2F2F2F"];
    _selectionColor = [UIColorHelper colorWithRGBA:@"#009688"];
    _selectionCenterColor = [UIColorHelper colorWithRGBA:@"#000302"];
    _backgroundPopupColor = [UIColor whiteColor];
    _backgroundClockColor = [UIColorHelper colorWithRGBA:@"#ECEFF1"];

  } else if (theme == MDTimePickerThemeDark) {

    _headerBackgroundColor = [UIColorHelper colorWithRGBA:@"#80CBC4"];
    _titleColor = [UIColor whiteColor];
    _selectionColor = [UIColorHelper colorWithRGBA:@"#80CBC4"];
    _selectionCenterColor = [UIColor whiteColor];
    _backgroundPopupColor = [UIColorHelper colorWithRGBA:@"#263238"];
    _backgroundClockColor = [UIColorHelper colorWithRGBA:@"#364147"];

  } else {
    NSAssert(nil, @"uknown theme: %d", (int)theme);
  }
  [self updateColors];
  [self updateHeaderView];
}

- (void)updateColors;
{
  // configure views
  popupHolder.backgroundColor = _backgroundPopupColor;
  _backgroundClock.fillColor = _backgroundClockColor.CGColor;
  _headerLabelHour.textColor = _headerTextColor;
  _headerLabelMinute.textColor = _headerTextColor;
  _header.backgroundColor = _headerBackgroundColor;

  [self.buttonCancel setTitleColor:_titleColor forState:UIControlStateNormal];
  [self.buttonOk setTitleColor:_titleColor forState:UIControlStateNormal];
  _labelTimeModeAM.textColor = _titleColor;
  _labelTimeModePM.textColor = _titleColor;
  _backgroundTimeMode.fillColor = _selectionColor.CGColor;

  selectorCircleLayer.fillColor = _selectionColor.CGColor;
  self.smallInvisibleIndexCircleLayer.fillColor = _selectionColor.CGColor;
  self.smallInvisibleIndexCircleLayer.strokeColor = _selectionColor.CGColor;

  self.centerInvisibleIndexCircleLayer.fillColor = _selectionColor.CGColor;
  self.centerInvisibleIndexCircleLayer.strokeColor = _selectionColor.CGColor;

  self.selectorInvisibleIndexCircleLayer.strokeColor =
      [_selectionColor colorWithAlphaComponent:0.5f].CGColor;

  selectorCircleLayer.fillColor = _selectionColor.CGColor;
  selectorCircleLayer.strokeColor = _selectionColor.CGColor;

  _backgroundTimeMode.fillColor = _selectionColor.CGColor;

  self.centerCircleLayer.fillColor = _selectionCenterColor.CGColor;
  self.centerCircleLayer.strokeColor = _selectionCenterColor.CGColor;

  for (UIButton *button in [_clockHour subviews]) {
    [button setTitleColor:_titleColor forState:UIControlStateNormal];
  }

  for (UIButton *button in [_clockMinute subviews]) {
    [button setTitleColor:_titleColor forState:UIControlStateNormal];
  }
}

- (void)setHeaderBackgroundColor:(UIColor *)headerBackgroundColor;
{
  _headerBackgroundColor = headerBackgroundColor;
  [self updateColors];
}

- (void)setSelectionColor:(UIColor *)selectionColor;
{
  _selectionColor = selectionColor;
  [self updateColors];
}

- (void)initComponents {
  UIView *rootView = [MDDeviceHelper getMainView];
  [self setFrame:rootView.bounds];

  popupHolder = [[UIView alloc] init];
  popupHolder.layer.shadowOpacity = 0.5;
  popupHolder.layer.shadowRadius = 8;
  popupHolder.layer.shadowColor = [[UIColor blackColor] CGColor];
  popupHolder.layer.shadowOffset = CGSizeMake(0, 2.5);

  int vSpacing = rootView.bounds.size.height * 0.05;
  int hSpacing = rootView.bounds.size.width * 0.1;

  [popupHolder
      setFrame:CGRectMake(hSpacing, vSpacing, self.mdWidth - 2 * hSpacing,
                          self.mdHeight - 2 * vSpacing)];

  _buttonFont = [UIFontHelper robotoFontWithName:@"roboto-bold" size:15];

  MDButton *buttonOk = [[MDButton alloc]
      initWithFrame:CGRectMake(popupHolder.mdWidth -
                                   2 * kCalendarActionBarHeight,
                               popupHolder.mdHeight - kCalendarActionBarHeight,
                               2 * kCalendarActionBarHeight * 3.0 / 4.0,
                               kCalendarActionBarHeight * 3.0 / 4.0)
               type:MDButtonTypeFlat
        rippleColor:nil];
  [buttonOk addTarget:self
                action:@selector(didSelect)
      forControlEvents:UIControlEventTouchUpInside];
  [buttonOk.titleLabel setFont:_buttonFont];
  [popupHolder addSubview:buttonOk];
  self.buttonOk = buttonOk;

  MDButton *buttonCancel = [[MDButton alloc]
      initWithFrame:CGRectMake(popupHolder.mdWidth -
                                   4 * kCalendarActionBarHeight,
                               popupHolder.mdHeight - kCalendarActionBarHeight,
                               2 * kCalendarActionBarHeight * 3.0 / 4.0,
                               kCalendarActionBarHeight * 3.0 / 4.0)
               type:MDButtonTypeFlat
        rippleColor:nil];
  [buttonCancel addTarget:self
                   action:@selector(didCancel)
         forControlEvents:UIControlEventTouchUpInside];

  [buttonCancel.titleLabel setFont:_buttonFont];
  [popupHolder addSubview:buttonCancel];
  self.buttonCancel = buttonCancel;

  [self setTitleOk:@"OK" andTitleCancel:@"CANCEL"];

  [self initHeaderView];

  // time mode component
  _labelTimeModeAM = [[UILabel alloc]
      initWithFrame:CGRectMake(40,
                               kCalendarHeaderHeight + kCalendarClockHeight +
                                   (popupHolder.mdWidth - kCalendarClockHeight),
                               40, 40)];
  _labelTimeModeAM.text = @"AM";
  _labelTimeModeAM.textAlignment = NSTextAlignmentCenter;
  UITapGestureRecognizer *showTimeModeAMSelectorGesture =
      [[UITapGestureRecognizer alloc]
          initWithTarget:self
                  action:@selector(changeTimeModeAM)];

  [_labelTimeModeAM addGestureRecognizer:showTimeModeAMSelectorGesture];
  [_labelTimeModeAM setUserInteractionEnabled:YES];

  _labelTimeModePM = [[UILabel alloc]
      initWithFrame:CGRectMake(popupHolder.mdWidth - 80,
                               kCalendarHeaderHeight + kCalendarClockHeight +
                                   (popupHolder.mdWidth - kCalendarClockHeight),
                               40, 40)];
  _labelTimeModePM.text = @"PM";
  _labelTimeModePM.textAlignment = NSTextAlignmentCenter;
  UITapGestureRecognizer *showTimeModePMSelectorGesture =
      [[UITapGestureRecognizer alloc]
          initWithTarget:self
                  action:@selector(changeTimeModePM)];

  [_labelTimeModePM addGestureRecognizer:showTimeModePMSelectorGesture];
  [_labelTimeModePM setUserInteractionEnabled:YES];

  _backgroundTimeMode = [[CAShapeLayer alloc] init];
  _backgroundTimeMode.backgroundColor = [UIColor clearColor].CGColor;
  _backgroundTimeMode.frame =
      CGRectMake(50, kCalendarHeaderHeight + kCalendarClockHeight +
                         (popupHolder.mdWidth - kCalendarClockHeight),
                 40, 40);
  _backgroundTimeMode.path =
      [UIBezierPath bezierPathWithOvalInRect:_backgroundTimeMode.bounds].CGPath;

  [self addSubview:popupHolder];
  [self setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.5]];
}

- (void)initHeaderView {
  _header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, popupHolder.mdWidth,
                                                     kCalendarHeaderHeight)];

  _headerLabelHour = [[UILabel alloc]
      initWithFrame:CGRectMake(0, 0, _header.mdWidth / 2, _header.mdHeight)];
  _headerLabelHour.font = [UIFontHelper robotoFontOfSize:43];
  _headerLabelHour.textAlignment = NSTextAlignmentRight;

  _headerLabelMinute = [[UILabel alloc]
      initWithFrame:CGRectMake(_header.mdWidth / 2, 0, _header.mdWidth / 2,
                               _header.mdHeight)];
  _headerLabelMinute.textAlignment = NSTextAlignmentLeft;
  _headerLabelMinute.font = [UIFontHelper robotoFontOfSize:43];

  [_header addSubview:_headerLabelHour];
  [_header addSubview:_headerLabelMinute];
  [popupHolder addSubview:_header];

  UITapGestureRecognizer *showClockHourSelectorGesture =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(showClockHour)];
  UITapGestureRecognizer *showClockMinuteSelectorGesture = [
      [UITapGestureRecognizer alloc] initWithTarget:self
                                             action:@selector(showClockMinute)];

  [_headerLabelHour addGestureRecognizer:showClockHourSelectorGesture];
  [_headerLabelHour setUserInteractionEnabled:YES];
  [_headerLabelMinute addGestureRecognizer:showClockMinuteSelectorGesture];
  [_headerLabelMinute setUserInteractionEnabled:YES];
}

- (void)initClock {
  // init hour clock
  _clockHour = [[UIView alloc]
      initWithFrame:CGRectMake(
                        (popupHolder.mdWidth - kCalendarClockHeight) / 2,
                        kCalendarHeaderHeight +
                            (popupHolder.mdWidth - kCalendarClockHeight) / 2,
                        kCalendarClockHeight, kCalendarClockHeight)];
  _clockHour.tag = 0;

  _backgroundClock = [[CAShapeLayer alloc] init];
  _backgroundClock.backgroundColor = [UIColor clearColor].CGColor;
  _backgroundClock.frame = _clockHour.frame;
  _backgroundClock.path =
      [UIBezierPath bezierPathWithOvalInRect:_backgroundClock.bounds].CGPath;
  [popupHolder.layer insertSublayer:_backgroundClock atIndex:0];

  _clockMinute = [[UIView alloc]
      initWithFrame:CGRectMake(
                        (popupHolder.mdWidth - kCalendarClockHeight) / 2,
                        kCalendarHeaderHeight +
                            (popupHolder.mdWidth - kCalendarClockHeight) / 2,
                        kCalendarClockHeight, kCalendarClockHeight)];
  _clockMinute.tag = 1;

  float x_point;
  float y_point;

  for (int i = 1; i < 13; i++) {
    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
    [bt setFrame:CGRectMake(0, 0, kHourItemSize, kHourItemSize)];
    [bt setTag:110 + 24 + i];

    [bt setBackgroundColor:[UIColor clearColor]];
    [bt.layer setCornerRadius:bt.mdWidth / 2];

    [bt.titleLabel setFont:[UIFontHelper robotoFontOfSize:15.0]];
    [bt setTitleColor:_titleColor forState:UIControlStateNormal];

    double stepAngle = 2 * M_PI / 12;
    x_point = _clockHour.mdWidth / 2 +
              sin(stepAngle * i) * (kCalendarClockHeight / 2 -
                                    kHourItemSize / 2 - kClockPadding);
    y_point = _clockHour.mdHeight / 2 -
              cos(stepAngle * i) * (kCalendarClockHeight / 2 -
                                    kHourItemSize / 2 - kClockPadding);

    if (i * 5 == 60) {
      [bt setTitle:@"00" forState:UIControlStateNormal];
    } else {
      [bt setTitle:[NSString stringWithFormat:@"%02d", 5 * i]
          forState:UIControlStateNormal];
    }
    [_clockMinute addSubview:bt];

    [bt setCenter:CGPointMake(x_point, y_point)];
    [bt addTarget:self
                  action:@selector(timeClicked:)
        forControlEvents:UIControlEventTouchUpInside];
    [bt.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self bringSubviewToFront:bt];
  }

  [_clockHour setBackgroundColor:[UIColor clearColor]];
  [_clockMinute setBackgroundColor:[UIColor clearColor]];

  [popupHolder addSubview:_clockHour];
  [popupHolder addSubview:_clockMinute];

  _clockHour.hidden = NO;
  _clockMinute.hidden = YES;
  visiblePanel = _clockHour.tag;
}

- (void)initClockHandView {
  _clockHandView = [[UIView alloc]
      initWithFrame:CGRectMake(
                        (popupHolder.mdWidth - kCalendarClockHeight) / 2,
                        kCalendarHeaderHeight +
                            (popupHolder.mdWidth - kCalendarClockHeight) / 2,
                        kCalendarClockHeight, kCalendarClockHeight)];
  [_clockHandView.layer setCornerRadius:5.0];
  [_clockHandView setBackgroundColor:[UIColor clearColor]];
  [popupHolder addSubview:_clockHandView];

  // Shape layer mask - visible index
  _maskVisibleIndexLayer = [CAShapeLayer layer];
  [_maskVisibleIndexLayer setFillRule:kCAFillRuleEvenOdd];
  [_maskVisibleIndexLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
  [_clockHandView.layer addSublayer:_maskVisibleIndexLayer];

  UIBezierPath *centerCirclePath = [UIBezierPath bezierPath];

  CGPoint centerCirclePoint =
      CGPointMake(_clockHandView.mdWidth / 2, _clockHandView.mdHeight / 2);
  centerCirclePath =
      [UIBezierPath bezierPathWithArcCenter:centerCirclePoint
                                     radius:kSmallCircleRadius
                                 startAngle:0
                                   endAngle:DEGREES_TO_RADIANS(360)
                                  clockwise:NO];

  [centerCirclePath moveToPoint:centerCirclePoint];
  CGPoint line_Point = CGPointMake(
      centerCirclePoint.x, centerCirclePoint.y - (kCalendarClockHeight) / 2 +
                               kMainCircleRadius * 2 + kClockPadding);
  [centerCirclePath addLineToPoint:line_Point];
  selectorCirclePath = [UIBezierPath
      bezierPathWithArcCenter:CGPointMake(line_Point.x,
                                          line_Point.y - (kMainCircleRadius))
                       radius:kMainCircleRadius
                   startAngle:0
                     endAngle:DEGREES_TO_RADIANS(360)
                    clockwise:NO];

  selectorMinCirclePath = [UIBezierPath
      bezierPathWithArcCenter:CGPointMake(line_Point.x,
                                          line_Point.y + (kMainCircleRadius))
                       radius:kMainCircleRadius
                   startAngle:0
                     endAngle:DEGREES_TO_RADIANS(360)
                    clockwise:NO];
  CGMutablePathRef combinedPath =
      CGPathCreateMutableCopy(selectorCirclePath.CGPath);
  CGPathAddPath(combinedPath, NULL, selectorMinCirclePath.CGPath);

  selectorCircleLayer = [CAShapeLayer layer];
  selectorCircleLayer.lineWidth = 1;
  selectorCircleLayer.opacity = 1.0f;

  // Small Circle Layer
  CAShapeLayer *centerCircleLayer = [CAShapeLayer layer];
  centerCircleLayer.path = centerCirclePath.CGPath;
  centerCircleLayer.lineWidth = 1.0f;
  centerCircleLayer.opacity = 1.0f;
  self.centerCircleLayer = centerCircleLayer;

  [_maskVisibleIndexLayer addSublayer:centerCircleLayer];
  [_maskVisibleIndexLayer addSublayer:selectorCircleLayer];

  // Shape layer mask - visible index
  _maskInvisibleIndexLayer = [CAShapeLayer layer];
  [_maskInvisibleIndexLayer setFillRule:kCAFillRuleEvenOdd];
  [_maskInvisibleIndexLayer setFillColor:[[UIColor colorWithHue:0.0f
                                                     saturation:0.0f
                                                     brightness:0.0f
                                                          alpha:0.9f] CGColor]];
  [_maskInvisibleIndexLayer setBackgroundColor:[[UIColor clearColor] CGColor]];

  UIBezierPath *centerInvisibleIndexCirclePath = [UIBezierPath bezierPath];

  CGPoint centerInvisibleIndexCirclePoint =
      CGPointMake(_clockHandView.mdWidth / 2, _clockHandView.mdHeight / 2);
  centerInvisibleIndexCirclePath =
      [UIBezierPath bezierPathWithArcCenter:centerInvisibleIndexCirclePoint
                                     radius:kSmallCircleRadius
                                 startAngle:0
                                   endAngle:DEGREES_TO_RADIANS(360)
                                  clockwise:NO];

  [centerInvisibleIndexCirclePath moveToPoint:centerInvisibleIndexCirclePoint];
  line_Point = CGPointMake(centerInvisibleIndexCirclePoint.x,
                           centerInvisibleIndexCirclePoint.y -
                               (kCalendarClockHeight) / 2 + kMainCircleRadius +
                               kClockPadding);
  [centerInvisibleIndexCirclePath addLineToPoint:line_Point];
  UIBezierPath *selectorInvisibleIndexCirclePath = [UIBezierPath
      bezierPathWithArcCenter:CGPointMake(line_Point.x, line_Point.y)
                       radius:kMainCircleRadius
                   startAngle:0
                     endAngle:DEGREES_TO_RADIANS(360)
                    clockwise:NO];
  CAShapeLayer *selectorInvisibleIndexCircleLayer = [CAShapeLayer layer];
  selectorInvisibleIndexCircleLayer.path =
      selectorInvisibleIndexCirclePath.CGPath;
  selectorInvisibleIndexCircleLayer.lineWidth = 0;
  selectorInvisibleIndexCircleLayer.opacity = 1.0f;
  self.selectorInvisibleIndexCircleLayer = selectorInvisibleIndexCircleLayer;

  // small circle layer in selector layer
  UIBezierPath *smallSelectorInvisibleIndexCirclePath = [UIBezierPath
      bezierPathWithArcCenter:CGPointMake(line_Point.x, line_Point.y)
                       radius:kSmallCircleRadius * 2
                   startAngle:0
                     endAngle:DEGREES_TO_RADIANS(360)
                    clockwise:NO];
  CAShapeLayer *smallInvisibleIndexCircleLayer = [CAShapeLayer layer];
  smallInvisibleIndexCircleLayer.path =
      smallSelectorInvisibleIndexCirclePath.CGPath;
  smallInvisibleIndexCircleLayer.lineWidth = 1.0f;
  smallInvisibleIndexCircleLayer.opacity = 1.0f;
  self.smallInvisibleIndexCircleLayer = smallInvisibleIndexCircleLayer;

  // Small Circle Layer
  CAShapeLayer *centerInvisibleIndexCircleLayer = [CAShapeLayer layer];
  centerInvisibleIndexCircleLayer.path = centerInvisibleIndexCirclePath.CGPath;
  centerInvisibleIndexCircleLayer.lineWidth = 1.0f;
  centerInvisibleIndexCircleLayer.opacity = 0.5f;
  self.centerInvisibleIndexCircleLayer = centerInvisibleIndexCircleLayer;

  [_maskInvisibleIndexLayer addSublayer:selectorInvisibleIndexCircleLayer];
  [_maskInvisibleIndexLayer addSublayer:centerInvisibleIndexCircleLayer];
  [_maskInvisibleIndexLayer addSublayer:smallInvisibleIndexCircleLayer];

  [_clockHandView.layer addSublayer:_maskInvisibleIndexLayer];

  _clockHandView.transform = CGAffineTransformMakeRotation(
      DEGREES_TO_RADIANS((_currentHour % 12) * 30));
  _clockHandView.backgroundColor = [UIColor clearColor];
  _clockHandView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)updateContent {
  [self updateClockHourPanel];
  [self updateClockHand];
  [self updateClockModePanel];
  [self updateHeaderView];
}

- (void)updateClockModePanel {
  if (_clockMode == MDClockMode12H) {
    [popupHolder.layer insertSublayer:_backgroundTimeMode
                              atIndex:(int)[popupHolder.layer.sublayers count]];

    [popupHolder addSubview:_labelTimeModeAM];
    [popupHolder addSubview:_labelTimeModePM];

    if (_currentHour < 12) {
      [self changeTimeModeAM];
    } else {
      [self changeTimeModePM];
    }

  } else {
    [_labelTimeModeAM removeFromSuperview];
    [_labelTimeModePM removeFromSuperview];
    [_backgroundTimeMode removeFromSuperlayer];
  }
}

- (void)updateClockHourPanel {
  double stepAngle = 2 * M_PI / 12;
  float x_point;
  float y_point;

  NSArray *viewsToRemove = [_clockHour subviews];
  for (UIView *v in viewsToRemove) {
    [v removeFromSuperview];
  }

  if (_clockMode == MDClockMode12H) {
    for (int i = 1; i < 13; i++) {
      UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
      [bt setFrame:CGRectMake(0, 0, kHourItemSize, kHourItemSize)];
      [bt setTag:(110 + i)];

      [bt setBackgroundColor:[UIColor clearColor]];
      [bt.layer setCornerRadius:bt.mdWidth / 2];

      [bt.titleLabel setFont:[UIFontHelper robotoFontOfSize:15.0]];
      x_point = _clockHour.mdWidth / 2 +
                sin(stepAngle * i) * (kCalendarClockHeight / 2 -
                                      kHourItemSize / 2 - kClockPadding);
      y_point = _clockHour.mdHeight / 2 -
                cos(stepAngle * i) * (kCalendarClockHeight / 2 -
                                      kHourItemSize / 2 - kClockPadding);

      [bt setTitle:[NSString stringWithFormat:@"%d", i]
          forState:UIControlStateNormal];
      [bt setTitleColor:_titleColor forState:UIControlStateNormal];
      [_clockHour addSubview:bt];

      [bt setCenter:CGPointMake(x_point, y_point)];
      [bt addTarget:self
                    action:@selector(timeClicked:)
          forControlEvents:UIControlEventTouchUpInside];
      [bt.titleLabel setTextAlignment:NSTextAlignmentCenter];
      [self bringSubviewToFront:bt];
    }
  } else {
    for (int i = 1; i < 25; i++) {
      UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
      [bt setFrame:CGRectMake(0, 0, kHourItemSize, kHourItemSize)];
      [bt setTag:(110 + i % 24)];

      [bt setBackgroundColor:[UIColor clearColor]];
      [bt.layer setCornerRadius:bt.mdWidth / 2];

      if (i < 13) {
        [bt.titleLabel setFont:[UIFontHelper robotoFontOfSize:15.0]];

        x_point =
            _clockHour.mdWidth / 2 +
            sin(stepAngle * i) * (kCalendarClockHeight / 2 - kHourItemSize -
                                  kHourItemSize / 2 - kClockPadding);
        y_point =
            _clockHour.mdHeight / 2 -
            cos(stepAngle * i) * (kCalendarClockHeight / 2 - kHourItemSize -
                                  kHourItemSize / 2 - kClockPadding);
      } else {
        [bt.titleLabel setFont:[UIFontHelper robotoFontOfSize:11.0]];

        x_point = _clockHour.mdWidth / 2 +
                  sin(stepAngle * i) * (kCalendarClockHeight / 2 -
                                        kHourItemSize / 2 - kClockPadding);
        y_point = _clockHour.mdHeight / 2 -
                  cos(stepAngle * i) * (kCalendarClockHeight / 2 -
                                        kHourItemSize / 2 - kClockPadding);
      }

      [bt setTitle:[NSString stringWithFormat:@"%d", (i % 24)]
          forState:UIControlStateNormal];
      [bt setTitleColor:_titleColor forState:UIControlStateNormal];
      [_clockHour addSubview:bt];

      [bt setCenter:CGPointMake(x_point, y_point)];
      [bt addTarget:self
                    action:@selector(timeClicked:)
          forControlEvents:UIControlEventTouchUpInside];
      [bt.titleLabel setTextAlignment:NSTextAlignmentCenter];
      [self bringSubviewToFront:bt];
    }
  }
}

- (void)updateHeaderView {
  if (_clockMode == MDClockMode12H) {
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]
        initWithString:[NSString stringWithFormat:@":%02d %@",
                                                  (int)_currentMinute,
                                                  [self timePeriods]]];

    [attString addAttribute:NSForegroundColorAttributeName
                      value:[UIColor whiteColor]
                      range:NSMakeRange(0, 3)];

    [attString addAttribute:NSFontAttributeName
                      value:[UIFontHelper robotoFontOfSize:43]
                      range:NSMakeRange(0, 3)];

    [attString addAttribute:NSFontAttributeName
                      value:[UIFontHelper robotoFontOfSize:15]
                      range:NSMakeRange(3, 3)];
    _headerLabelMinute.attributedText = attString;
  } else {
    _headerLabelMinute.text =
        [NSString stringWithFormat:@":%02d", (int)_currentMinute];
  }

  int hour = (int)_currentHour;
  if (_clockMode == MDClockMode12H) {
    hour %= 12;
    if (hour == 0)
      hour = 12;
  }
  _headerLabelHour.text = [NSString stringWithFormat:@"%02d", hour];

  if (visiblePanel == _clockHour.tag) {
    [_headerLabelHour
        setTextColor:[_headerLabelHour.textColor colorWithAlphaComponent:1]];
    [_headerLabelMinute setTextColor:[_headerLabelMinute.textColor
                                         colorWithAlphaComponent:0.5]];
  } else {
    [_headerLabelHour
        setTextColor:[_headerLabelHour.textColor colorWithAlphaComponent:0.5]];
    [_headerLabelMinute
        setTextColor:[_headerLabelMinute.textColor colorWithAlphaComponent:1]];
  }

  if (preHourTag != -1) {
    [((UIButton *)[_clockHour
        viewWithTag:preHourTag]) setTitleColor:_titleColor
                                      forState:UIControlStateNormal];
  }
  if (preMinuteTag != -1) {
    [((UIButton *)[_clockMinute
        viewWithTag:preMinuteTag]) setTitleColor:_titleColor
                                        forState:UIControlStateNormal];
  }

  [((UIButton *)[_clockHour
      viewWithTag:(hour + 110)]) setTitleColor:_titleSelectedColor
                                      forState:UIControlStateNormal];

  preHourTag = hour + 110;
  if (_currentMinute % 5 == 0) {
    int tag = (int)(_currentMinute == 0 ? (12 + 110 + 24)
                                        : _currentMinute / 5 + 110 + 24);
    preMinuteTag = tag;
    [((UIButton *)[_clockMinute
        viewWithTag:tag]) setTitleColor:_titleSelectedColor
                               forState:UIControlStateNormal];
  }
}

- (void)updateClockHand {
  if (visiblePanel == _clockHour.tag) {
    if ((_clockMode == MDClockMode24H) &&
        (0 < _currentHour & _currentHour <= 12)) {
      selectorCircleLayer.path = selectorMinCirclePath.CGPath;
    } else {
      selectorCircleLayer.path = selectorCirclePath.CGPath;
    }
    _maskInvisibleIndexLayer.hidden = YES;
    _maskVisibleIndexLayer.hidden = NO;
  } else {
    if (_currentMinute % 5 == 0) {
      _maskInvisibleIndexLayer.hidden = YES;
      _maskVisibleIndexLayer.hidden = NO;
    } else {
      _maskInvisibleIndexLayer.hidden = NO;
      _maskVisibleIndexLayer.hidden = YES;
    }
  }
}

- (void)layoutSubviews {
  [super layoutSubviews];

  UIView *rootView = [MDDeviceHelper getMainView];
  int vSpacing = rootView.bounds.size.height * 0.05;
  int hSpacing = rootView.bounds.size.width * 0.1;
  if ([[UIScreen mainScreen] bounds].size.width > 320) {
  } else {
    vSpacing /= 2;
    hSpacing /= 2;
  }

  [popupHolder
      setFrame:CGRectMake(hSpacing, vSpacing, self.mdWidth - 2 * hSpacing,
                          self.mdHeight - 2 * vSpacing)];

  UIInterfaceOrientation orientation =
      [[UIApplication sharedApplication] statusBarOrientation];
  switch (orientation) {
  case UIInterfaceOrientationPortrait:
  case UIInterfaceOrientationPortraitUpsideDown: {
    if (rootView.bounds.size.height < rootView.bounds.size.width) {
      self.frame = CGRectMake(0, 0, rootView.bounds.size.height,
                              rootView.bounds.size.width);
      [popupHolder
          setFrame:CGRectMake(hSpacing, vSpacing,
                              rootView.bounds.size.height - 2 * hSpacing,
                              rootView.bounds.size.width - 2 * vSpacing)];
    }
    // load the portrait view
    _header.frame =
        CGRectMake(0, 0, popupHolder.mdWidth, kCalendarHeaderHeight);
    _clockHour.center =
        CGPointMake((popupHolder.mdWidth - kCalendarClockHeight) / 2 +
                        kCalendarClockHeight / 2,
                    kCalendarHeaderHeight +
                        (popupHolder.mdHeight - kCalendarActionBarHeight -
                         kCalendarHeaderHeight - kCalendarClockHeight) /
                            2 -
                        15 + kCalendarClockHeight / 2);
  } break;

  case UIInterfaceOrientationLandscapeLeft:
  case UIInterfaceOrientationLandscapeRight: {
    if (rootView.bounds.size.height > rootView.bounds.size.width) {
      self.frame = CGRectMake(0, 0, rootView.bounds.size.height,
                              rootView.bounds.size.width);
      [popupHolder
          setFrame:CGRectMake(hSpacing, vSpacing,
                              rootView.bounds.size.height - 2 * hSpacing,
                              rootView.bounds.size.width - 2 * vSpacing)];
    }

    // load the landscape view
    float headerWidthRatio = 0.5;
    if ([[UIScreen mainScreen] bounds].size.width <= 320)
      headerWidthRatio = 0.4;
    _header.frame = CGRectMake(0, 0, popupHolder.mdWidth * headerWidthRatio,
                               popupHolder.mdHeight - kCalendarActionBarHeight);
    _clockHour.center =
        CGPointMake(popupHolder.mdWidth * headerWidthRatio +
                        (popupHolder.mdWidth * (1 - headerWidthRatio) -
                         kCalendarClockHeight) /
                            2 +
                        kCalendarClockHeight / 2,
                    (popupHolder.mdHeight - kCalendarActionBarHeight -
                     kCalendarClockHeight) /
                            2 +
                        kCalendarClockHeight / 2);

    if ([[UIScreen mainScreen] bounds].size.width <= 320) {
      _clockHour.center =
          CGPointMake(popupHolder.mdWidth * headerWidthRatio +
                          (popupHolder.mdWidth * (1 - headerWidthRatio) -
                           kCalendarClockHeight) /
                              2 +
                          kCalendarClockHeight / 2,
                      kCalendarClockHeight / 2 - 10);
    }

  } break;
  case UIInterfaceOrientationUnknown:
    break;
  }

  if ([[UIScreen mainScreen] bounds].size.width <= 320) {
    _headerLabelHour.frame =
        CGRectMake(0, 0, _header.mdWidth / 2 - 20, _header.mdHeight);
    _headerLabelMinute.frame = CGRectMake(
        _header.mdWidth / 2 - 20, 0, _header.mdWidth / 2, _header.mdHeight);
  } else {
    _headerLabelHour.frame =
        CGRectMake(0, 0, _header.mdWidth / 2, _header.mdHeight);
    _headerLabelMinute.frame = CGRectMake(
        _header.mdWidth / 2, 0, _header.mdWidth / 2, _header.mdHeight);
  }

  _clockMinute.center = _clockHour.center;
  _backgroundClock.frame = _clockHour.frame;
  _clockHandView.center = _clockHour.center;

  if (_clockMode == MDClockMode12H) {
    if ([[UIScreen mainScreen] bounds].size.width <= 320) {
      _labelTimeModeAM.center =
          CGPointMake(_clockHour.center.x - _clockHour.mdWidth / 2 + 15,
                      _clockHour.center.y + _clockHour.mdHeight / 2 + 3);
      _labelTimeModePM.center =
          CGPointMake(_clockHour.center.x + _clockHour.mdWidth / 2 - 15,
                      _clockHour.center.y + _clockHour.mdHeight / 2 + 3);
    } else {
      _labelTimeModeAM.center =
          CGPointMake(_clockHour.center.x - _clockHour.mdWidth / 2 + 15,
                      _clockHour.center.y + _clockHour.mdHeight / 2 + 15);
      _labelTimeModePM.center =
          CGPointMake(_clockHour.center.x + _clockHour.mdWidth / 2 - 15,
                      _clockHour.center.y + _clockHour.mdHeight / 2 + 15);
    }

    if (_currentHour < 12) {
      _backgroundTimeMode.frame = _labelTimeModeAM.frame;
    } else {
      _backgroundTimeMode.frame = _labelTimeModePM.frame;
    }
  }

  _buttonCancel.mdLeft = popupHolder.mdWidth - 4 * kCalendarActionBarHeight;
  _buttonCancel.mdTop = popupHolder.mdHeight - kCalendarActionBarHeight;
  _buttonOk.mdLeft = popupHolder.mdWidth - 2 * kCalendarActionBarHeight;
  _buttonOk.mdTop = popupHolder.mdHeight - kCalendarActionBarHeight;
}

#pragma mark Popup Handle

- (void)show {
  [self addSelfToMainWindow];
  self.hidden = NO;
  [self showClockHour];
}

- (void)addSelfToMainWindow {
  UIView *rootView = [MDDeviceHelper getMainView];
  [self setFrame:rootView.bounds];
  [rootView addSubview:self];
}

#pragma mark Clock Hand Actions
- (void)rotateHand:(UIView *)view rotationDegree:(float)degree {
  [UIView animateWithDuration:0.5
      delay:0
      options:UIViewAnimationOptionCurveEaseInOut
      animations:^{
        view.transform = CGAffineTransformMakeRotation((degree) * (M_PI / 180));
      }
      completion:^(BOOL finished) {
        if (!_clockHour.hidden) {
          [self showClockMinute];
        }
      }];
}

- (void)rotateHand:(UIPanGestureRecognizer *)recognizer {
  UIView *currentView;
  if (!_clockHour.hidden) {
    currentView = _clockHour;
  } else {
    currentView = _clockMinute;
  }

  // Ignore pan gesture on header area
  if (!CGRectContainsPoint(_header.bounds,
                           [recognizer locationInView:_header])) {
    CGPoint translation = [recognizer locationInView:currentView];

    if (_clockHour.hidden) {
      NSInteger minute = [self minuteFromTouchPoint:translation];
      if (_currentMinute != minute) {
        self.currentMinute = minute;
        float angle = ((int)(_currentMinute)) * 6;
        _clockHandView.transform =
            CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
        [self updateClockHand];
        [self updateHeaderView];
      }
    } else {
      NSInteger hour = [self hourFromTouchPoint:translation];
      if (_currentHour != hour) {
        self.currentHour = hour;
        float angle = (_currentHour % 12) * 30;
        _clockHandView.transform =
            CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
        [self updateClockHand];
        [self updateHeaderView];
      }
    }

    if (recognizer.state == UIGestureRecognizerStateEnded) {
      if (_clockMinute.hidden)
        [self showClockMinute];
    }
  }
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)sender {
  UIView *currentView;
  if (!_clockHour.hidden) {
    currentView = _clockHour;
  } else {
    currentView = _clockMinute;
  }
  CGPoint translation = [sender locationInView:currentView];

  float angle;
  if (_clockHour.hidden) {
    float minute = [self minuteFromTouchPoint:translation];
    if (_currentMinute != minute) {
      self.currentMinute = minute;
      angle = ((int)(_currentMinute)) * 6;
      [self rotateHand:_clockHandView rotationDegree:angle];
      [self updateClockHand];
      [self updateHeaderView];
    }
  } else {
    NSUInteger hours = [self hourFromTouchPoint:translation];

    if (_currentHour != hours) {
      self.currentHour = (int)hours;
      angle = (_currentHour % 12) * 30;
      [self rotateHand:_clockHandView rotationDegree:angle];
      [self updateClockHand];
      [self updateHeaderView];
    }
  }
}

- (void)timeClicked:(id)sender {
  UIButton *selectedButton = (UIButton *)sender;

  int tag = (int)selectedButton.tag;
  CGFloat degreesToRotate;
  if (!_clockHour.hidden) {
    self.currentHour = tag - 110;
    degreesToRotate = (_currentHour % 12) * 30;
    [self updateClockHand];

    if (preHourTag != -1) {
      [((UIButton *)[_clockHour
          viewWithTag:preHourTag]) setTitleColor:_titleColor
                                        forState:UIControlStateNormal];
    }

    preHourTag = tag;
  } else {
    self.currentMinute = (tag - 110 - 24) * 5;
    degreesToRotate = (_currentMinute / 5) * 30;
    if (preMinuteTag != -1) {
      [((UIButton *)[_clockMinute
          viewWithTag:preMinuteTag]) setTitleColor:_titleColor
                                          forState:UIControlStateNormal];
    }

    preMinuteTag = tag;
  }

  [self rotateHand:_clockHandView rotationDegree:degreesToRotate];
  [self updateClockHand];
  [self updateHeaderView];
}

- (NSInteger)minuteFromTouchPoint:(CGPoint)touchPoint {
  float minutesFloat = (atan2f((touchPoint.x - _clockMinute.mdHeight / 2),
                               (touchPoint.y - _clockMinute.mdWidth / 2)) *
                            -(180 / M_PI) +
                        180) /
                       6;
  float roundedUp = lroundf(minutesFloat);
  if (roundedUp == 60)
    roundedUp = 00;
  return roundedUp;
}

- (NSInteger)hourFromTouchPoint:(CGPoint)touchPoint {
  NSUInteger hour = (atan2f((touchPoint.x - _clockHour.mdHeight / 2),
                            (touchPoint.y - _clockHour.mdWidth / 2)) *
                         -(180 / M_PI) +
                     180 + 15) /
                    30;

  float r = sqrtf(powf(_clockHour.mdWidth / 2 - touchPoint.x, 2) +
                  powf(_clockHour.mdHeight / 2 - touchPoint.y, 2));

  if (_clockMode == MDClockMode24H) {
    if (hour == 0)
      hour = 12;
    if (r > _clockHour.mdHeight / 2 - kHourItemSize - kClockPadding) {
      hour += 12;
      if (hour == 24)
        hour = 0;
    }
  } else {
    hour %= 12;
    if (_currentHour >= 12) {
      hour += 12;
      if (hour == 24)
        hour = 0;
    }
  }

  return hour;
}

- (NSString *)timePeriods {
  if (_currentHour < 12)
    return @"AM";
  else
    return @"PM";
}

#pragma mark Delegate & Actions

- (void)setTitleOk:(nonnull NSString *)okTitle
    andTitleCancel:(nonnull NSString *)cancelTitle {
  _okTitle = okTitle;
  _cancelTitle = cancelTitle;

  [_buttonOk setTitle:_okTitle forState:UIControlStateNormal];
  [_buttonCancel setTitle:_cancelTitle forState:UIControlStateNormal];
}

- (void)changeTimeModeAM {
  if (_currentHour >= 12)
    _currentHour -= 12;
  _backgroundTimeMode.frame = _labelTimeModeAM.frame;
  [self updateHeaderView];
}
- (void)changeTimeModePM {
  if (_currentHour < 12)
    _currentHour += 12;
  _backgroundTimeMode.frame = _labelTimeModePM.frame;
  [self updateHeaderView];
}

- (void)showClockHour {
  if (animating)
    return;
  if (_clockHour.hidden) {
    animating = YES;
    _clockHour.hidden = NO;
    visiblePanel = _clockHour.tag;
    _clockHour.alpha = 0.0;
    _clockHour.transform =
        CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
    [UIView animateWithDuration:0.3 / 1.5
        animations:^{
          _clockHour.alpha = 0.2;
          _clockHour.transform =
              CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 0.95);
          [self updateClockHand];
          [self updateHeaderView];
          _clockHandView.transform = CGAffineTransformMakeRotation(
              DEGREES_TO_RADIANS(_currentHour * 30));
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:0.3 / 2
              animations:^{
                _clockHour.transform =
                    CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                _clockHour.alpha = 1.0;
              }
              completion:^(BOOL finished) {
                [UIView animateWithDuration:0.6 / 2
                                 animations:^{
                                   _clockHour.transform =
                                       CGAffineTransformIdentity;
                                   animating = NO;
                                 }
                                 completion:nil];
              }];
        }];
    _clockMinute.transform =
        CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    _clockMinute.alpha = 0.2;
    [UIView animateWithDuration:0.3 / 2
        animations:^{
          _clockMinute.transform =
              CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:0.3 / 2
                           animations:^{
                             _clockMinute.alpha = 0.0;
                             _clockMinute.transform = CGAffineTransformIdentity;
                             _clockMinute.hidden = YES;
                           }];
        }];

    [self updateClockHand];
  }
}

- (void)showClockMinute {
  if (animating)
    return;
  if (!_clockHour.hidden) {
    animating = YES;
    _clockMinute.alpha = 0.0;
    _clockMinute.hidden = NO;
    visiblePanel = _clockMinute.tag;
    _clockMinute.transform =
        CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);

    [UIView animateWithDuration:0.3 / 1.5
        animations:^{
          _clockMinute.alpha = 0.2;
          _clockMinute.transform =
              CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 0.95);
          [self updateClockHand];
          [self updateHeaderView];
          _clockHandView.transform = CGAffineTransformMakeRotation(
              DEGREES_TO_RADIANS(_currentMinute / 5 * 30));
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:0.3 / 2
              animations:^{
                _clockMinute.transform =
                    CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                _clockMinute.alpha = 1.0;
              }
              completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3 / 2
                                 animations:^{
                                   _clockMinute.transform =
                                       CGAffineTransformIdentity;
                                   animating = NO;
                                 }
                                 completion:nil];
              }];
        }];
    _clockHour.transform =
        CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    _clockHour.alpha = 0.2;
    [UIView animateWithDuration:0.3 / 2
        animations:^{
          _clockHour.transform =
              CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:0.3 / 2
                           animations:^{
                             _clockHour.transform = CGAffineTransformIdentity;
                             _clockHour.hidden = YES;
                             _clockHour.alpha = 0.0;
                           }];
        }];

    selectorCircleLayer.path = selectorCirclePath.CGPath;
  }
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
  UIInterfaceOrientation orientation =
      [[UIApplication sharedApplication] statusBarOrientation];
  UIView *view = [MDDeviceHelper getMainView];
  switch (orientation) {
  case UIInterfaceOrientationPortrait:
  case UIInterfaceOrientationPortraitUpsideDown:
  case UIInterfaceOrientationLandscapeLeft:
  case UIInterfaceOrientationLandscapeRight: {
    self.frame =
        CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
  } break;
  case UIInterfaceOrientationUnknown:
    break;
  }
}

- (void)didSelect {
  if (_delegate &&
      [_delegate respondsToSelector:@selector(timePickerDialog:
                                                 didSelectHour:
                                                     andMinute:)]) {
    [_delegate timePickerDialog:self
                  didSelectHour:_currentHour
                      andMinute:_currentMinute];
  }

  [self removeFromSuperview];
}

- (void)didCancel {
  [self removeFromSuperview];
}
@end