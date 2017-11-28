//
//  JoinUpSocketViewController.m
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/9/13.
//  Copyright © 2017年 郑旭. All rights reserved.
//
#import <Masonry.h>
#import "JoinUpSocketViewController.h"
#import "ZXAssemblyView.h"


#import <SIOSocket.h>
@interface JoinUpSocketViewController ()<AssemblyViewDelegate,ZXSocketDataReformerDelegate>
/**
 *k线实例对象
 */
@property (nonatomic,strong) ZXAssemblyView *assenblyView;
/**
 *横竖屏方向
 */
@property (nonatomic,assign) UIInterfaceOrientation orientation;
/**
 *当前绘制的指标名
 */
@property (nonatomic,strong) NSString *currentDrawQuotaName;
/**
 *所有的指标名数组
 */
@property (nonatomic,strong) NSArray *quotaNameArr;
/**
 *所有数据模型
 */
@property (nonatomic,strong) NSMutableArray *dataArray;
/**
 *
 */
@property (nonatomic,assign) TopChartContentType topChartContentType;

@property (nonatomic,strong) NSTimer  *timer;
@end

@implementation JoinUpSocketViewController
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //背景色
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self addSubviews];
    [self addConstrains];
    [self configureData];
    
    //这句话必须要,否则拖动到两端会出现白屏
    self.automaticallyAdjustsScrollViewInsets = NO;
    //
    self.topChartContentType = TopChartContentTypeWithCandle;
    //
    self.currentDrawQuotaName = self.quotaNameArr[0];
    
    
    //监测旋转:用于适配横竖屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    

    //socket请求
//    [self useSocketIO];
    
    
    //soclet数据暂时用假数据替代
    self.timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(creatFakeSocketData) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

#pragma mark - 屏幕旋转通知事件
- (void)statusBarOrientationChange:(NSNotification *)notification
{
    
    if (self.orientation == UIDeviceOrientationPortrait || self.orientation == UIDeviceOrientationPortraitUpsideDown) {
        
        //翻转为竖屏时
        [self updateConstrainsForPortrait];
        self.navigationController.navigationBar.hidden = NO;
    }else if (self.orientation==UIDeviceOrientationLandscapeLeft || self.orientation == UIDeviceOrientationLandscapeRight) {
        
        [self updateConstrsinsForLandscape];
        self.navigationController.navigationBar.hidden = YES;
    }
}
- (void)updateConstrainsForPortrait
{
    [self.assenblyView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.view).offset(200);
        make.width.mas_equalTo(TotalWidth);
        make.height.mas_equalTo(TotalHeight);
    }];
    
}
- (void)updateConstrsinsForLandscape
{
    //翻转为横屏时
    [self.assenblyView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view);
        make.width.mas_equalTo(TotalWidth);
        make.height.mas_equalTo(TotalHeight);
    }];
    
}
#pragma mark - Private Methods
- (void)addSubviews
{
    //需要加载在最上层，为了旋转的时候直接覆盖其他控件
    [self.view addSubview:self.assenblyView];
}

- (void)addConstrains
{
    if (self.orientation == UIDeviceOrientationPortrait || self.orientation == UIDeviceOrientationPortraitUpsideDown) {
        //初始为竖屏
        self.navigationController.navigationBar.hidden = NO;
        [self.assenblyView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(self.view).offset(200);
            make.left.mas_equalTo(self.view);
            make.width.mas_equalTo(TotalWidth);
            make.height.mas_equalTo(TotalHeight);
            
        }];
        
    }else if (self.orientation==UIDeviceOrientationLandscapeLeft || self.orientation == UIDeviceOrientationLandscapeRight) {
        //初始为横屏
        self.navigationController.navigationBar.hidden = YES;
        [self.assenblyView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(self.view);
            make.left.mas_equalTo(self.view);
            make.width.mas_equalTo(TotalWidth);
            make.height.mas_equalTo(TotalHeight);
            
        }];
    }
    
}

