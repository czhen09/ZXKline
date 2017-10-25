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
@property (nonatomic,strong) AFHTTPSessionManager *manager;
@property (nonatomic,assign) NSInteger serviceTime;
@property (nonatomic,assign) double newestPrice;

@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) KlineModel *perfectModel;
@property (nonatomic,strong) KlineModel *bulidingModel;
@property (nonatomic,assign) BOOL isOKModelBySocket;
@property (nonatomic,strong) KlineModel *lastKlineModel;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,assign) BOOL isFirst;
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

- (void)shouldToCreatTimerWithDataArray:(NSArray *)dataArray

{
    self.lastKlineModel = nil;
    self.bulidingModel = nil;
    self.isFirst = YES;
    self.lastKlineModel = dataArray.lastObject;
    //取消网络请求
    [self.manager.operationQueue cancelAllOperations];
    //取消延时创建timer的任务
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    if (self.timer) {
        
        [self invalidTimer];
    }
    __weak typeof(self) weakSelf = self;
    [self requestServiceTime:^(NSInteger timesamp) {
        NSLog(@"当前获取的服务器时间为===%ld",(long)timesamp);
        self.serviceTime = timesamp;
        [self creatFakePushData];
        NSInteger intervalTimestamp = [[ZXCalculator sharedInstance] getTimesampIntervalWithRequestType:weakSelf.currentRequestType timesamp:weakSelf.serviceTime];
        NSInteger delayTimesamp = intervalTimestamp - (weakSelf.serviceTime%intervalTimestamp);
        NSLog(@"经过%lds之后开始创建定时器",delayTimesamp);
        [self performSelector:@selector(delayActionWithParamsArr:) withObject:@[@(delayTimesamp),@(intervalTimestamp)] afterDelay:delayTimesamp];
    }];
}

- (void)delayActionWithParamsArr:(NSArray *)dataArr
{
    [self dealyToCreatTimerWithDelayTimesamp:[dataArr[0] integerValue]  intervalTimestamp:[dataArr[1] integerValue]];
}

