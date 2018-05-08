//
//  ZXRippleLayer.m
//  ZXKlineDemo
//
//  Created by 郑旭 on 2018/4/27.
//  Copyright © 2018年 郑旭. All rights reserved.
//

#import "ZXRippleLayer.h"
@interface ZXRippleLayer()
@property (nonatomic,strong) CAShapeLayer  *rippleLayer;
@property (nonatomic,strong) CAShapeLayer  *circleLayer;
@property (nonatomic,strong) UIBezierPath  *initialPath;
//@property (nonatomic,strong) NSTimer  *timer;
@property (nonatomic,assign) CGRect ovalRect;
@end
@implementation ZXRippleLayer
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.frame = frame;
        [self addSublayer:self.circleLayer];
//        self.timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(addRippleLayerAnimation) userInfo:nil repeats:YES];
        [self addRippleLayerAnimation];
//        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    return self;
}
- (void)addRippleLayerAnimation
{

    [self removeRippleLayer:self.rippleLayer];
    [self addSublayer:self.rippleLayer];
    
    //扩展半径
    CGFloat extendRadius = -6.0;
    
    
    //addRippleAnimation
    //控制初始半径
    UIBezierPath *beginPath = [UIBezierPath bezierPathWithOvalInRect:self.ovalRect];
    //控制扩散半径
    CGRect endRect = CGRectInset(self.ovalRect, extendRadius, extendRadius);
    UIBezierPath *endPath = [UIBezierPath bezierPathWithOvalInRect:endRect];
    
    self.rippleLayer.path = endPath.CGPath;
    self.rippleLayer.opacity = 0.2;
    
    CABasicAnimation *rippleAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    rippleAnimation.fromValue = (__bridge id _Nullable)(beginPath.CGPath);
    rippleAnimation.toValue = (__bridge id _Nullable)(endPath.CGPath);
    rippleAnimation.duration = 1.0;
    
    //    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    //    opacityAnimation.fromValue = [NSNumber numberWithFloat:0.6];
    //    opacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
    //    opacityAnimation.duration = 2.0;
    //
    //    [rippleLayer addAnimation:opacityAnimation forKey:@""];
    [self.rippleLayer addAnimation:rippleAnimation forKey:@""];

}
- (void)removeRippleLayer:(CAShapeLayer *)rippleLayer
{
    if (rippleLayer) {
        [rippleLayer removeFromSuperlayer];
        rippleLayer = nil;
    }
}

#pragma mark - Getters & Setters
- (CAShapeLayer *)circleLayer
{
    if (!_circleLayer) {
        //原点
        _circleLayer = [[CAShapeLayer alloc] init];
        _circleLayer.frame = self.ovalRect;
        _circleLayer.backgroundColor = [UIColor clearColor].CGColor;
        _circleLayer.path = self.initialPath.CGPath;
        _circleLayer.strokeColor = [UIColor clearColor].CGColor;
        _circleLayer.lineWidth = 1;
        _circleLayer.fillColor = [UIColor colorWithRed:106/255.0 green:231/255.0 blue:252/255.0 alpha:1].CGColor;
    }
    return _circleLayer;
}
- (UIBezierPath *)initialPath
{
    if (!_initialPath) {
        _initialPath = [UIBezierPath bezierPathWithOvalInRect:self.ovalRect];
    }
    return _initialPath;
}
- (CAShapeLayer *)rippleLayer
{
    if (!_rippleLayer){
        _rippleLayer = [[CAShapeLayer alloc] init];
        _rippleLayer.frame = self.ovalRect;
        _rippleLayer.backgroundColor = [UIColor clearColor].CGColor;
        _rippleLayer.path = self.initialPath.CGPath;
        _rippleLayer.strokeColor = [UIColor clearColor].CGColor;
        _rippleLayer.lineWidth = 1;
        _rippleLayer.fillColor = [UIColor colorWithRed:106/255.0 green:231/255.0 blue:252/255.0 alpha:1].CGColor;
    }
    return _rippleLayer;
}
- (CGRect)ovalRect
{
    return CGRectMake(0, 0, 4, 4);
}
@end
