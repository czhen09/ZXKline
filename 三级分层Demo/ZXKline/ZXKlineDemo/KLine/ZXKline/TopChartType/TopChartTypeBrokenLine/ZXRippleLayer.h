//
//  ZXRippleLayer.h
//  ZXKlineDemo
//
//  Created by 郑旭 on 2018/4/27.
//  Copyright © 2018年 郑旭. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
@interface ZXRippleLayer : CAShapeLayer
- (instancetype)initWithFrame:(CGRect)frame;
- (void)addRippleLayerAnimation;
@end
