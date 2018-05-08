//
//  ZXTimeLineView.h
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/8/28.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZXTimeLineView : UIView
- (instancetype)init;
- (void)updateTimeWithTimeString:(NSString *)timeString;
- (void)updateFrameWhenCandleFullScreenWithCandleHeight:(CGFloat)candleChartHeight;
@end
