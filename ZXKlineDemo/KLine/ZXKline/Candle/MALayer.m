//
//  MALayer.m
//  LandscapeTableviewAndKLine
//
//  Created by 郑旭 on 2017/8/1.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "MALayer.h"
#import "KlineModel.h"
#import "ZXHeader.h"
@interface MALayer()
@property (nonatomic,strong) UIBezierPath *beizerPath;
@property (nonatomic,assign) CGFloat rowHeight;
@property (nonatomic,strong) NSArray *needDrawMAArr;
@property (nonatomic,assign) CGFloat totalHeight;
/**
 * 峰值
 */
@property (nonatomic,assign) double minAssert;
/**
 *低值
 */
@property (nonatomic,assign) double maxAssert;
@property (nonatomic,assign) CGFloat heightPerpoint;
@property (nonatomic,assign) NSInteger startIndex;
@property (nonatomic,assign) CGFloat candyChartHeight;
@property (nonatomic,assign) CGFloat detailDisplayLabelHeight;
@property (nonatomic,strong) UIColor *lineColor;
@end
@implementation MALayer
- (instancetype)initWithNum:(NSInteger)num needDrawMAArr:(NSArray *)needDrawMAArr rowHeight:(CGFloat)rowHeight totalHeight:(CGFloat)totalHeight minValue:(CGFloat)minValue candyChartHeight:(CGFloat)candyChartHeight detailDisplayLabelHeight:(CGFloat)detailDisplayLabelHeight currentDrawStartIndex:(NSInteger)startIndex heightPerpoint:(CGFloat)heightPerpoint lineColor:(UIColor *)lineColor
{
    if (self=[super init]) {
        self.lineColor = lineColor;
        self.needDrawMAArr = needDrawMAArr;
        self.totalHeight = totalHeight;
        self.rowHeight = rowHeight;
        self.startIndex = startIndex;
        self.minAssert = minValue;
        self.heightPerpoint = heightPerpoint;
        self.candyChartHeight = candyChartHeight;
        self.detailDisplayLabelHeight = detailDisplayLabelHeight;
        [self drawWithNum:num needDrawMAArr:needDrawMAArr];
    }
    return self;
}

- (void)drawWithNum:(NSInteger)num needDrawMAArr:(NSArray *)needDrawMAArr
{

    
    __block NSInteger invalidNumCount = 0;
    if ([needDrawMAArr containsObject:@"-"]) {
        
        [needDrawMAArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj isKindOfClass:[NSString class]]) {
                
                if ([obj isEqualToString:@"-"]) {
                    
                    invalidNumCount += 1;
                }
            }
            
        }];
    }
    
     self.beizerPath = [UIBezierPath bezierPath];
    [needDrawMAArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        double value = [obj doubleValue];
        if (![obj isKindOfClass:[NSString class]]) {
            
            if (idx == invalidNumCount) {
                
                [self.beizerPath moveToPoint:CGPointMake(((value-self.minAssert)*self.heightPerpoint)+(self.totalHeight-self.candyChartHeight)-self.detailDisplayLabelHeight, self.rowHeight*(self.startIndex + idx)+self.rowHeight/2)];
            }else
            {
                
                [self.beizerPath addLineToPoint:CGPointMake(((value-self.minAssert)*self.heightPerpoint)+(self.totalHeight-self.candyChartHeight)-self.detailDisplayLabelHeight, self.rowHeight*(self.startIndex + idx)+self.rowHeight/2)];
            }
        }

    }];
    self.path = self.beizerPath.CGPath;
    self.lineWidth = 1;
    struct CGColor *strokeColor = nil;
    strokeColor = self.lineColor.CGColor;
    self.strokeColor = strokeColor;
    self.fillColor = [UIColor clearColor].CGColor;
}

@end
