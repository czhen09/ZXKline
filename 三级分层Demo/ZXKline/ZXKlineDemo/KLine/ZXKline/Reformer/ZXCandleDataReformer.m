//
//  ZXCandleDataReformer.m
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/9/13.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ZXCandleDataReformer.h"
@interface ZXCandleDataReformer()
@property (nonatomic,strong) NSString *currentRequestType;
@end

@implementation ZXCandleDataReformer
static id _instance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (NSArray<KlineModel *>*)transformDataWithDataArr:(NSArray *)dataArr currentRequestType:(NSString *)currentRequestType
{
    self.currentRequestType = currentRequestType;
    //修改数据格式  →  ↓↓↓↓↓↓↓终点到啦↓↓↓↓↓↓↓↓↓  ←
    NSMutableArray *tempArr = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    [dataArr enumerateObjectsUsingBlock:^(NSString *dataStr, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSArray *strArr = [dataStr componentsSeparatedByString:@","];
        KlineModel *model = [KlineModel new];
        model.timestamp  = [strArr[0] integerValue];
        model.timeStr = [weakSelf setTime:strArr[0]];
        model.closePrice = [strArr[1] doubleValue];
        model.openPrice = [strArr[2] doubleValue];
        model.highestPrice = [strArr[3] doubleValue];
        model.lowestPrice = [strArr[4] doubleValue];
        if (strArr.count>=6) {
            
            model.volumn = @([strArr[5] doubleValue]);
        }else{
            model.volumn = @(0);
        }
        
        model.x = idx;
        [tempArr addObject:model];
        model = nil;
    }];
    return tempArr;
}
-(NSString*)setTime:(NSString*)time{
    
    NSString *format = nil;
    //日周
    if ([self.currentRequestType containsString:@"D"]||[self.currentRequestType containsString:@"W"]||[self.currentRequestType isEqualToString:@"MN"]) {
        
        format = @"MMdd";
        //分钟
    }else if ([self.currentRequestType containsString:@"M"]||[self.currentRequestType containsString:@"H"])
    {
        format = @"MMdd HH:mm";
    }
    NSDateFormatter*formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    int timeval = [time intValue];
    NSDate*confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeval];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

@end
