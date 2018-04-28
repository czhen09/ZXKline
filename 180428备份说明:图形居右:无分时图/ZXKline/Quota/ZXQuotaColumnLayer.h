//
//  ZXQuotaColumnLayer.h
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/8/14.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ZXHeader.h"
@interface ZXQuotaColumnLayer : CAShapeLayer
- (instancetype)initQuotaDataArr:(NSArray *)dataArr currentDrawStartIndex:(NSInteger)startIndex rowHeight:(CGFloat)rowHeight  minValue:(double)minValue maxValue:(CGFloat)maxValue heightPerpoint:(CGFloat)heightPerpoint columnColorArr:(NSArray *)columnColorArr columnWidthType:(ColumnWidthType)columnWidthType;
@end
