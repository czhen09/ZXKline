//
//  ZXTimeLineLayer.m
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/9/1.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ZXTimeLineLayer.h"
#import <UIKit/UIKit.h>
#import "ZXHeader.h"
#import "KlineModel.h"
@interface ZXTimeLineLayer()
@property (nonatomic,assign) double heightPerpoint;
@property (nonatomic,strong) UIBezierPath *beizerPath;
@property (nonatomic,strong) NSArray *currentNeedDrawDataArr;
@property (nonatomic,assign) CGFloat rowHeight;
@property (nonatomic,assign) double minValue;
@property (nonatomic,assign) CGFloat totalHeight;
@property (nonatomic,assign) CGFloat candleChartHeight;
@end
@implementation ZXTimeLineLayer
- (instancetype)initCurrentNeedDrawDataArr:(NSArray *)dataArr rowHeight:(CGFloat)rowHeight minValue:(double)minValue heightPerpoint:(CGFloat)heightPerpoint totalHeight:(CGFloat)totalHeight candleChartHeight:(CGFloat)candleChartHeight
{
    if (self==[super init]) {
        self.totalHeight = totalHeight;
        self.currentNeedDrawDataArr = dataArr;
        self.rowHeight = rowHeight;
        self.minValue = minValue;
        self.heightPerpoint = heightPerpoint;
        self.candleChartHeight = candleChartHeight;
        NSArray *positionArr = [self convertToKlinePositionModelWithDataArr:dataArr];
        [self drawWithPositionArr:positionArr];
    }
    return self;
}
- (void)drawWithPositionArr:(NSArray *)positionArr
{
    NSInteger startIndex = ((KlineModel *)(self.currentNeedDrawDataArr.firstObject)).x;
    NSInteger endIndex = ((KlineModel *)(self.currentNeedDrawDataArr.lastObject)).x;
    self.beizerPath = [UIBezierPath bezierPath];
    [positionArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        if (idx==0) {
            
            [self.beizerPath moveToPoint:CGPointMake([obj doubleValue], self.rowHeight*(startIndex+idx)+self.rowHeight/2)];
        }else{
            
            [self.beizerPath addLineToPoint:CGPointMake([obj doubleValue], self.rowHeight*(startIndex+idx)+self.rowHeight/2)];
        }

    }];
    
    self.path = self.beizerPath.CGPath;
    self.lineWidth = 0.6;
    self.strokeColor = [UIColor blueColor].CGColor;
    self.fillColor = [UIColor clearColor].CGColor;
    
    
    
    [self.beizerPath addLineToPoint:CGPointMake((self.totalHeight-self.candleChartHeight), endIndex*self.rowHeight+self.rowHeight/2)];
    [self.beizerPath addLineToPoint:CGPointMake((self.totalHeight-self.candleChartHeight), startIndex*self.rowHeight+self.rowHeight/2)];
    [self.beizerPath closePath];
    CAShapeLayer *fillColorLayer = [CAShapeLayer layer];
    fillColorLayer.path = self.beizerPath.CGPath;
    fillColorLayer.fillColor = [UIColor colorWithRed:107/255.0 green:165/255.0 blue:131/255.0 alpha:0.5].CGColor;
    fillColorLayer.strokeColor = [UIColor clearColor].CGColor;
    fillColorLayer.zPosition = -1;
    [self addSublayer:fillColorLayer];
}
- (NSArray *)convertToKlinePositionModelWithDataArr:(NSArray *)dataArr
{
    NSMutableArray *timeLinePositionArr = [NSMutableArray array];
    [dataArr enumerateObjectsUsingBlock:^(KlineModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
    
        double positionY = (model.closePrice - self.minValue)*self.heightPerpoint+(self.totalHeight-self.candleChartHeight);
        [timeLinePositionArr addObject:@(positionY)];
       
    }];
    return [timeLinePositionArr copy];
}
@end
