//
//  MALayer.h
//  LandscapeTableviewAndKLine
//
//  Created by 郑旭 on 2017/8/1.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface MALayer : CAShapeLayer
- (instancetype)initWithNum:(NSInteger)num needDrawMAArr:(NSArray *)needDrawMAArr rowHeight:(CGFloat)rowHeight totalHeight:(CGFloat)totalHeight  minValue:(CGFloat)minValue candyChartHeight:(CGFloat)candyChartHeight detailDisplayLabelHeight:(CGFloat)detailDisplayLabelHeight currentDrawStartIndex:(NSInteger)startIndex heightPerpoint:(CGFloat)heightPerpoint lineColor:(UIColor *)lineColor;

@end
