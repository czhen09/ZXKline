//
//  ZXDataReformer.m
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/9/13.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ZXDataReformer.h"
#import "ZXQuotaDataReformer.h"
#import "ZXCandleDataReformer.h"
@implementation ZXDataReformer
static id _instance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
- (NSArray <KlineModel *>*)transformDataWithOriginalDataArray:(NSArray *)dataArray currentRequestType:(NSString *)currentRequestType;
{
    self.currentRequestType = currentRequestType;
    //原始数据转模型
    //将请求到的数据数组传递过去，并且精度也是需要你自己传;
    /*
     数组中数据格式:@[@"时间戳,收盘价,开盘价,最高价,最低价,成交量",
     @"时间戳,收盘价,开盘价,最高价,最低价,成交量",
     @"时间戳,收盘价,开盘价,最高价,最低价,成交量",
     @"...",
     @"..."];
     */
    /*如果的数据格式和此demo中不同，那么你需要点进去看看，并且修改响应的取值为你的数据格式;
     修改数据格式→  ↓↓↓↓↓↓↓继续点它↓↓↓↓↓↓↓↓↓  ←
     */
    //数据处理
    NSArray <KlineModel *>*candleTransformerDataArray = [[ZXCandleDataReformer sharedInstance] transformDataWithDataArr:dataArray currentRequestType:currentRequestType];
    //模型二次计算;计算指标的值
    /*
      如果指标不够用，可以在这里进去计算更多的初始值
     */
    NSArray <KlineModel *>*quotaInitDataArray = [[ZXQuotaDataReformer sharedInstance] initializeQuotaDataWithArray:candleTransformerDataArray];
    return quotaInitDataArray;
}
@end
