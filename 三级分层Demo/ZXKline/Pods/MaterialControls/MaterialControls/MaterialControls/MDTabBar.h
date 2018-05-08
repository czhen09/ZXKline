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

#import <UIKit/UIKit.h>

#define kMDTabBarHeight 48
#define kMDIndicatorHeight 2

@class MDTabBar;

NS_ASSUME_NONNULL_BEGIN
@protocol MDTabBarDelegate <NSObject>
- (void)tabBar:(MDTabBar *)tabBar
    didChangeSelectedIndex:(NSUInteger)selectedIndex;
@end

IB_DESIGNABLE
@interface MDTabBar : UIView

/// selected text color
@property(null_unspecified, nonatomic) IBInspectable UIColor *textColor;
/// normal (not selected) text color
@property(null_unspecified, nonatomic) IBInspectable UIColor *normalTextColor;
@property(null_unspecified, nonatomic) IBInspectable UIColor *backgroundColor;
@property(null_unspecified, nonatomic) IBInspectable UIColor *indicatorColor;
@property(null_unspecified, nonatomic) IBInspectable UIColor *rippleColor;

/// selected font
@property(nullable, nonatomic) UIFont *textFont;
/// normal (not selected) font
@property(nullable, nonatomic) UIFont *normalTextFont;

/// inset from the side (default: 8)
@property(nonatomic, assign) CGFloat horizontalInset;

/// padding for each item in tab bar (default: iPhone=12, iPad=24) Values <4 can cause labels to be truncated
@property(nonatomic, assign) CGFloat horizontalPaddingPerItem;

@property(nonatomic) NSUInteger selectedIndex;
@property(nonatomic, weak) id<MDTabBarDelegate> delegate;
@property(nonatomic, readonly) NSInteger numberOfItems;

- (void)setItems:(NSArray <id>*)items;

- (void)insertItem:(id)item atIndex:(NSUInteger)index animated:(BOOL)animated;

- (void)removeItemAtIndex:(NSUInteger)index animated:(BOOL)animated;

- (void)replaceItem:(id)item atIndex:(NSUInteger)index;

- (NSArray <UIView*>*)tabs;

- (void)moveIndicatorToFrame:(CGRect)frame withAnimated:(BOOL)animated;

@end
NS_ASSUME_NONNULL_END
