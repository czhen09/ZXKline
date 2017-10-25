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

#import "UIColorHelper.h"

@implementation UIColorHelper
+ (UIColor *)colorWithRGBA:(NSString *)rgba {
  float red = 0.0;
  float green = 0.0;
  float blue = 0.0;
  float alpha = 1.0;

  if ([rgba hasPrefix:@"#"]) {
    NSString *hex = [rgba substringFromIndex:1];
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    unsigned long long hexValue = 0;
    if ([scanner scanHexLongLong:&hexValue]) {
      switch (hex.length) {
      case 3:
        red = ((hexValue & 0xF00) >> 8) / 15.0;
        green = ((hexValue & 0x0F0) >> 4) / 15.0;
        blue = (hexValue & 0x00F) / 15.0;
        break;
      case 4:
        red = ((hexValue & 0xF000) >> 12) / 15.0;
        green = ((hexValue & 0x0F00) >> 8) / 15.0;
        blue = ((hexValue & 0x00F0) >> 4) / 15.0;
        alpha = (hexValue & 0x000F) / 15.0;
        break;
      case 6:
        red = ((hexValue & 0xFF0000) >> 16) / 255.0;
        green = ((hexValue & 0x00FF00) >> 8) / 255.0;
        blue = (hexValue & 0x0000FF) / 255.0;
        break;
      case 8:
        red = ((hexValue & 0xFF000000) >> 24) / 255.0;
        green = ((hexValue & 0x00FF0000) >> 16) / 255.0;
        blue = ((hexValue & 0x0000FF00) >> 8) / 255.0;
        alpha = (hexValue & 0x000000FF) / 255.0;
        break;
      default:
        NSLog(
            @"Invalid RGB string: '%@', number of characters after '#' should "
            @"be " @"either 3, 4, 6 or 8",
            rgba);
      }
    } else {
      NSLog(@"Scan hex error");
    }
  } else {
    NSLog(@"Invalid RGB string: '%@', missing '#' as prefix", rgba);
  }

  return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)colorFromRGB:(NSString *)rgb withAlpha:(float)alpha {
  return [[UIColorHelper colorWithRGBA:rgb] colorWithAlphaComponent:alpha];
}
@end
