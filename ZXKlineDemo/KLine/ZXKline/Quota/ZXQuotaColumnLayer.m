//
//  ZXQuotaColumnLayer.m
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/8/14.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ZXQuotaColumnLayer.h"
#import <UIKit/UIKit.h>

@interface ZXQuotaColumnLayer()
@property (nonatomic,strong) NSArray *dataArr;
@property (nonatomic,assign) NSInteger startIndex;
@property (nonatomic,assign) double heightPerpoint;
@property (nonatomic,assign) CGFloat rowHeight;
@property (nonatomic,assign) double quotaMinValue;
@property (nonatomic,assign) double quotaMaxValue;
@property (nonatomic,strong) NSArray *columnColorArr;
@property (nonatomic,assign) ColumnWidthType columnWidthType;
@end
@implementation ZXQuotaColumnLayer
- (instancetype)initQuotaDataArr:(NSArray *)dataArr currentDrawStartIndex:(NSInteger)startIndex rowHeight:(CGFloat)rowHeight  minValue:(double)minValue maxValue:(CGFloat)maxValue heightPerpoint:(CGFloat)heightPerpoint columnColorArr:(NSArray *)columnColorArr columnWidthType:(ColumnWidthType)columnWidthType
{
    self = [super init];
    if (self) {
        
        self.rowHeight = rowHeight;
        self.quotaMinValue = minValue;
        self.quotaMaxValue = maxValue;
        self.dataArr = dataArr;
        self.startIndex = startIndex;
        self.heightPerpoint = heightPerpoint;
        self.columnColorArr = columnColorArr;
        self.columnWidthType = columnWidthType;
        NSArray *tempArr = [self convertToKlinePositionModelWithDataArr:self.dataArr];
        [self drawWithPositionArr:tempArr];
    }
    return self;
}

- (void)drawWithPositionArr:(NSArray *)positionArr
{
    
    [positionArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (![obj isKindOfClass:[NSString class]]) {
//
            NSArray *layerArr = [self drawQuotaWithIndex:idx xPosition:[obj doubleValue]];
            for (CAShapeLayer *columnLayer in layerArr) {
        
                [self addSublayer:columnLayer];
            }
//        }
    
    }];
    
}

- (NSArray *)drawQuotaWithIndex:(NSInteger)index xPosition:(CGFloat)x
{
    NSMutableArray *layerArr = [NSMutableArray array];
    UIBezierPath *beizerPath = [UIBezierPath bezierPath];
    CAShapeLayer *layer = [CAShapeLayer layer];
    
    //如果最小值是负数的话，这里zerovalue就是中线0的位置；
    //如果最小值是正数的话，这里zerovalue就是最小值的位置；
    double zeroValue = ABS(self.quotaMinValue*self.heightPerpoint);
    if (self.quotaMinValue<0&&self.quotaMaxValue>0) {
        CGFloat startPointX = 0;
        switch (self.columnWidthType) {
            case ColumnWidthTypeEqualLine:
                
                [beizerPath moveToPoint:CGPointMake(zeroValue, self.rowHeight*(self.startIndex+index)+self.rowHeight/2)];
                [beizerPath addLineToPoint:CGPointMake(x, self.rowHeight*(self.startIndex+index)+self.rowHeight/2)];
                break;
            case ColumnWidthTypeEqualCandle:
                
                if (x>zeroValue) {
                    startPointX = zeroValue;
                }else{
                    startPointX = x;
                }
                 beizerPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(startPointX, self.rowHeight*(self.startIndex+index)+2, ABS(x-zeroValue),self.rowHeight-4) cornerRadius:0];
                break;
            default:
                break;
        }
        
        //画一根横线代表0值
        UIBezierPath *zeroBeizer = [UIBezierPath bezierPath];
        CAShapeLayer *zeroLayer = [CAShapeLayer layer];
        [zeroBeizer moveToPoint:CGPointMake(zeroValue, self.rowHeight*(self.startIndex+index))];
        [zeroBeizer addLineToPoint:CGPointMake(zeroValue, self.rowHeight*(self.startIndex+index)+self.rowHeight)];
        zeroLayer.lineDashPattern = @[@4, @2];//画虚线
        zeroLayer.path = zeroBeizer.CGPath;
        zeroLayer.lineWidth = 0.5;
        struct CGColor *strokeColor = [UIColor grayColor].CGColor;
        zeroLayer.strokeColor = strokeColor;
        zeroLayer.fillColor = [UIColor clearColor].CGColor;
        [layerArr addObject:zeroLayer];
    }else
    {
        
        switch (self.columnWidthType) {
            case ColumnWidthTypeEqualLine:
                [beizerPath moveToPoint:CGPointMake(0, self.rowHeight*(self.startIndex+index)+self.rowHeight/2)];
                [beizerPath addLineToPoint:CGPointMake(x, self.rowHeight*(self.startIndex+index)+self.rowHeight/2)];
                break;
            case ColumnWidthTypeEqualCandle:
                //高度  x-QuotaBottomMargin   需要减去10
                beizerPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, self.rowHeight*(self.startIndex+index)+2, x,self.rowHeight-4) cornerRadius:0];
                break;
            default:
                break;
        }

    }
    
    struct CGColor *strokeColor = nil;
    if (self.quotaMinValue<0&&self.quotaMaxValue>0&&!self.columnColorArr) {
        
        if (x>zeroValue) {
            strokeColor = RISECOLOR.CGColor;
        }else{
            strokeColor = DROPCOLOR.CGColor;
        }
    }else{
        if (self.columnColorArr.count==0) {
            
            if (self.quotaMinValue<=0&&self.quotaMaxValue<=0) {
                
                strokeColor = DROPCOLOR.CGColor;
            }else if (self.quotaMinValue>=0&&self.quotaMaxValue>=0)
            {
                strokeColor = RISECOLOR.CGColor;
            }
        } else if (self.columnColorArr.count==1) {
            
            NSObject *item = self.columnColorArr.firstObject;
            if ([item isKindOfClass:[UIColor class]]) {
                
                strokeColor = ((UIColor *)item).CGColor;
                
            }else{
                
                NSAssert(![item isKindOfClass:[UIColor class]],
                         @"柱状指标颜色数组中非颜色");
            }
            
        }else
        {
            if (index<self.columnColorArr.count) {
                
                NSObject *item  = self.columnColorArr[index];
                if ([item isKindOfClass:[UIColor class]]) {
                    
                    strokeColor = ((UIColor *)item).CGColor;
                    
                }else{
                    
                    NSAssert(![item isKindOfClass:[UIColor class]],
                             @"柱状指标颜色数组中非颜色");
                }
            }
            
        }
    }

    layer.path = beizerPath.CGPath;
    layer.lineWidth = 1;
    layer.strokeColor = strokeColor;
    layer.fillColor = strokeColor;
    [layerArr addObject:layer];
    return [layerArr copy];
}


- (NSArray *)convertToKlinePositionModelWithDataArr:(NSArray *)dataArr
{
    NSMutableArray *quotaPositionArr = [NSMutableArray array];
    [dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
//        if (![obj isKindOfClass:[NSString class]]) {
//
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
