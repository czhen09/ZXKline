//
//  ZXTimeLineLayer.m
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/9/1.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ZXBrokenLineLayer.h"
#import <UIKit/UIKit.h>
#import "ZXHeader.h"
#import "KlineModel.h"
#import "ZXRippleLayer.h"
@interface ZXBrokenLineLayer()
@property (nonatomic,assign) double heightPerpoint;
@property (nonatomic,strong) UIBezierPath *beizerPath;
@property (nonatomic,strong) NSArray *currentNeedDrawDataArr;
@property (nonatomic,assign) CGFloat rowHeight;
@property (nonatomic,assign) double minValue;
@property (nonatomic,assign) CGFloat totalHeight;
@property (nonatomic,assign) CGFloat candleChartHeight;
@property (nonatomic,assign) ZXTopChartType topChartType;
@property (nonatomic,strong) ZXRippleLayer  *rippleLayer;
@end
@implementation ZXBrokenLineLayer
- (instancetype)initCurrentNeedDrawDataArr:(NSArray *)dataArr  rowHeight:(CGFloat)rowHeight  minValue:(double)minValue heightPerpoint:(CGFloat)heightPerpoint totalHeight:(CGFloat)totalHeight candleChartHeight:(CGFloat)candleChartHeight topChartType:(ZXTopChartType)topChartType
{
    if (self==[super init]) {
        self.totalHeight = totalHeight;
        self.currentNeedDrawDataArr = dataArr;
        self.rowHeight = rowHeight;
        self.minValue = minValue;
        self.heightPerpoint = heightPerpoint;
        self.candleChartHeight = candleChartHeight;
        self.topChartType = topChartType;
        NSArray *positionArr = [self convertToKlinePositionModelWithDataArr:dataArr];
        [self drawWithPositionArr:positionArr];
    }
    return self;
}
- (void)drawWithPositionArr:(NSArray *)positionArr
{
    //
    NSInteger startIndex = ((KlineModel *)(self.currentNeedDrawDataArr[0])).x;
    self.beizerPath = [UIBezierPath bezierPath];
    [positionArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        if (![obj isKindOfClass:[NSString class]]) {
            if (idx==0) {
                [self.beizerPath moveToPoint:CGPointMake([obj doubleValue], self.rowHeight*(startIndex+idx)+self.rowHeight/2)];
            }else{
            
                [self.beizerPath addLineToPoint:CGPointMake([obj doubleValue], self.rowHeight*(startIndex+idx)+self.rowHeight/2)];
            }
        }
    }];
    self.path = self.beizerPath.CGPath;
    self.lineWidth = 0.6;
    self.strokeColor = [UIColor blueColor].CGColor;
    self.fillColor = [UIColor clearColor].CGColor;
    


    [self.beizerPath addLineToPoint:CGPointMake((self.totalHeight-self.candleChartHeight), (startIndex+positionArr.count-0.5)*self.rowHeight)];
    [self.beizerPath addLineToPoint:CGPointMake((self.totalHeight-self.candleChartHeight), (startIndex)*self.rowHeight+self.rowHeight/2)];
    [self.beizerPath closePath];
    CAShapeLayer *fillColorLayer = [CAShapeLayer layer];
    fillColorLayer.path = self.beizerPath.CGPath;
    fillColorLayer.fillColor = [UIColor colorWithRed:106/255.0 green:231/255.0 blue:252/255.0 alpha:0.3].CGColor;
    fillColorLayer.strokeColor = [UIColor clearColor].CGColor;
    fillColorLayer.zPosition = -1;
    [self addSublayer:fillColorLayer];
}
- (NSArray *)convertToKlinePositionModelWithDataArr:(NSArray *)dataArr
{
    NSMutableArray *timeLinePositionArr = [NSMutableArray array];
    [dataArr enumerateObjectsUsingBlock:^(KlineModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!model.isPlaceHolder) {
//            [timeLinePositionArr addObject:@"-"];
//        }else{
            double positionY = (model.closePrice - self.minValue)*self.heightPerpoint+(self.totalHeight-self.candleChartHeight);
            [timeLinePositionArr addObject:@(positionY)];
        }
    }];
    return [timeLinePositionArr copy];
}
- (void)removeRippleLayer:(CAShapeLayer *)rippleLayer
{
    [rippleLayer removeFromSuperlayer];
    rippleLayer = nil;
}
@end
