//
//  ZXSocketDataReformer.m
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/9/13.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ZXSocketDataReformer.h"
#import "ZXDataReformer.h"
#import "ZXCalculator.h"
#import "ZXQuotaDataReformer.h"
#import <AFNetworking.h>
@interface ZXSocketDataReformer()
@property (nonatomic,strong) NSString *currentRequestType;
@property (nonatomic,assign) NSInteger serviceTime;
@property (nonatomic,assign) double newestPrice;
@property (nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation ZXSocketDataReformer
static id _instance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        
    });
    return _instance;
}
- (void)bulidNewKlineModelWithNewPrice:(double)newPrice timestamp:(NSInteger)timestamp volumn:(NSNumber *)volumn dataArray:(NSMutableArray<KlineModel *> *)dataArray isFakeData:(BOOL)isFakeData
{
    KlineModel *lastKlineModel = dataArray.lastObject;
    KlineModel *newKlineMlodel = nil;
    NSInteger shouldAddTimestamp = [[ZXCalculator sharedInstance] getTimesampIntervalWithRequestType:self.currentRequestType timesamp:lastKlineModel.timestamp];
    NSInteger shouldShortTimestamp =  [self transformTimestampWithTimestamp:timestamp requestType:self.currentRequestType];
    if ((timestamp>=lastKlineModel.timestamp&&timestamp<lastKlineModel.timestamp+shouldAddTimestamp)) {
        newKlineMlodel = [KlineModel new];
        newKlineMlodel.openPrice = lastKlineModel.openPrice;
        newKlineMlodel.closePrice = newPrice;
      
        if (newPrice>lastKlineModel.highestPrice) {
          
            newKlineMlodel.highestPrice = newPrice;
        }else{
          
            newKlineMlodel.highestPrice = lastKlineModel.highestPrice;
        }
        if (newPrice<lastKlineModel.lowestPrice) {
            newKlineMlodel.lowestPrice = newPrice;
        }else{
          
            newKlineMlodel.lowestPrice = lastKlineModel.lowestPrice;
        }
        newKlineMlodel.x = lastKlineModel.x;
        newKlineMlodel.isNew = NO;
        newKlineMlodel.timestamp = timestamp-shouldShortTimestamp;
        newKlineMlodel.timeStr = [self setTime:[NSString stringWithFormat:@"%ld",newKlineMlodel.timestamp]];
        //TODO  成交量最新的没有返回
        if (!volumn) {
            newKlineMlodel.volumn = @(0);
        }else{
            newKlineMlodel.volumn = volumn;
        }
        if ([self.delegate respondsToSelector:@selector(bulidSuccessWithNewKlineModel:)]) {
            
            [self.delegate bulidSuccessWithNewKlineModel:newKlineMlodel];
        }
    }else
    {
        //
        NSLog(@"在%ld新增",timestamp);
        newKlineMlodel = [KlineModel new];
        newKlineMlodel.timestamp = timestamp-shouldShortTimestamp;
        newKlineMlodel.timeStr = [self setTime:[NSString stringWithFormat:@"%ld",newKlineMlodel.timestamp]];
        newKlineMlodel.x = lastKlineModel.x+1;
        newKlineMlodel.openPrice = newPrice;
        newKlineMlodel.closePrice = newPrice;
        newKlineMlodel.highestPrice = newPrice;
        newKlineMlodel.lowestPrice = newPrice;
        newKlineMlodel.isFakeData = isFakeData;
        //TODO  成交量最新的没有返回
        newKlineMlodel.volumn = @(0);
        newKlineMlodel.isNew = YES;
      if ([self.delegate respondsToSelector:@selector(bulidSuccessWithNewKlineModel:)]) {
        
        [self.delegate bulidSuccessWithNewKlineModel:newKlineMlodel];
      }
    }
   
}
- (NSInteger)transformTimestampWithTimestamp:(NSInteger)timestamp requestType:(NSString *)requestType
{
    NSDate*lastDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekday|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:lastDate];
//    NSInteger year  = [components year];
//    NSInteger month = [components month];
    NSInteger weekday = [components weekday];
    NSInteger day = [components day];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSInteger second = [components second];
    
    
    NSInteger timesampInterval = 0;
    if ([requestType isEqualToString:@"M1"]) {
        timesampInterval = second;
//         NSLog(@"减去的M1时间为:%ld",(long)second);
    }else if ([requestType isEqualToString:@"M5"])
    {
        timesampInterval = (minute%5*60+second);
//        NSLog(@"减去的M5时间为:%ld",(long)(minute%5*60+second));
    }else if ([requestType isEqualToString:@"M15"])
    {
        timesampInterval = (minute%15*60+second);
//        NSLog(@"减去的M15时间为:%ld",(long)(minute%15*60+second));
    }else if ([requestType isEqualToString:@"M30"])
    {
        timesampInterval = (minute%30*60+second);
//        NSLog(@"减去的M30时间为:%ld",(long)(minute%30*60+second));
    }else if ([requestType isEqualToString:@"H1"])
    {
        timesampInterval = (minute*60+second);
//        NSLog(@"减去的H1时间为:%ld",(long)(minute*60+second));
    }else if ([requestType isEqualToString:@"H4"])
    {
      timesampInterval = (hour%4*60*60+minute*60+second);
      //        NSLog(@"减去的D1时间为:%ld",(long)(hour*60*60+minute*60+second));
    }else if ([requestType isEqualToString:@"D1"])
    {
        timesampInterval = (hour*60*60+minute*60+second);
//        NSLog(@"减去的D1时间为:%ld",(long)(hour*60*60+minute*60+second));
    }else if ([requestType isEqualToString:@"W1"])
    {
        timesampInterval = ((weekday-1)*24*60*60+hour*60*60+minute*60+second);
//        NSLog(@"减去的W1时间为:%ld",(long)((weekday-1)*24*60*60+hour*60*60+minute*60+second));
    }else if ([requestType isEqualToString:@"MN"])
    {

        timesampInterval = ((day-1)*24*60*60+hour*60*60+minute*60+second);
//        NSLog(@"减去的MN时间为:%ld",(long)((day-1)*24*60*60+hour*60*60+minute*60+second));
    }
    return timesampInterval;
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

- (NSString *)currentRequestType
{
    return [ZXDataReformer sharedInstance].currentRequestType;
}
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
@end