- (void)configureData
{
    
    //数据获取
    NSString *path = [[NSBundle mainBundle] pathForResource:@"kData" ofType:@"plist"];
    NSArray *kDataArr = [NSArray arrayWithContentsOfFile:path];
    
    
    //将请求到的数据数组传递过去，并且精度也是需要你自己传;
    /*
     数组中数据格式:@[@"时间戳,收盘价,开盘价,最高价,最低价,成交量",
     @"时间戳,收盘价,开盘价,最高价,最低价,成交量",
     @"时间戳,收盘价,开盘价,最高价,最低价,成交量",
     @"...",
     @"..."];
     */
    /*如果的数据格式和此demo中不同，那么你需要点进去看看，并且修改响应的取值为你的数据格式;
     修改数据格式→  ↓↓↓↓↓↓↓点它↓↓↓↓↓↓↓↓↓  ←
     */
    //数据处理
    NSArray *transformedDataArray =  [[ZXDataReformer sharedInstance] transformDataWithOriginalDataArray:kDataArr currentRequestType:@"M1"];
    [self.dataArray addObjectsFromArray:transformedDataArray];
    
    
    
    
    //绘制k线图
    [self.assenblyView drawHistoryCandleWithDataArr:self.dataArray precision:5 stackName:@"股票名" needDrawQuota:self.currentDrawQuotaName];
    
    //如若有socket实时绘制的需求，需要实现下面的方法
    //socket
    //定时器不再沿用
    [ZXSocketDataReformer sharedInstance].delegate = self;
    
}

#pragma mark - AssemblyViewDelegate
- (void)tapActionActOnQuotaArea
{
    //这里可以进行quota图的切换
    NSInteger index = [self.quotaNameArr indexOfObject:self.currentDrawQuotaName];
    if (index<self.quotaNameArr.count-1) {
        
        self.currentDrawQuotaName = self.quotaNameArr[index+1];
    }else{
        self.currentDrawQuotaName = self.quotaNameArr[0];
    }
    [self drawQuotaWithCurrentDrawQuotaName:self.currentDrawQuotaName];
}

- (void)tapActionActOnCandleArea
{
    if (self.topChartContentType==TopChartContentTypeTineLine) {
        
        [self.assenblyView switchTopChartContentWithTopChartContentType:TopChartContentTypeWithCandle];
        self.topChartContentType = TopChartContentTypeWithCandle;
    }else if (self.topChartContentType==TopChartContentTypeWithCandle)
    {
        [self.assenblyView switchTopChartContentWithTopChartContentType:TopChartContentTypeTineLine];
        self.topChartContentType = TopChartContentTypeTineLine;
    }
    
}
#pragma mark - 画指标
//在返回的数据里面。可以调用预置的指标接口绘制指标，也可以根据返回的数据自己计算数据，然后调用绘制接口进行绘制
- (void)drawQuotaWithCurrentDrawQuotaName:(NSString *)currentDrawQuotaName
{
    
    if ([currentDrawQuotaName isEqualToString:self.quotaNameArr[0]])
    {
        //macd绘制
        [self.assenblyView drawPresetQuotaWithQuotaName:PresetQuotaNameWithMACD];
    }else if ([currentDrawQuotaName isEqualToString:self.quotaNameArr[1]])
    {
        
        //KDJ绘制
        [self.assenblyView drawPresetQuotaWithQuotaName:PresetQuotaNameWithKDJ];
    }else if ([currentDrawQuotaName isEqualToString:self.quotaNameArr[2]])
    {
        
        //BOLL绘制
        [self.assenblyView drawPresetQuotaWithQuotaName:PresetQuotaNameWithBOLL];
    }else if ([currentDrawQuotaName isEqualToString:self.quotaNameArr[3]])
    {
        
        //RSI绘制
        [self.assenblyView drawPresetQuotaWithQuotaName:PresetQuotaNameWithRSI];
    }else if ([currentDrawQuotaName isEqualToString:self.quotaNameArr[4]])
    {
        
        //Vol绘制
        [self.assenblyView drawPresetQuotaWithQuotaName:PresetQuotaNameWithVOL];
    }
    
}

