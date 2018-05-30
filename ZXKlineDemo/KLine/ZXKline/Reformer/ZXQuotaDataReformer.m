//
//  ZXQuotaDataReformer.m
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/9/13.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ZXQuotaDataReformer.h"
static NSString *const kRise = @"kRise";
static NSString *const kDrop = @"kDrop";
@implementation ZXQuotaDataReformer
static id _instance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
- (NSArray <KlineModel *>*)initializeQuotaDataWithArray:(NSArray <KlineModel *>*)dataArray
{
    
    __weak typeof(self) weakSelf = self;
    [dataArray enumerateObjectsUsingBlock:^(KlineModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [weakSelf handleQuotaDataWithDataArr:dataArray model:model index:idx];
        
    }];
    return dataArray;
}

- (void)handleQuotaDataWithDataArr:(NSArray *)dataArr model:(KlineModel *)model index:(NSInteger)idx
{
    //MACD
    [self calculateMACDWithDataArr:dataArr model:model index:idx];
    //KDJ
    [self calculateKDJWithDataArr:dataArr model:model index:idx];
    //BOLL
    [self calculateBOLLWithDataArr:dataArr model:model index:idx];
    //RSI
    [self calculateRSIWithDataArr:dataArr model:model index:idx];
    //VOL
    [self calculateVOLWithDataArr:dataArr model:model index:idx];
    //MA
    //    [self calculateMAWithDataArr:dataArr model:model index:idx];
}
//- (void)calculateMAWithDataArr:(NSArray *)dataArr model:(KlineModel *)model index:(NSInteger)idx
//{
//    NSInteger MAFiveNum = 5.0;
//    if (idx>=MAFiveNum-1) {
//
//        model.MA5 = @([self getPreviousAverageMAWithDataArr:dataArr dayCount:MAFiveNum index:idx]);
//    }
//
//    NSInteger MATenNum = 10.0;
//    if (idx>=MATenNum-1) {
//
//        model.MA10 = @([self getPreviousAverageMAWithDataArr:dataArr dayCount:MATenNum index:idx]);
//
//    }
//
//    NSInteger MATwentyNum = 20.0;
//    if (idx>=MATwentyNum-1) {
//
//        model.MA20 = @([self getPreviousAverageMAWithDataArr:dataArr dayCount:MATwentyNum index:idx]);
//
//    }
//
//}
//- (double)getPreviousAverageMAWithDataArr:(NSArray *)dataArr dayCount:(NSInteger)dayCount index:(NSInteger)idx
//{
//    __block double sumOfMA = 0;
//    for (NSInteger i = idx-(dayCount-1); i<=idx; i++) {
//
//        if (i>=0&&i<dataArr.count) {
//            KlineModel *model = dataArr[i];
//            sumOfMA += model.closePrice;
//        }
//    }
//    return sumOfMA/dayCount;
//}
//MACD
- (void)calculateMACDWithDataArr:(NSArray *)dataArr model:(KlineModel *)model index:(NSInteger)idx
{
    KlineModel *previousKlineModel = nil;
    if (idx>0&&idx<dataArr.count) {
        
        previousKlineModel = dataArr[idx-1];
    }
    model.previousKlineModel = previousKlineModel;
    [model reInitData];
}
//VOL
- (void)calculateVOLWithDataArr:(NSArray *)dataArr model:(KlineModel *)model index:(NSInteger)idx
{
    NSInteger VOLFiveNum = 5.0;
    if (idx>=VOLFiveNum-1) {
        
        model.volumn_MA5 = @([self getPreviousAverageVolumnWithDataArr:dataArr dayCount:VOLFiveNum index:idx]);
    }
    
    NSInteger VOLTenNum = 10.0;
    if (idx>=VOLTenNum-1) {
        
        model.volumn_MA10 = @([self getPreviousAverageVolumnWithDataArr:dataArr dayCount:VOLTenNum index:idx]);
        
    }
    
    NSInteger VOLTwentyNum = 20.0;
    if (idx>=VOLTwentyNum-1) {
        
        model.volumn_MA20 = @([self getPreviousAverageVolumnWithDataArr:dataArr dayCount:VOLTwentyNum index:idx]);
        
    }
}
- (double)getPreviousAverageVolumnWithDataArr:(NSArray *)dataArr dayCount:(NSInteger)dayCount index:(NSInteger)idx
{
    __block double sumOfVolumn = 0;
    for (NSInteger i = idx-(dayCount-1); i<=idx; i++) {
        
        if (i>=0&&i<dataArr.count) {
            KlineModel *model = dataArr[i];
            sumOfVolumn += [model.volumn doubleValue];
        }
    }
    return sumOfVolumn/dayCount;
}

