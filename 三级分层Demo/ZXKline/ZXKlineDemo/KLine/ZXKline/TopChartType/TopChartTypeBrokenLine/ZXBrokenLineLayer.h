//
//  ZXTimeLineLayer.h
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/9/1.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ZXHeader.h"
@interface ZXBrokenLineLayer : CAShapeLayer
- (instancetype)initCurrentNeedDrawDataArr:(NSArray *)dataArr  rowHeight:(CGFloat)rowHeight  minValue:(double)minValue heightPerpoint:(CGFloat)heightPerpoint totalHeight:(CGFloat)totalHeight candleChartHeight:(CGFloat)candleChartHeight topChartType:(ZXTopChartType)topChartType;
@end
