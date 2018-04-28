//
//  ZXQuotaSynthsisLayer.m
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/8/23.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ZXQuotaSynthsisLayer.h"
@interface ZXQuotaSynthsisLayer()
@property (nonatomic,strong) NSArray *dataArr;
@property (nonatomic,assign) NSInteger startIndex;
@property (nonatomic,assign) double heightPerpoint;
@property (nonatomic,assign) CGFloat rowHeight;
@property (nonatomic,assign) double quotaMinValue;
@property (nonatomic,strong) UIColor *synthsisColor;
@property (nonatomic,strong) NSArray *openPositionArr;
@property (nonatomic,strong) NSArray *closePositionArr;
@property (nonatomic,strong) NSArray *highPositionArr;
@property (nonatomic,strong) NSArray *lowPositionArr;
@end
@implementation ZXQuotaSynthsisLayer
- (instancetype)initQuotaDataArr:(NSArray *)dataArr currentDrawStartIndex:(NSInteger)startIndex rowHeight:(CGFloat)rowHeight minValue:(double)minValue heightPerpoint:(CGFloat)heightPerpoint synthsisColor:(UIColor *)synthsisColor
{
    self = [super init];
    if (self) {
        
        self.dataArr = dataArr;
        self.startIndex = startIndex;
        self.heightPerpoint = heightPerpoint;
        self.rowHeight = rowHeight;
        self.quotaMinValue = minValue;
        self.synthsisColor = synthsisColor;
        self.openPositionArr = [self convertToKlinePositionModelWithDataArr:dataArr[0]];
        self.closePositionArr = [self convertToKlinePositionModelWithDataArr:dataArr[1]];
        self.highPositionArr = [self convertToKlinePositionModelWithDataArr:dataArr[2]];
        self.lowPositionArr = [self convertToKlinePositionModelWithDataArr:dataArr[3]];
        [self drawSynthsisLayer];
    }
    return self;
}

- (void)drawSynthsisLayer
{
    for (int i = 0; i<self.openPositionArr.count; i++) {
        if (![self.openPositionArr[i] isKindOfClass:[NSString class]]) {
            double openPosition = [self.openPositionArr[i] doubleValue];
            double closePosition = [self.closePositionArr[i] doubleValue];
            double highPosition = [self.highPositionArr[i] doubleValue];
            double lowPosition = [self.lowPositionArr[i] doubleValue];
            CAShapeLayer *openLayer = [self drawOpenHorizontalQuotaWithIndex:self.startIndex+i xPosition:openPosition];
            CAShapeLayer *closeLayer = [self drawCloseHorizontalQuotaWithIndex:self.startIndex+i xPosition:closePosition];
            CAShapeLayer *verticalLayer = [self drawVerticalQuotaWithIndex:self.startIndex+i lowPosition:lowPosition highPosition:highPosition];
            [self addSublayer:openLayer];
            [self addSublayer:closeLayer];
            [self addSublayer:verticalLayer];
        }
        
    }
    
}

- (CAShapeLayer *)drawOpenHorizontalQuotaWithIndex:(NSInteger)index xPosition:(double)x
{
    UIBezierPath *beizerPath = [UIBezierPath bezierPath];
    CAShapeLayer *layer = [CAShapeLayer layer];
    [beizerPath moveToPoint:CGPointMake(x, self.rowHeight*index+2)];
    [beizerPath addLineToPoint:CGPointMake(x, self.rowHeight*index+self.rowHeight/2)];
    layer.path = beizerPath.CGPath;
    layer.lineWidth = 1;
    layer.strokeColor = self.synthsisColor.CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    return layer;
}
- (CAShapeLayer *)drawCloseHorizontalQuotaWithIndex:(NSInteger)index xPosition:(double)x
{
    UIBezierPath *beizerPath = [UIBezierPath bezierPath];
    CAShapeLayer *layer = [CAShapeLayer layer];
    [beizerPath moveToPoint:CGPointMake(x, self.rowHeight*index+self.rowHeight/2)];
    [beizerPath addLineToPoint:CGPointMake(x, self.rowHeight*index+self.rowHeight-2)];
    layer.path = beizerPath.CGPath;
    layer.lineWidth = 1;
    layer.strokeColor = self.synthsisColor.CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    return layer;
}
- (CAShapeLayer *)drawVerticalQuotaWithIndex:(NSInteger)index lowPosition:(double)lowPosition highPosition:(double)highPosition
{
    UIBezierPath *beizerPath = [UIBezierPath bezierPath];
    CAShapeLayer *layer = [CAShapeLayer layer];
    [beizerPath moveToPoint:CGPointMake(lowPosition, self.rowHeight*index+self.rowHeight/2)];
    [beizerPath addLineToPoint:CGPointMake(highPosition, self.rowHeight*index+self.rowHeight/2)];
    layer.path = beizerPath.CGPath;
    layer.lineWidth = 1;
    layer.strokeColor = self.synthsisColor.CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    return layer;
}

- (NSArray *)convertToKlinePositionModelWithDataArr:(NSArray *)dataArr
{
    NSMutableArray *quotaPositionArr = [NSMutableArray array];
    [dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
//        if (![obj isKindOfClass:[NSString class]]) {
        
            double value = [obj doubleValue];
            double quotaPositionY = (value - self.quotaMinValue)*self.heightPerpoint;
            [quotaPositionArr addObject:@(quotaPositionY)];
//        }else{
//            [quotaPositionArr addObject:@"-"];
//        }
        
    }];
    return [quotaPositionArr copy];
}

@end