//KDJ
- (void)calculateKDJWithDataArr:(NSArray *)dataArr model:(KlineModel *)model index:(NSInteger)idx
{
    NSInteger num = 9;
    if (idx>=num-1) {
        NSMutableArray *previousNineKlineModelArr = [NSMutableArray array];
        for (NSInteger i = idx-(num-1); i<=idx; i++) {
            
            if (i>=0&&i<dataArr.count) {
                KlineModel *model = dataArr[i];
                [previousNineKlineModelArr addObject:@(model. highestPrice)];
                [previousNineKlineModelArr addObject:@(model.lowestPrice)];
            }
        }
        NSDictionary *resultDic = [[ZXCalculator sharedInstance] calculateMaxAndMinValueWithDataArr:previousNineKlineModelArr];
        model.HNinePrice = resultDic[kMaxValue];
        model.LNinePrice = resultDic[kMinValue];
        [model reInitKDJData];
    }
}
//BOLL
- (void)calculateBOLLWithDataArr:(NSArray *)dataArr model:(KlineModel *)model index:(NSInteger)idx
{
    NSInteger bollNum = 20.0;
    if (idx>=bollNum-1) {
        
        double sum = 0;
        for (NSInteger i = idx-(bollNum-1); i<=idx; i++) {
            
            if (i>=0&&i<dataArr.count) {
                KlineModel * model = dataArr[i];
                sum += model.closePrice;
            }
        }
        model.BOLL_MA = @(sum/bollNum);
        
        
        double powSumPrice = 0;
        NSInteger j = idx-(bollNum-2);
        if (j<19) {
            j = 19;
        }
        for (NSInteger i = j; i<=idx; i++) {
            
            if (i>=0&&i<dataArr.count) {
                KlineModel * model = dataArr[i];
                powSumPrice += pow((model.closePrice-model.BOLL_MA.doubleValue), 2);
            }
        }
        model.BOLL_MD = @(sqrt(powSumPrice/bollNum));
        [model reInitBOLLData];
    }
}
//RSI
- (void)calculateRSIWithDataArr:(NSArray *)dataArr model:(KlineModel *)model index:(NSInteger)idx
{
    NSInteger RSISixNum = 6;
    if (idx>=RSISixNum-1) {
        model.RSI_6 = @([self getRSIWithDataArr:dataArr dayCount:RSISixNum index:idx]);
    }
    
    NSInteger RSITwelveNum = 12;
    if (idx>=RSITwelveNum-1) {
        model.RSI_12 = @([self getRSIWithDataArr:dataArr dayCount:RSITwelveNum index:idx]);
    }
    
    NSInteger RSITwentyfourNum = 24;
    if (idx>=RSITwentyfourNum-1) {
        model.RSI_24 = @([self getRSIWithDataArr:dataArr dayCount:RSITwentyfourNum index:idx]);
    }
    [model judgeRSIIsNan];
}
- (double)getRSIWithDataArr:(NSArray *)dataArr dayCount:(NSInteger)dayCount index:(NSInteger)idx
{
    NSMutableArray *previousPriceArr = [NSMutableArray array];
    for (NSInteger i = idx-(dayCount-1); i<=idx; i++) {
        
        if (i>=0&&i<dataArr.count) {
            KlineModel *model = dataArr[i];
            double close = model.closePrice;
            double open = model.previousKlineModel.closePrice;
            [previousPriceArr addObject:@(close-open)];
            model = nil;
        }
    }
    return [self getRSIWithPreviousPriceOfChangeArr:previousPriceArr dayCount:dayCount];
    
}
- (double)getRSIWithPreviousPriceOfChangeArr:(NSArray *)previousPriceOfChangeArr dayCount:(double)dayCount
{
    
    NSDictionary *sumDic = [self getSumOfRiseAndDropWithPreviousPriceOfChangeArr:previousPriceOfChangeArr];
    double riseSum  = [sumDic[kRise] doubleValue];
    double dropSum  = [sumDic[kDrop] doubleValue];
    double riseRate = riseSum/dayCount;
    double dropRate = dropSum/dayCount*(-1);
    double RS       = riseRate/dropRate;
    double RSI      = (100-(100/(1+RS)));
    return RSI;
}

- (NSDictionary *)getSumOfRiseAndDropWithPreviousPriceOfChangeArr:(NSArray *)previousPriceOfChangeArr
{
    __block double sumOfRise = 0;
    __block double sumOfDrop = 0;
    
    [previousPriceOfChangeArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        double changeValue = [obj doubleValue];
        if (changeValue>=0) {
            
            sumOfRise +=changeValue;
        }else
        {
            sumOfDrop += changeValue;
        }
        
    }];
    NSDictionary *resultDic = [NSDictionary dictionaryWithObjectsAndKeys:@(sumOfRise),kRise,@(sumOfDrop),kDrop,nil];
    return resultDic;
}
@end
