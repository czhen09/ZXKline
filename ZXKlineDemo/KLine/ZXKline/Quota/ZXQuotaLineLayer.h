//
//  ZXQuotaLayer.h
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/8/11.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
@interface ZXQuotaLineLayer : CAShapeLayer
@property (nonatomic,assign) double quotaMaxValue;
@property (nonatomic,assign) double quotaMinValue;
//- (instancetype)initQuotaDataArr:(NSArray *)dataArr currentDrawStartIndex:(NSInteger)startIndex;
//- (void)drawQuotaWithMaxValue:(double)maxValue minValue:(double)minValue rowHeight:(CGFloat)rowHeight totalHeight:(CGFloat)totalHeight;
- (instancetype)initQuotaDataArr:(NSArray *)dataArr currentDrawStartIndex:(NSInteger)startIndex rowHeight:(CGFloat)rowHeight  minValue:(double)minValue heightPerpoint:(CGFloat)heightPerpoint lineColor:(UIColor *)lineColor quotaName:(NSString *)quotaName;
@end
