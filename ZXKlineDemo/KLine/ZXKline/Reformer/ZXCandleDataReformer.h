//
//  ZXCandleDataReformer.h
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/9/13.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KlineModel.h"
/**
 * 蜡烛时间
 */
typedef NS_ENUM(NSUInteger, DurationPerCandle) {
    DurationPerCandleWithM1 = 0,
    DurationPerCandleWithM5,
    DurationPerCandleWithM15,
    DurationPerCandleWithM30,
    DurationPerCandleWithH1,
    DurationPerCandleWithH4,
    DurationPerCandleWithD1,
    DurationPerCandleWithD2,
    DurationPerCandleWithD5,
    DurationPerCandleWithW1,
    DurationPerCandleWithW2,
    DurationPerCandleWithW3,
    DurationPerCandleWithW4,
};
@interface ZXCandleDataReformer : NSObject
+ (instancetype)sharedInstance;
- (NSArray<KlineModel *>*)transformDataWithDataArr:(NSArray *)dataArr currentRequestType:(NSString *)currentRequestType;
@end