#pragma mark - Socket请求
//- (void)useSocketIO
//{
//    [SIOSocket socketWithHost:@"socket地址" response:^(SIOSocket *socket) {
//        NSDictionary *dic = @{};//配置信息
//        [socket emit:@"login" args:@[dic]];
//        socket.onConnect = ^{
//
//            NSLog(@"连接成功");
//        };
//        [socket on:@"quote" callback:^(SIOParameterArray *args) {
//
//            //必须在主线程执行
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//                NSArray *strArr = [args[0] componentsSeparatedByString:@","];
//                NSString *timestamp = strArr[1];
//                double newPrice = [strArr[2] doubleValue]/100000.0;
//                //socket数据处理
//                [[ZXSocketDataReformer sharedInstance] bulidNewKlineModelWithNewPrice:newPrice timestamp:[timestamp integerValue] volumn:@(100) dataArray:self.dataArray isFakeData:NO];
//                NSLog(@"socketData=%@",args);
//            });
//
//        }];
//    }];
//}
//socket 假数据
- (void)creatFakeSocketData
{
    KlineModel *model = self.dataArray[self.dataArray.count-2];
    int32_t highestPrice = model.highestPrice*100000;
    int32_t lowestPrice = model.lowestPrice*100000;
    CGFloat newPrice = (arc4random_uniform(highestPrice-lowestPrice)+lowestPrice)/100000.0;
    NSLog(@"%f",newPrice);
    NSInteger volumn = arc4random_uniform(100);
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timestamp = [date timeIntervalSince1970];
    //socket数据处理
    [[ZXSocketDataReformer sharedInstance] bulidNewKlineModelWithNewPrice:newPrice timestamp:timestamp volumn:@(volumn) dataArray:self.dataArray isFakeData:NO];
}
#pragma mark - ZXSocketDataReformerDelegate
- (void)bulidSuccessWithNewKlineModel:(KlineModel *)newKlineModel
{
    //维护控制器数据源
    if (newKlineModel.isNew) {
        
        [self.dataArray addObject:newKlineModel];
        [[ZXQuotaDataReformer sharedInstance] handleQuotaDataWithDataArr:self.dataArray model:newKlineModel index:self.dataArray.count-1];
        [self.dataArray replaceObjectAtIndex:self.dataArray.count-1 withObject:newKlineModel];
        
    }else{
        [self.dataArray replaceObjectAtIndex:self.dataArray.count-1 withObject:newKlineModel];
        
        [[ZXQuotaDataReformer alloc] handleQuotaDataWithDataArr:self.dataArray model:newKlineModel index:self.dataArray.count-1];
        
        [self.dataArray replaceObjectAtIndex:self.dataArray.count-1 withObject:newKlineModel];
    }
    //绘制最后一个蜡烛
    [self.assenblyView drawLastKlineWithNewKlineModel:newKlineModel];
}


#pragma mark - Event Response



#pragma mark - CustomDelegate



#pragma mark - Getters & Setters
- (ZXAssemblyView *)assenblyView
{
    if (!_assenblyView) {
        _assenblyView = [[ZXAssemblyView alloc] init];
        _assenblyView.delegate = self;
    }
    return _assenblyView;
}
- (UIInterfaceOrientation)orientation
{
    return [[UIApplication sharedApplication] statusBarOrientation];
}
- (NSArray *)quotaNameArr
{
    if (!_quotaNameArr) {
        _quotaNameArr = @[@"MACD",@"KDJ",@"BOLL",@"RSI",@"VOL"];
    }
    return _quotaNameArr;
}
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


@end