- (void)dealyToCreatTimerWithDelayTimesamp:(NSInteger)delayTimesamp intervalTimestamp:(NSInteger)intervalTimestamp
{
    self.serviceTime += delayTimesamp;
    [self creatFakePushData];
    //NSLog(@"self.serviceTime===%ld",(long)weakSelf.serviceTime);
    NSDictionary *paraDic= @{@"serviceTime":@(intervalTimestamp)};
    //这里必须进行判断销毁以防止  界面数据刷新的问题
    NSLog(@"在%ld定时器创建",self.serviceTime);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:intervalTimestamp target:self selector:@selector(timerAction:) userInfo:paraDic repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
- (void)invalidTimer
{
    [self.timer invalidate];
    self.timer = nil;
}
- (void)timerAction:(NSTimer *)timer
{
    NSInteger intervalTimestamp = [((NSDictionary *)timer.userInfo)[@"serviceTime"] integerValue];
    self.serviceTime += intervalTimestamp;
//    if (self.serviceTime%intervalTimestamp==0) {
    
//        NSLog(@"这里需要进行推进%ld",self.serviceTime);
    [self creatFakePushData];
//        
//    }else{
//        
//        NSLog(@"错了?????%ld",(long)self.serviceTime);
//    }
}

- (void)creatFakePushData
{

    //数据结算由socket完成
    //数据推送新的由定时器完成，相比之下必须延时1秒，不然会出错
    [self performSelector:@selector(creatFakePushDataT) withObject:nil afterDelay:1];

}

- (void)creatFakePushDataT
{
    //第一次&&时间范围--->替换历史数据的最后一个
    if (self.isFirst) {
        self.isFirst = NO;
        NSInteger shouldAddTimestamp = [[ZXCalculator sharedInstance] getTimesampIntervalWithRequestType:self.currentRequestType timesamp:self.lastKlineModel.timestamp];
        if ((self.serviceTime>=self.lastKlineModel.timestamp&&self.serviceTime<self.lastKlineModel.timestamp+shouldAddTimestamp)) {
            
            return;
        }
    }
    //新增
    if (self.bulidingModel.isNew) {
        
        if ([self.delegate respondsToSelector:@selector(bulidSuccessWithNewKlineModel:)]) {
            NSLog(@"socket结算");
            [self.delegate bulidSuccessWithNewKlineModel:self.bulidingModel];
            self.bulidingModel.isNew = NO;
            self.lastKlineModel = self.bulidingModel;
            return;
        }
    }else
    {
        NSLog(@"定时器结算--在%ld新增,%f",self.serviceTime,self.lastKlineModel.closePrice);
        KlineModel *newKlineModel = [KlineModel new];
        newKlineModel.isFakeData = YES;
        newKlineModel.openPrice = self.lastKlineModel.closePrice;
        newKlineModel.closePrice = self.lastKlineModel.closePrice;
        newKlineModel.lowestPrice = self.lastKlineModel.closePrice;
        newKlineModel.highestPrice = self.lastKlineModel.closePrice;
        newKlineModel.timestamp = self.serviceTime;
        newKlineModel.timeStr = [self setTime:[NSString stringWithFormat:@"%ld",newKlineModel.timestamp]];
        newKlineModel.x = self.lastKlineModel.x+1;
        newKlineModel.volumn = self.lastKlineModel.volumn;
        newKlineModel.isNew = YES;
        if ([self.delegate respondsToSelector:@selector(bulidSuccessWithNewKlineModel:)]) {
            [self.delegate bulidSuccessWithNewKlineModel:newKlineModel];
        }
        self.lastKlineModel = newKlineModel;
    }
    
}
- (void)requestServiceTime:(void(^)(NSInteger timesamp))success
{
    
    //这里Demo使用的本地时间代替;正确的应该取下面的服务器时间
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timestamp = [date timeIntervalSince1970];
    success(timestamp);
    
    //获取服务器时间
//    NSString *urlStr = @"服务器时间校对地址";
//
//    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    self.manager.responseSerializer.acceptableContentTypes = [self.manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
//    [self.manager GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//        NSString *time = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        success([time integerValue]);
//        //        NSLog(@"ServiceTime=%@",time);
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//    }];
    
}
- (void)shouldToInvalidTimer
{
    if (!self.timer) {
        [self.manager.operationQueue cancelAllOperations];
        [[self class] cancelPreviousPerformRequestsWithTarget:self];
    }else{
        [self invalidTimer];
    }
}
- (void)bulidNewKlineModelWithNewPrice:(double)newPrice timestamp:(NSInteger)timestamp volumn:(NSNumber *)volumn dataArray:(NSMutableArray<KlineModel *> *)dataArray isFakeData:(BOOL)isFakeData
{
    KlineModel *lastKlineModel = dataArray.lastObject;
    KlineModel *newKlineMlodel = nil;
    NSInteger shouldAddTimestamp = [[ZXCalculator sharedInstance] getTimesampIntervalWithRequestType:self.currentRequestType timesamp:lastKlineModel.timestamp];
    NSInteger shouldShortTimestamp =  [self transformTimestampWithTimestamp:timestamp requestType:self.currentRequestType];
    if ((timestamp>=lastKlineModel.timestamp&&timestamp<lastKlineModel.timestamp+shouldAddTimestamp)) {
        newKlineMlodel = [KlineModel new];
        //数据微调:
        if (lastKlineModel.isFakeData) {
            
            newKlineMlodel.openPrice = newPrice;
            newKlineMlodel.closePrice = newPrice;
            newKlineMlodel.highestPrice = newPrice;
            newKlineMlodel.lowestPrice = newPrice;
            newKlineMlodel.isFakeData = NO;
            
        }else{
        
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
        self.bulidingModel.isNew = NO;
        if ([self.delegate respondsToSelector:@selector(bulidSuccessWithNewKlineModel:)]) {
            
            [self.delegate bulidSuccessWithNewKlineModel:newKlineMlodel];
        }
        self.lastKlineModel = newKlineMlodel;
    }else
    {
        if (!self.bulidingModel.isNew) {
            NSLog(@"新增模型%ld,%f",(long)timestamp,newPrice);
            self.bulidingModel.timestamp = timestamp-shouldShortTimestamp;
            self.bulidingModel.timeStr = [self setTime:[NSString stringWithFormat:@"%ld",self.bulidingModel.timestamp]];
            self.bulidingModel.x = lastKlineModel.x+1;
            self.bulidingModel.openPrice = newPrice;
            self.bulidingModel.closePrice = newPrice;
            self.bulidingModel.highestPrice = newPrice;
            self.bulidingModel.lowestPrice = newPrice;
            self.bulidingModel.isFakeData = isFakeData;
            //TODO  成交量最新的没有返回
            self.bulidingModel.volumn = @(0);
            self.bulidingModel.isNew = YES;
        }else{
            NSLog(@"维护模型%ld,%f",(long)timestamp,newPrice);
            self.bulidingModel.closePrice = newPrice;
            if (newPrice>self.bulidingModel.highestPrice) {
                
                self.bulidingModel.highestPrice = newPrice;
            }
            if (newPrice<self.bulidingModel.lowestPrice) {
                self.bulidingModel.lowestPrice = newPrice;
            }
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
- (AFHTTPSessionManager *)manager
{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (KlineModel *)bulidingModel
{
    if (!_bulidingModel) {
        _bulidingModel = [KlineModel new];
    }
    return _bulidingModel;
}
- (KlineModel *)perfectModel
{
    if (!_perfectModel) {
        _perfectModel = [KlineModel new];
    }
    return _perfectModel;
}
@end
