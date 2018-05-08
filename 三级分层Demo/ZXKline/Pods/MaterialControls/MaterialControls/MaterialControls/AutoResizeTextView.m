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

#import "AutoResizeTextView.h"
#import "MDTextField.h"

@implementation AutoResizeTextView {
  UILabel *placeholderLabel;
  int numLines;
  BOOL settingText;
}

- (instancetype)init {
  self = [super init];
  if (self) {

    placeholderLabel = [[UILabel alloc] init];
    [placeholderLabel setTextColor:[UIColor grayColor]];
    [self addSubview:placeholderLabel];

    self.textContainerInset = UIEdgeInsetsZero;
    self.textContainer.lineFragmentPadding = 0;
    [self setScrollEnabled:NO];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(textViewDidChangeWithNotification:)
               name:UITextViewTextDidChangeNotification
             object:self];
    numLines = -1;
  }
  return self;
}

#pragma mark setters

- (void)setTintColor:(UIColor *)tintColor {
  [super setTintColor:tintColor];

  if ([self isFirstResponder]) {
    [self resignFirstResponder];
    [self becomeFirstResponder];
  }
}

- (CGRect)caretRectForPosition:(UITextPosition *)position {
  CGRect caretRect = [super caretRectForPosition:position];
  caretRect.size.width = 1;
  return caretRect;
}

- (void)setPlaceholder:(NSString *)placeholder {
  _placeholder = placeholder;
  [placeholderLabel setText:_placeholder];
}

- (void)setFont:(UIFont *)font {
  [super setFont:font];
  [placeholderLabel setFont:font];
  [self calculateTextViewHeight];
  UIEdgeInsets textContainerInsets = self.textContainerInset;
  [placeholderLabel
      setFrame:CGRectMake(0, textContainerInsets.top, self.frame.size.width,
                          placeholderLabel.font.lineHeight)];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
  _placeholderColor = placeholderColor;
  [placeholderLabel setTextColor:_placeholderColor];
}

- (void)setMinVisibleLines:(NSInteger)minVisibleLines {
  _minVisibleLines = minVisibleLines;
  [self calculateTextViewHeight];
}

- (void)setMaxVisibleLines:(NSInteger)maxVisibleLines {
  _maxVisibleLines = maxVisibleLines;
  [self calculateTextViewHeight];
}

- (void)setMaxHeight:(float)maxHeight {
  if (_maxHeight != maxHeight) {
    _maxHeight = maxHeight;
    [self calculateTextViewHeight];
  }
}

#pragma mark private methods

- (void)layoutSubviews {
  [super layoutSubviews];
  [placeholderLabel
      setFrame:CGRectMake(0, self.textContainerInset.top, self.frame.size.width,
                          placeholderLabel.font.lineHeight)];
}

- (void)textViewDidChangeWithNotification:(NSNotification *)notification {
  if (notification.object == self && !settingText) {
    if (self.text.length >= 1) {
      placeholderLabel.hidden = YES;
    } else {
      placeholderLabel.hidden = NO;
    }
    [self calculateTextViewHeight];
  }
}

- (void)setText:(NSString *)text {
  settingText = YES;
  [super setText:text];
  settingText = NO;
  if (self.text.length >= 1) {
    placeholderLabel.hidden = YES;
  } else {
    placeholderLabel.hidden = NO;
  }
  [self calculateTextViewHeight];
}

- (CGFloat)intrinsicContentHeight {
  if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
    CGRect frame = self.bounds;
    UIEdgeInsets textContainerInsets = self.textContainerInset;
    UIEdgeInsets contentInsets = self.contentInset;

    CGFloat leftRightPadding = textContainerInsets.left +
                               textContainerInsets.right +
                               self.textContainer.lineFragmentPadding * 2 +
                               contentInsets.left + contentInsets.right;
    CGFloat topBottomPadding = textContainerInsets.top +
                               textContainerInsets.bottom + contentInsets.top +
                               contentInsets.bottom;

    frame.size.width -= leftRightPadding;
    frame.size.height -= topBottomPadding;

    NSString *textToMeasure = self.text;
    if ([textToMeasure hasSuffix:@"\n"]) {
      textToMeasure = [NSString stringWithFormat:@"%@-", self.text];
    }
    NSMutableParagraphStyle *paragraphStyle =
        [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    NSDictionary *attributes = @{
      NSFontAttributeName : self.font,
      NSParagraphStyleAttributeName : paragraphStyle
    };
    CGRect size = [textToMeasure
        boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                     options:NSStringDrawingUsesLineFragmentOrigin
                  attributes:attributes
                     context:nil];

    CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding);
    return measuredHeight;
  } else {
    return self.contentSize.height;
  }
}

- (void)calculateTextViewHeight {
  CGFloat contentHeight = [self intrinsicContentHeight];
  int lastNumLine = numLines;
  numLines = contentHeight / self.font.lineHeight;
  float minHeight = _minVisibleLines * self.font.lineHeight;

  float visibleHeight = minHeight > contentHeight ? minHeight : contentHeight;
  self.contentSize = CGSizeMake(self.contentSize.width, contentHeight);

  if (_maxVisibleLines <= 0 && _maxHeight <= 0) {
    if (visibleHeight != self.frame.size.height) {
      _holder.textViewHeightConstraint.constant = visibleHeight;
    }
  } else if (_maxHeight <= 0) { // _maxVisibleLines > 0
    if ((lastNumLine <= _maxVisibleLines) && (numLines > _maxVisibleLines)) {
      self.scrollEnabled = YES;
      [self scrollToCaret];
    } else if ((lastNumLine > _maxVisibleLines) &&
               (numLines <= _maxVisibleLines)) {
      [self setScrollEnabled:NO];
      _holder.textViewHeightConstraint.constant = visibleHeight;
    } else if (numLines > _maxVisibleLines) {
      [self scrollToCaret];
    } else if (visibleHeight != self.frame.size.height) {
      _holder.textViewHeightConstraint.constant = visibleHeight;
    }
  } else {
    float maxHeight = _maxHeight;
    if (_maxVisibleLines > 0) {
      float maxVisibleHeight = _maxVisibleLines * self.font.lineHeight;
      if (maxVisibleHeight < maxHeight)
        maxHeight = maxVisibleHeight;
    }
    if (maxHeight < self.font.lineHeight)
      maxHeight = self.font.lineHeight;

    if (minHeight > maxHeight)
      minHeight = maxHeight;
    visibleHeight = minHeight > contentHeight ? minHeight : contentHeight;
    if (maxHeight < visibleHeight) {
      self.scrollEnabled = YES;
      _holder.textViewHeightConstraint.constant = maxHeight;
      [self scrollToCaret];
    } else {
      self.scrollEnabled = NO;

      _holder.textViewHeightConstraint.constant = visibleHeight;
    }
  }
}

- (void)scrollToCaret {
  CGPoint bottomOffset =
      CGPointMake(0, self.contentSize.height - self.bounds.size.height);
  [self setContentOffset:bottomOffset animated:NO];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
