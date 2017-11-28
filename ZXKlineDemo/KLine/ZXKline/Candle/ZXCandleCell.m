//
//  ZXTestCell.m
//  LandscapeTableviewAndKLine
//
//  Created by 郑旭 on 2017/7/17.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ZXCandleCell.h"
#import "ZXHeader.h"
#import <Masonry.h>




@interface ZXCandleCell()
@property (nonatomic,strong) UIBezierPath *bezierPath;
@property (nonatomic,strong) CAShapeLayer *shapeLayer;
@property (nonatomic,strong) CAShapeLayer *topLayer;
@property (nonatomic,strong) CAShapeLayer *bottomLayer;
@property (nonatomic,strong) NSMutableArray *dottedLayerArr;


//竖直虚线
@property (nonatomic,strong) CAShapeLayer *vertivalTopDottedLayer;
@property (nonatomic,strong) CAShapeLayer *vertivalBottomDottedLayer;

@property (nonatomic,strong) UILabel *timeLabel;


/**
 *横竖屏方向
 */
@property (nonatomic,assign) UIInterfaceOrientation orientation;
@end
@implementation ZXCandleCell
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self addTimeLabel];
    
}
- (void)layoutSubviews
{
    [self.contentView removeFromSuperview];
    [self drawLine];
    
}
- (void)addTimeLabel
{
    [self bringSubviewToFront:self.timeLabel];
    CGFloat height = 60;
    CGFloat leftSpace = 0;
    leftSpace = -(height-TimeViewHeight)/2+(MiddleBlankSpace+QuotaChartHeight-2);
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(TimeViewHeight);
        make.width.mas_equalTo(height);
        make.top.mas_equalTo(self).offset((height-TimeViewHeight)/2+self.frame.size.height/2);
        make.left.mas_equalTo(self).offset(leftSpace);
    }];
    self.timeLabel.transform = CGAffineTransformMakeRotation(M_PI/2);
}

