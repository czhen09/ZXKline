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

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@protocol MDLayerDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface MDRippleLayer : CALayer

/*!
 * @brief layer delegate
 */
@property(nonatomic) id<MDLayerDelegate> layerDelegate;
/*!
 * @brief enable ripple effect or not
 */
@property(nonatomic) BOOL enableRipple;
/*!
 * @brief enable elevation effect or not
 */
@property(nonatomic) BOOL enableElevation;
/*!
 * @brief change display area of the effects, if value is YES , effects will
 * only display the path inside superview's layer background bounds
 */
@property(nonatomic) BOOL enableMask;

/*!
 * @brief Resting elevation value of the view in which this layer will be
 * added.
 */
@property(nonatomic) CGFloat restingElevation;

/*!
 * @brief Scale ratio of the ripple effect, if it's value = 1, the ripple effect
 * will cover entire view's bounds
 */
@property(nonatomic) CGFloat rippleScaleRatio;

/*!
 * @brief Speed of the ripple effect, points per second
 */
@property(nonatomic) CGFloat effectSpeed;

/*!
 * @brief Base color for effects. By default, ripple effect has the same color
 * as the effectColor with 50% alpha component, background color will have 30%
 * alpha component
 */
@property(null_unspecified, nonatomic) UIColor *effectColor;

- (instancetype)initWithSuperLayer:(CALayer *)superLayer;
- (instancetype)initWithSuperView:(UIView *)superView;

/*!
 * @discussion Set color for effects with custom alpha components
 * @param color the base color of effects
 * @param rippleAlpha opacity value for ripple color
 * @param backgroundAlpha opacity value for background effect color
 */
- (void)setEffectColor:(UIColor *)color
       withRippleAlpha:(CGFloat)rippleAlpha
       backgroundAlpha:(CGFloat)backgroundAlpha;

- (void)startEffectsAtLocation:(CGPoint)touchLocation;
- (void)stopEffectsImmediately;
- (void)stopEffects;

@end

@protocol MDLayerDelegate <NSObject>
@optional
- (void)mdLayer:(MDRippleLayer *)layer didFinishEffect:(CFTimeInterval)duration;
@end
NS_ASSUME_NONNULL_END
