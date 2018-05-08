//
//  ZXQuotaSynthsisLayer.h
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/8/23.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "ZXHeader.h"
@interface ZXQuotaSynthsisLayer : CAShapeLayer
- (instancetype)initQuotaDataArr:(NSArray *)dataArr currentDrawStartIndex:(NSInteger)startIndex rowHeight:(CGFloat)rowHeight minValue:(double)minValue heightPerpoint:(CGFloat)heightPerpoint synthsisColor:(UIColor *)synthsisColor;
@end
