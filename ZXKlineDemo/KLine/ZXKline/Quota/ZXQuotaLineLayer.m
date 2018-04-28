//
//  ZXQuotaLayer.m
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/8/11.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ZXQuotaLineLayer.h"
#import "ZXHeader.h"
@interface ZXQuotaLineLayer()
@property (nonatomic,strong) NSArray *dataArr;
@property (nonatomic,assign) NSInteger startIndex;
@property (nonatomic,assign) double heightPerpoint;
@property (nonatomic,strong) UIBezierPath *beizerPath;
@property (nonatomic,assign) CGFloat rowHeight;
@property (nonatomic,strong) UIColor *lineColor;
@property (nonatomic,strong) NSString *quotaName;
@end

@implementation ZXQuotaLineLayer
- (instancetype)initQuotaDataArr:(NSArray *)dataArr currentDrawStartIndex:(NSInteger)startIndex rowHeight:(CGFloat)rowHeight  minValue:(double)minValue heightPerpoint:(CGFloat)heightPerpoint lineColor:(UIColor *)lineColor quotaName:(NSString *)quotaName
{
    self = [super init];
    if (self) {
        
        self.rowHeight = rowHeight;
//        [self getMaxAndMinValueWithDataArr:dataArr];
        self.lineColor = lineColor;
        self.quotaMinValue = minValue;
        self.dataArr = dataArr;
        self.startIndex = startIndex;
        self.heightPerpoint = heightPerpoint;
        self.quotaName = quotaName;
        NSArray *tempArr = [self convertToKlinePositionModelWithDataArr:self.dataArr];
        [self drawWithPositionArr:tempArr];
    }
    return self;
}

- (void)drawWithPositionArr:(NSArray *)positionArr
{
    self.beizerPath = [UIBezierPath bezierPath];
    __block NSInteger invalidNumCount = 0;
    if ([positionArr containsObject:@"-"]) {
        
        [positionArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj isKindOfClass:[NSString class]]) {
                
                if ([obj isEqualToString:@"-"]) {
                    
                    invalidNumCount += 1;
                }
            }
            
        }];
    }
    
    [positionArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger startIndex = 0;
        if (invalidNumCount > 0) {
            
            if (self.startIndex<=invalidNumCount-1) {
                
                startIndex = invalidNumCount-1+idx;
            }else{
                startIndex = self.startIndex + idx;
            }
        }else{
            startIndex = self.startIndex + idx;
        }
        if (![obj isKindOfClass:[NSString class]]) {
            
            
            if (idx==invalidNumCount) {
                
                [self.beizerPath moveToPoint:CGPointMake([obj doubleValue], self.rowHeight*(self.startIndex+idx)+self.rowHeight/2)];
            }else{
                
                [self.beizerPath addLineToPoint:CGPointMake([obj doubleValue], self.rowHeight*(self.startIndex+idx)+self.rowHeight/2)];
            }
            
        }
        
       // [self drawQuotaWithIndex:startIndex xPosition:[obj doubleValue]];
    }];
    
    self.path = self.beizerPath.CGPath;
    self.lineWidth = 0.5;
    self.strokeColor = self.lineColor.CGColor;
    self.fillColor = [UIColor clearColor].CGColor;

}

- (void)drawQuotaWithIndex:(NSInteger)index xPosition:(CGFloat)x
{
    if (index == self.startIndex||index == 8) {
        
        [self.beizerPath moveToPoint:CGPointMake(x, self.rowHeight*index+self.rowHeight/2)];
    }else
    {
        
        [self.beizerPath addLineToPoint:CGPointMake(x, self.rowHeight*index+self.rowHeight/2)];
    }
}

- (NSArray *)convertToKlinePositionModelWithDataArr:(NSArray *)dataArr
{

    NSMutableArray *quotaPositionArr = [NSMutableArray array];
    [dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSString class]]) {
        
            double value = [obj doubleValue];
            double quotaPositionY = (value - self.quotaMinValue)*self.heightPerpoint;
            [quotaPositionArr addObject:@(quotaPositionY)];
        }else{
            [quotaPositionArr addObject:@"-"];
        }

    }];
    return [quotaPositionArr copy];
}

@end
