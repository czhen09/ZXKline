//
//  ZXCalculator.h
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/8/11.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <Foundation/Foundation.h>
static NSString *const kMaxValue = @"kMaxValue";
static NSString *const kMinValue = @"kMinValue";
@interface ZXCalculator : NSObject
+ (instancetype)sharedInstance;
/**
 * @brief 极值计算
 * @param dataArr 数据数组
 */
- (NSDictionary *)calculateMaxAndMinValueWithDataArr:(NSArray *)dataArr;
/**
 * @brief 获取当前蜡烛之间的时间间隔的时间戳，比如1min，5min的时间戳
 * @param requestType 请求类型，M1,M5...
 * @param lastKlineModelTimesamp 数据源中的最后一个的时间戳
 */
- (NSInteger)getTimesampIntervalWithRequestType:(NSString *)requestType timesamp:(NSInteger)lastKlineModelTimesamp;
@end
