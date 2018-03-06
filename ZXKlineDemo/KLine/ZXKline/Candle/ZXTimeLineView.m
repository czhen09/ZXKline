//
//  ZXTimeLineView.m
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/8/28.
//  Copyright © 2017年 郑旭. All rights reserved.
//
#import "ZXTimeLineView.h"
#import "ZXHeader.h"
#import <Masonry.h>
@interface ZXTimeLineView()
@property (nonatomic,assign) UIInterfaceOrientation orientation;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) CAShapeLayer *vereticalTopLineLayer;
@property (nonatomic,strong) CAShapeLayer *vereticalBottomLineLayer;
@property (nonatomic,assign) CGFloat candleChartHeight;
@property (nonatomic,assign) CGFloat quotaChartHeight;
@property (nonatomic,assign) CGFloat middleBlankSpace;
@end

@implementation ZXTimeLineView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self = [super init];
        [self creatUI];
        //监测旋转
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)creatUI
{
    [self creatVerticalLineWithCandleHeight:self.candleChartHeight];
    [self addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(self.candleChartHeight+(TimeViewHeight-14)/2);
        make.height.mas_equalTo(14);
        make.centerX.mas_equalTo(self);
    }];
    self.timeLabel.text = @"00:00";
}
- (void)creatVerticalLineWithCandleHeight:(CGFloat)candleChartHeight
{
    [self.vereticalTopLineLayer removeFromSuperlayer];
    self.vereticalTopLineLayer = nil;
    self.vereticalTopLineLayer = [CAShapeLayer layer];
    UIBezierPath *topLine = [UIBezierPath bezierPath];
    [topLine moveToPoint:CGPointMake(0,0)];
    [topLine addLineToPoint:CGPointMake(0,candleChartHeight)];
    self.vereticalTopLineLayer.lineWidth = 0.5;
    self.vereticalTopLineLayer.path = topLine.CGPath;
    self.vereticalTopLineLayer.strokeColor = CoordinateDisPlayLabelColor.CGColor;
    [self.layer addSublayer:self.vereticalTopLineLayer];
    

    
    [self.vereticalBottomLineLayer removeFromSuperlayer];
    self.vereticalBottomLineLayer = nil;
    self.vereticalBottomLineLayer = [CAShapeLayer layer];
    UIBezierPath *bottomLine = [UIBezierPath bezierPath];
    [bottomLine moveToPoint:CGPointMake(0,candleChartHeight+self.middleBlankSpace+TimeViewHeight)];
    [bottomLine addLineToPoint:CGPointMake(0,candleChartHeight+self.middleBlankSpace+TimeViewHeight+self.quotaChartHeight)];
    self.vereticalBottomLineLayer.lineWidth = 0.5;
    self.vereticalBottomLineLayer.path = bottomLine.CGPath;
    self.vereticalBottomLineLayer.strokeColor = CoordinateDisPlayLabelColor.CGColor;
    [self.layer addSublayer:self.vereticalBottomLineLayer];
}

#pragma mark - PublicMethods
- (void)updateTimeWithTimeString:(NSString *)timeString
{
    self.timeLabel.text = timeString;
}
- (void)updateFrameWhenCandleFullScreenWithCandleHeight:(CGFloat)candleChartHeight
{
    //翻转为竖屏时
    [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self).offset(candleChartHeight+(TimeViewHeight-14)/2);
    }];
    [self creatVerticalLineWithCandleHeight:candleChartHeight];
}
#pragma mark - 旋转事件
- (void)statusBarOrientationChange:(NSNotification *)notification
{
    
    self.orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (self.orientation == UIDeviceOrientationPortrait || self.orientation == UIDeviceOrientationPortraitUpsideDown) {
        
        //翻转为竖屏时
        [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(self).offset(self.candleChartHeight+(TimeViewHeight-14)/2);
        }];
        [self creatVerticalLineWithCandleHeight:self.candleChartHeight];
        
    }
    if (self.orientation==UIDeviceOrientationLandscapeLeft || self.orientation == UIDeviceOrientationLandscapeRight) {
        
        [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(self).offset(self.candleChartHeight+(TimeViewHeight-14)/2);
        }];
        [self creatVerticalLineWithCandleHeight:self.candleChartHeight];
    }
}
- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:FontSize];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.backgroundColor = CoordinateDisPlayLabelColor;
    }
    return _timeLabel;
}
- (UIInterfaceOrientation)orientation
{
    return [[UIApplication sharedApplication] statusBarOrientation];
}
- (CGFloat)candleChartHeight
{

    return CandleChartHeight;
}
- (CGFloat)quotaChartHeight
{
    return QuotaChartHeight;
}
- (CGFloat)middleBlankSpace
{

    return MiddleBlankSpace;
}
@end
