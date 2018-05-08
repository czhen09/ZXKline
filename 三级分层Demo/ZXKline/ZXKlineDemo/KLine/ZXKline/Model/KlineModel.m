


//
//  KlineModel.m
//  LandscapeTableviewAndKLine
//
//  Created by 郑旭 on 2017/7/17.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "KlineModel.h"
static NSString *const kRise = @"kRise";
static NSString *const kDrop = @"kDrop";
@interface KlineModel()

@end
@implementation KlineModel
- (void)initData
{
    [self EMA12];
    [self EMA26];
    [self DIF];
    [self DEA];
    [self MACD];
}

//在最新的蜡烛数据来的时候需要重新每次计算
- (void)reInitData
{
    [self EMA12];
    [self EMA26];
    [self DIF];
    [self DEA];
    [self MACD];
}
- (NSNumber *)EMA12
{
    if (_EMA12==nil) {
        
        if (self.x==0) {

            _EMA12 = @(self.closePrice);

        }else{
        
            _EMA12 = @((2.0 * self.closePrice + 11 *(_previousKlineModel.EMA12.doubleValue))/13.0);
        }
    }
    return _EMA12;
}
- (NSNumber *)EMA26
{
    if (self.x==0) {

        _EMA26 = @(self.closePrice);
    }else{
        _EMA26 = @((2 * self.closePrice + 25 * self.previousKlineModel.EMA26.doubleValue)/27);
    }
    return _EMA26;
}
- (NSNumber *)DIF
{
    if (_DIF==nil) {
        
        _DIF = @(self.EMA12.doubleValue - self.EMA26.doubleValue);
    }
    return _DIF;
}
- (NSNumber *)DEA
{
    if (_DEA==nil) {
        
        _DEA = @(self.previousKlineModel.DEA.doubleValue * 0.8 + 0.2*self.DIF.doubleValue);
    }
    return _DEA;
}
- (NSNumber *)MACD
{
    if (_MACD==nil) {
        _MACD = @(2*(self.DIF.doubleValue - self.DEA.doubleValue));
    }
    return _MACD;
}


//KDJ
- (void)reInitKDJData
{

    self.RSV_9 = @((self.closePrice - self.LNinePrice.doubleValue)/(self.HNinePrice.doubleValue-self.LNinePrice.doubleValue)*100);
    

    double previousK = 0;
    if (self.x==8) {
        
        previousK = 50;
    }else{
        previousK = self.previousKlineModel.KDJ_K.doubleValue;
    }
    self.KDJ_K = @(previousK*2/3.0+1/3.0*self.RSV_9.doubleValue);
    

    double previousD = 0;
    if (self.x==8) {
        
        previousD = 50;
    }else{
        previousD = self.previousKlineModel.KDJ_D.doubleValue;
    }
    self.KDJ_D = @(previousD*2/3.0+1/3.0*self.KDJ_K.doubleValue);

    
    self.KDJ_J = @(3*self.KDJ_K.doubleValue-2*self.KDJ_D.doubleValue);
    
    if (isnan(self.KDJ_K.doubleValue)) {
        self.KDJ_K = self.previousKlineModel.KDJ_K;

    }
    if (isnan(self.KDJ_D.doubleValue)) {

        self.KDJ_D = self.previousKlineModel.KDJ_D;
    }
    if (isnan(self.KDJ_J.doubleValue)) {

        self.KDJ_J = self.previousKlineModel.KDJ_J;
    }
}


//BOLL
- (void)reInitBOLLData
{
    if (self.x==19) {
        
        self.BOLL_MB = self.BOLL_MA;
    }else{
        
        self.BOLL_MB = self.previousKlineModel.BOLL_MA;
    }
    
    self.BOLL_UP = @(self.BOLL_MB.doubleValue + 2*self.BOLL_MD.doubleValue);
    
    self.BOLL_DN = @(self.BOLL_MB.doubleValue - 2*self.BOLL_MD.doubleValue);
}


//RSI
- (void)judgeRSIIsNan
{
    if (isnan(self.RSI_6.doubleValue)) {
        
        self.RSI_6 = self.previousKlineModel.RSI_6;
    }
    if (isnan(self.RSI_12.doubleValue)) {
        
        self.RSI_12 = self.previousKlineModel.RSI_12;
    }
    if (isnan(self.RSI_24.doubleValue)) {
        
        self.RSI_24 = self.previousKlineModel.RSI_24;
    }
}

//VOL
@end
