- (void)drawLine
{
    
    if (self.isDrawDottedLine) {
        
        //上部分
        [self.vertivalTopDottedLayer removeFromSuperlayer];
        self.vertivalTopDottedLayer = nil;
        self.vertivalTopDottedLayer = [CAShapeLayer layer];
        UIBezierPath *dottedLine = [UIBezierPath bezierPath];
        [dottedLine moveToPoint:CGPointMake(self.quotaChartHeight+self.middleBlankSpace+TimeViewHeight-4,self.frame.size.height/2)];
        [dottedLine addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height/2)];
//        self.vertivalTopDottedLayer.lineDashPattern = @[@4, @2];
        self.vertivalTopDottedLayer.lineWidth = 0.5;
        self.vertivalTopDottedLayer.path = dottedLine.CGPath;
        self.vertivalTopDottedLayer.strokeColor = GrateLineColor.CGColor;
        [self.layer addSublayer:self.vertivalTopDottedLayer];
        
        
        //下部分
        [self.vertivalBottomDottedLayer removeFromSuperlayer];
        self.vertivalBottomDottedLayer = nil;
        self.vertivalBottomDottedLayer = [CAShapeLayer layer];
        UIBezierPath *dottedBottomLine = [UIBezierPath bezierPath];
        [dottedBottomLine moveToPoint:CGPointMake(0,self.frame.size.height/2)];
        [dottedBottomLine addLineToPoint:CGPointMake(self.quotaChartHeight, self.frame.size.height/2)];
//        self.vertivalBottomDottedLayer.lineDashPattern = @[@4, @2];
        self.vertivalBottomDottedLayer.lineWidth = 0.5;
        self.vertivalBottomDottedLayer.path = dottedBottomLine.CGPath;
        self.vertivalBottomDottedLayer.strokeColor = GrateLineColor.CGColor;
        [self.layer addSublayer:self.vertivalBottomDottedLayer];
        
        
        
        
        
        self.timeLabel.text = self.model.timeStr;
        self.timeLabel.hidden = NO;
    }else{
        
        [self.vertivalTopDottedLayer removeFromSuperlayer];
        self.vertivalTopDottedLayer = nil;
        [self.vertivalBottomDottedLayer removeFromSuperlayer];
        self.vertivalBottomDottedLayer = nil;
        
        
        self.timeLabel.text = @"";
        self.timeLabel.hidden = YES;
    }
    for (CAShapeLayer *layer in self.dottedLayerArr) {
        
        [layer removeFromSuperlayer];
        
    }
    [self.dottedLayerArr removeAllObjects];
    for (int i = 0; i<5; i++) {
        
        CAShapeLayer *dottedLineLayer = [CAShapeLayer layer];
        UIBezierPath *dottedLineBeizer = [UIBezierPath bezierPath];
        [dottedLineBeizer moveToPoint:CGPointMake(self.candyChartHeight/4*i+(self.tableViewHeight-self.candyChartHeight)-self.detailDisplayLabelHeight,0)];
        [dottedLineBeizer addLineToPoint:CGPointMake(self.candyChartHeight/4*i+(self.tableViewHeight-self.candyChartHeight)-self.detailDisplayLabelHeight,self.contentView.frame.size.height)];
//        dottedLineLayer.lineDashPattern = @[@4, @2];//画虚线
        dottedLineLayer.path = dottedLineBeizer.CGPath;
        dottedLineLayer.lineWidth = 0.5;
        struct CGColor *strokeColor = GrateLineColor.CGColor;
        dottedLineLayer.strokeColor = strokeColor;
        dottedLineLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:dottedLineLayer];
        [self.dottedLayerArr addObject:dottedLineLayer];
        
    }
    for (int i = 0; i<2; i++) {
        
        CAShapeLayer *bottomDottedLineLayer = [self drawDottedLineWithStartPoint:CGPointMake(self.quotaChartHeight*i, 0) endPoint:CGPointMake(self.quotaChartHeight*i, self.frame.size.height)];
        [self.layer addSublayer:bottomDottedLineLayer];
        [self.dottedLayerArr addObject:bottomDottedLineLayer];
    }
    
    //重绘前都移除
    [self.shapeLayer removeFromSuperlayer];
    [self.bottomLayer removeFromSuperlayer];
    [self.topLayer removeFromSuperlayer];
    if (self.isDrawKline&&!self.model.isPlaceHolder) {
        
        //画矩形
        //这个地方的模型需要倒置思考，旋转了90度
        self.bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.model.y+(self.tableViewHeight-self.candyChartHeight)-self.detailDisplayLabelHeight, 2, self.model.h, self.frame.size.height-4) cornerRadius:0];
        self.shapeLayer = [CAShapeLayer layer];
        self.shapeLayer.path = self.bezierPath.CGPath;
        self.shapeLayer.fillColor = self.model.fillColor.CGColor;
        self.shapeLayer.strokeColor = self.model.strokeColor.CGColor;
        [self.layer addSublayer:self.shapeLayer];
        
        //上影线
        self.topLayer = [CAShapeLayer layer];
        UIBezierPath *topLine = [UIBezierPath bezierPath];
        [topLine moveToPoint:CGPointMake(self.model.y+self.model.h+(self.tableViewHeight-self.candyChartHeight)-self.detailDisplayLabelHeight, self.frame.size.height/2)];
        [topLine addLineToPoint:CGPointMake(self.model.highestPoint+(self.tableViewHeight-self.candyChartHeight)-self.detailDisplayLabelHeight, self.frame.size.height/2)];
        self.topLayer.path = topLine.CGPath;
        self.topLayer.strokeColor = self.model.strokeColor.CGColor;
        [self.layer addSublayer:self.topLayer];
        
        
        //下影线
        self.bottomLayer = [CAShapeLayer layer];
        UIBezierPath *bottomLine = [UIBezierPath bezierPath];
        [bottomLine moveToPoint:CGPointMake(self.model.y+(self.tableViewHeight-self.candyChartHeight)-self.detailDisplayLabelHeight, self.frame.size.height/2)];
        [bottomLine addLineToPoint:CGPointMake(self.model.lowestPoint+(self.tableViewHeight-self.candyChartHeight)-self.detailDisplayLabelHeight, self.frame.size.height/2)];
        self.bottomLayer.path = bottomLine.CGPath;
        self.bottomLayer.strokeColor = self.model.strokeColor.CGColor;
        [self.layer addSublayer:self.bottomLayer];
        self.layer.backgroundColor = BackgroundColor.CGColor;
    }

}
- (CAShapeLayer *)drawDottedLineWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    CAShapeLayer *dottedLineLayer = [CAShapeLayer layer];
    UIBezierPath *dottedLineBeizer = [UIBezierPath bezierPath];
    [dottedLineBeizer moveToPoint:startPoint];
    [dottedLineBeizer addLineToPoint:endPoint];
//    dottedLineLayer.lineDashPattern = @[@4, @2];//画虚线
    dottedLineLayer.path = dottedLineBeizer.CGPath;
    dottedLineLayer.lineWidth = 0.5;
    struct CGColor *strokeColor = GrateLineColor.CGColor;
    dottedLineLayer.strokeColor = strokeColor;
    dottedLineLayer.fillColor = [UIColor clearColor].CGColor;
    return dottedLineLayer;
}
- (NSMutableArray *)dottedLayerArr
{
    if (!_dottedLayerArr) {
        _dottedLayerArr = [NSMutableArray array];
    }
    return _dottedLayerArr;
}
- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.text = self.model.timeStr;
        _timeLabel.backgroundColor = BackgroundColor;
        _timeLabel.font = [UIFont systemFontOfSize:9];
        _timeLabel.userInteractionEnabled = YES;
        _timeLabel.textColor = NormalTextColor;
        [self addSubview:_timeLabel];
    }
    return _timeLabel;
}
- (UIInterfaceOrientation)orientation
{
    return  [[UIApplication sharedApplication] statusBarOrientation];
}
@end


