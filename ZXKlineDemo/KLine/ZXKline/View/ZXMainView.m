//
//  ZXMainView.m
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/8/8.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ZXMainView.h"
#import "ZXCandleCell.h"
#import "KlineModel.h"
#import <Masonry/Masonry.h>
#import "ZXJumpView.h"
#import "MALayer.h"
#import "ZXQuotaLineLayer.h"
#import "ZXQuotaColumnLayer.h"
#import "ZXQuotaSynthsisLayer.h"
#import "ZXTimeLineView.h"
#import "ZXTimeLineLayer.h"
#import "ZXRefresh.h"
//tableView总的高度

/**
 *  K线图每次缩放界限
 */
#define Y_StockChartScaleBound 0.0

/**
 *  K线的缩放因子
 */
#define Y_StockChartScaleFactor 0.1

/**
 *最小缩放值
 */
static const CGFloat scale_MinValue = CandleMinWidth;
/**
 *最大缩放值
 */
static const CGFloat scale_MaxValue = CandleMaxWidth;
static NSString *const kCandleWidth = @"kCandleWidth";
@interface  ZXMainView()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
@property (nonatomic,strong) UITableView *tableView;
/**
 *存放模型数组
 */
@property (nonatomic,strong) NSMutableArray *kLineModelArr;
/**
 *计算得到的最高价
 */
@property (nonatomic,assign) double heighestPrice;
/**
 *计算得到的最低价
 */
@property (nonatomic,assign) double lowestPrice;

/**
 *5日均线
 */
@property (nonatomic,strong) MALayer *MA5Layer;
/**
 *10日均线
 */
@property (nonatomic,strong) MALayer *MA10Layer;
/**
 *20日均线
 */
@property (nonatomic,strong) MALayer *MA20Layer;
/**
 *每屏绘制的cell的个数
 */
@property (nonatomic,assign) NSInteger needDrawKlineCount;
/**
 *每屏绘制的第一个的index
 */
@property (nonatomic,assign) NSInteger needDrawStartIndex;
/**
 *每屏绘制的模型数组
 */
@property (nonatomic,strong) NSMutableArray *needDrawKlineArr;
/**
 *tableView rowHeight
 */
@property (nonatomic,assign) CGFloat candleWidth;

/**
 * subView宽度；tableView高度
 */
@property (nonatomic,assign) CGFloat subViewWidth;
/**
 * subView高度；tableView宽度
 */
@property (nonatomic,assign) CGFloat subViewHeight;
@property (nonatomic,assign) CGFloat candleChartHeight;
@property (nonatomic,assign) CGFloat quotaChartHeight;
@property (nonatomic,assign) CGFloat middleBlankSpace;
/**
 *记录当前是否是最新值，用于判断绘制一个新的cell的时候，是添加新的还是刷新旧的
 */
@property (nonatomic,assign) BOOL isNew;
/**
 *是否第一次进入,第一次进入的时候会设置偏移到末尾，并且第一次进入的时候根据偏移计算startIndex
 */
@property (nonatomic,assign) BOOL isFirst;


//虚线间隔
@property (nonatomic,strong) NSMutableArray *needDrawDottLineIndexArr;
/**
 *随最新价格跳动的横线和label
 */
@property (nonatomic,strong) ZXJumpView *jumpView;
/**
 *横竖屏方向
 */
@property (nonatomic,assign) UIInterfaceOrientation orientation;
/**
 * 装指标layer的数组
 */
@property (nonatomic,strong) NSMutableArray *quotaLayerArr;
/**
 * 装指标数据的字典数组
 */
@property (nonatomic,strong) NSMutableArray *quotaDataArr;
/**
 * 装指标颜色的字典数组
 */
@property (nonatomic,strong) NSMutableArray *quotaColorArr;
/**
 * 装均线数据的字典数组
 */
@property (nonatomic,strong) NSMutableArray *MADataArr;

/**
 * 是否绘制均线
 */
@property (nonatomic,assign) BOOL isDrawMALayer;
/**
 * 当前所绘的指标名
 */
@property (nonatomic,strong) NSString *quotaName;



/**
 * 是否绘制k线，如果不是的话就绘制分时线
 */
@property (nonatomic,assign) BOOL isDrawKline;

@property (nonatomic,strong) ZXTimeLineLayer *timeLineLayer;


@property (nonatomic,assign) NSInteger MA1Day;
@property (nonatomic,assign) NSInteger MA2Day;
@property (nonatomic,assign) NSInteger MA3Day;


@property (nonatomic,assign) BOOL isCandleFullScreen;
@property (nonatomic,assign) BOOL isGestureScroll;
//footer刷新
@property (nonatomic,strong) ZXRefresh *refreshView;

//是否应该加载更多数据，用于手势拖曳结束的判断
@property (nonatomic,assign) BOOL isShouldToLoadMoreData;

@property (nonatomic,strong) UIView *maskView;
@end

@implementation ZXMainView
#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (self) {

        [self addSubviews];
        [self addConstrains];
        self.backgroundColor = BackgroundColor;
        self.isFirst = YES;
        self.isCandleFullScreen = NO;
        self.isNew = 0;
        self.MA1Day = 5;
        self.MA2Day = 10;
        self.MA3Day = 20;
        self.isDrawKline = YES;
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
        [self.tableView addGestureRecognizer:pinchGesture];
        
        
        [self.tableView registerClass:[ZXCandleCell class] forCellReuseIdentifier:@"cell"];
        
        
        //长按手势
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(event_longPressMethod:)];
        [self.tableView addGestureRecognizer:longPressGesture];
 
        
        //监测旋转
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
        
//        if (@available(iOS 11.0, *)) {
//            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        } else {
//            // Fallback on earlier versions
//            
//        }
    }
    return self;
}

#pragma mark - 旋转事件
- (void)statusBarOrientationChange:(NSNotification *)notification
{
    
    self.orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (self.orientation == UIDeviceOrientationPortrait || self.orientation == UIDeviceOrientationPortraitUpsideDown) {
        
        //翻转为竖屏时
        [self updateConstrainsForPortrait];
        
        
    }
    if (self.orientation==UIDeviceOrientationLandscapeLeft || self.orientation == UIDeviceOrientationLandscapeRight) {
        
        [self updateConstrsinsForLandscape];
        
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView setContentOffset:CGPointMake(0, (self.kLineModelArr.count)*self.candleWidth-self.subViewWidth-0.5)];
    });
    
}

#pragma mark - Private Methods
- (void)addSubviews
{

    [self addSubview:self.tableView];
    [self addSubview:self.maskView];
}

- (void)addConstrains
{
    
    if (self.orientation == UIDeviceOrientationPortrait || self.orientation == UIDeviceOrientationPortraitUpsideDown) {
        
        [self initPortraitContrains];
        
    }else{
        [self initLandscapeConstrains];
    }
    
}

#pragma mark - Constrains
- (void)updateConstrainsForPortrait
{
    [self updateConstrainsWithWidth:self.subViewWidth height:self.subViewHeight];
    [self drawTopKline];
    [self.tableView reloadData];
}
- (void)updateConstrsinsForLandscape
{
    [self updateConstrainsWithWidth:self.subViewWidth height:self.subViewHeight];
    [self drawTopKline];
    [self.tableView reloadData];
}


- (void)updateConstrainsWithWidth:(CGFloat)width height:(CGFloat)height
{
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo((width-height)/2);
        make.top.mas_equalTo(-(width-height)/2);
        make.width.mas_equalTo(height);
        make.height.mas_equalTo(width);
    }];
}

- (void)initLandscapeConstrains
{
    //翻转为横屏时
    [self initConstrainsWithWidth:self.subViewWidth height:self.subViewHeight];
}
- (void)initPortraitContrains
{
    
    [self initConstrainsWithWidth:self.subViewWidth height:self.subViewHeight];
    
}
- (void)initConstrainsWithWidth:(CGFloat)width height:(CGFloat)height
{

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo((width-height)/2);
        make.top.mas_equalTo(-(width-height)/2);
        make.width.mas_equalTo(height);
        make.height.mas_equalTo(width);
    }];
    
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.top.mas_equalTo(self);
        make.width.mas_equalTo(ZXLeftMargin);
        make.right.mas_equalTo(self.mas_left);
    }];
}

#pragma mark - 伸缩
//缩放：改变的是tableview的rowheight
- (void)pinchAction:(UIPinchGestureRecognizer *)sender
{
    //新的缩放
    CGFloat oldNeedDrawStartPointY = self.tableView.contentOffset.y;
    //static修饰的变量只会被赋值一次；相当于声明一个全局变量
    static CGFloat oldScale = 1.0f;
    CGFloat difValue = sender.scale - oldScale;
//    NSLog(@"difValue=====%f",difValue);
//    NSLog(@"oldScale=====%f",oldScale);
    
    if ((self.candleWidth==scale_MaxValue&&difValue>0)||(self.candleWidth==scale_MinValue&&difValue<0)) {
        return;
    }
    
    if (ABS(difValue)>Y_StockChartScaleBound) {
        
        CGFloat oldKlineWidth = self.candleWidth;
        // NSLog(@"原来的index%ld",oldNeedDrawStartIndex);
        self.candleWidth = oldKlineWidth * ((difValue > 0) ? (1+Y_StockChartScaleFactor):(1-Y_StockChartScaleFactor));
        oldScale = sender.scale;
        if (self.candleWidth < scale_MinValue) {
            
            self.candleWidth = scale_MinValue;
        }else if (self.candleWidth > scale_MaxValue)
        {
            self.candleWidth = scale_MaxValue;
        }
        //将candle宽度保存到本地
        [[NSUserDefaults standardUserDefaults] setObject:@(self.candleWidth) forKey:kCandleWidth];
    
        CGPoint centerPoint = CGPointMake(0, 0);
        if (sender.numberOfTouches == 2) {
            
            CGPoint p1 = [sender locationOfTouch:0 inView:self.tableView];
            CGPoint p2  = [sender locationOfTouch:1 inView:self.tableView];
            centerPoint = CGPointMake((p1.x+p2.x)/2, (p1.y+p2.y)/2);
            
        }
        self.tableView.rowHeight = self.candleWidth;
        [self drawTopKline];
        //这句话达到让tableview在缩放的时候能够保持缩放中心点不变；
        //实现原理：在放大缩小的时候，计算出变化后和变化前中心点的距离，然后为了保持中心点的偏移值始终保持不变，就直接在原来的偏移上加减变换的距离
        //  ceil(centerPoint.y/oldKlineWidth)中心点前面的cell个数
        //  self.rowHeight-oldKlineWidth每个cell的高度的变化
        CGFloat pinchOffsetY  = ceil(centerPoint.y/oldKlineWidth)*(self.candleWidth-oldKlineWidth)+oldNeedDrawStartPointY;
        if (pinchOffsetY<0) {
            
            pinchOffsetY = 0;
        }
        if (pinchOffsetY+self.subViewWidth>self.kLineModelArr.count*self.candleWidth) {
            
            pinchOffsetY = self.kLineModelArr.count*self.candleWidth - self.subViewWidth;
        }
        
        [self.tableView setContentOffset:CGPointMake(0, pinchOffsetY)];
    }
    
    //其实这里我也不想重复调用一次，但是不调用的时候会出现如此bug：滑动到最右边，缩小的时候，均线显示出现问题
    [self drawTopKline];

}
- (NSArray *)getNeedDrawMAArrWithNum:(NSUInteger)num
{
    NSMutableArray *needDrawMAArr = [NSMutableArray array];
    for (NSInteger i = self.needDrawStartIndex-num+1; i<=self.needDrawStartIndex + self.needDrawKlineCount-1; i++) {
        if (i>=0&&i<self.kLineModelArr.count) {
            [needDrawMAArr addObject:self.kLineModelArr[i]];
        }
    }
    NSMutableArray *averagePriceArr = [NSMutableArray array];
    [needDrawMAArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat sum = 0;
        if (idx>=num-1) {
            for (int i = 0; i<num; i++) {
                
                KlineModel *model = needDrawMAArr[idx - i];
                sum += model.closePrice;
            }
            double value = sum/num;
            [averagePriceArr addObject:@(value)];
            
        }
    }];
    return averagePriceArr;
}

#pragma mark  -  绘指标
- (void)drawQuotaWithType:(QuotaType)quotaType dataArr:(NSArray *)dataArr maxValue:(double)maxValue minValue:(double)minValue quotaName:(NSString *)quotaName subName:(NSString *)subName lineColor:(UIColor *)lineColor columnColorArr:(NSArray *)columnColorArr columnWidthType:(ColumnWidthType)columnWidthType
{
    
    
    //用@"-"填充，当数据在最开始的时候，线条不是从最开始的地方进行的，那么用@@"-"填充到跟needdrawcount的数量一致，改变数据源，进行绘制和后面获取数据；
    NSMutableArray *newDataArr = [NSMutableArray arrayWithArray:dataArr];
    if (dataArr.count<self.needDrawKlineCount) {
        
        for (int i = 0; i<(self.needDrawKlineCount-dataArr.count); i++) {
            
            [newDataArr insertObject:@"-" atIndex:0];
        }
    }
    //+==========================================

    if (![self.quotaName isEqualToString:quotaName]) {
        if (self.quotaDataArr.count>0) {
            
            [self.quotaDataArr removeAllObjects];
            //颜色
            [self.quotaColorArr removeAllObjects];
        }
        
    }
    NSDictionary *quotaDataDic = [NSDictionary dictionaryWithObjectsAndKeys:newDataArr,subName,nil];
    //颜色
    NSDictionary *quotaColorDic = [NSDictionary dictionaryWithObjectsAndKeys:lineColor,subName,nil];
    NSMutableArray *tempArr = [NSMutableArray array];
    [self.quotaDataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary *dic = (NSDictionary *)obj;
        NSString *key = [dic allKeys].firstObject;
        [tempArr addObject:key];
        
    }];
    if ([tempArr containsObject:subName]) {

        NSInteger idx = [tempArr indexOfObject:subName];
        [self.quotaDataArr replaceObjectAtIndex:idx withObject:quotaDataDic];
        //颜色
        [self.quotaColorArr replaceObjectAtIndex:idx withObject:quotaColorDic];
    }else{
        [self.quotaDataArr addObject:quotaDataDic];
        //颜色
        [self.quotaColorArr addObject:quotaColorDic];
    }
    
    switch (quotaType) {
        case QuotaTypeLine:
   
            [self drawQuotaLinewithDataArr:newDataArr maxValue:maxValue minValue:minValue quotaName:quotaName subName:(NSString *)subName lineColor:lineColor];
            break;
        case QuotaTypeColumn:
            [self drawQuotaColumnwithDataArr:newDataArr maxValue:maxValue minValue:minValue quotaName:quotaName subName:(NSString *)subName columnColorArr:columnColorArr columnWidthType:columnWidthType];
            break;
        case QuotaTypeSynthsis:
            [self drawQuotaSynthsisWithDataArr:dataArr maxValue:maxValue minValue:minValue quotaName:quotaName subName:subName synthsisColor:lineColor];
            break;
        default:
            break;
    }
}

//折线状
- (void)drawQuotaSynthsisWithDataArr:(NSArray *)dataArr maxValue:(double)maxValue minValue:(double)minValue quotaName:(NSString *)quotaName subName:(NSString *)subName synthsisColor:(UIColor *)synthsisColor
{
    
    if (![self.quotaName isEqualToString:quotaName]) {
        if (self.quotaLayerArr.count>0) {
            for (NSDictionary *dic in self.quotaLayerArr) {
                CAShapeLayer *layer = [dic allValues].firstObject;
                [layer removeFromSuperlayer];
            }
            [self.quotaLayerArr removeAllObjects];
        }
    }
    self.quotaName = quotaName;
    self.quotaMaxAssert = maxValue;
    self.quotaMinAssert = minValue;
    if (self.quotaMaxAssert!=self.quotaMinAssert) {
        
        self.quotaHeightPerPoint = self.quotaChartHeight/(self.quotaMaxAssert - self.quotaMinAssert);

    }else{
        self.quotaHeightPerPoint = 0;
    }
    ZXQuotaSynthsisLayer * MA5Layer = [[ZXQuotaSynthsisLayer alloc] initQuotaDataArr:dataArr currentDrawStartIndex:self.needDrawStartIndex rowHeight:self.candleWidth minValue:minValue heightPerpoint:self.quotaHeightPerPoint synthsisColor:synthsisColor];
    
    //在同一个指标中，不同的指标线或者指标柱，数组中包含了同名的就提换，没有就新增
    NSMutableArray *tempArr = [NSMutableArray array];
    [self.quotaLayerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary *dic = (NSDictionary *)obj;
        NSString *key = [dic allKeys].firstObject;
        [tempArr addObject:key];
        
    }];
    NSDictionary *quotaLayerDic = [NSDictionary dictionaryWithObjectsAndKeys:MA5Layer,subName,nil];
    if ([tempArr containsObject:subName]) {
        
        NSInteger idx = [tempArr indexOfObject:subName];
        
        NSDictionary *tempQuotaLayerDic = self.quotaLayerArr[idx];
        CAShapeLayer *quotaLayer = tempQuotaLayerDic[subName];
        [quotaLayer removeFromSuperlayer];
        quotaLayer = nil;
        [self.quotaLayerArr replaceObjectAtIndex:idx withObject:quotaLayerDic];
    }else{
        [self.quotaLayerArr addObject:quotaLayerDic];
    }
    [self.tableView.layer addSublayer:MA5Layer];
}

//柱状
             
- (void)drawQuotaColumnwithDataArr:(NSArray *)dataArr maxValue:(double)maxValue minValue:(double)minValue quotaName:(NSString *)quotaName subName:(NSString *)subName columnColorArr:(NSArray *)columnColorArr columnWidthType:(ColumnWidthType)columnWidthType{
    
    if (![self.quotaName isEqualToString:quotaName]) {
        if (self.quotaLayerArr.count>0) {
            for (NSDictionary *dic in self.quotaLayerArr) {
                CAShapeLayer *layer = [dic allValues].firstObject;
                    [layer removeFromSuperlayer];
            }
            [self.quotaLayerArr removeAllObjects];
        }
    }
    self.quotaName = quotaName;
    self.quotaMaxAssert = maxValue;
    self.quotaMinAssert = minValue;
    self.quotaHeightPerPoint = self.quotaChartHeight/(self.quotaMaxAssert - self.quotaMinAssert);
    ZXQuotaColumnLayer * MA5Layer = [[ZXQuotaColumnLayer alloc] initQuotaDataArr:dataArr currentDrawStartIndex:self.needDrawStartIndex rowHeight:self.candleWidth minValue:self.quotaMinAssert maxValue:self.quotaMaxAssert  heightPerpoint:self.quotaHeightPerPoint columnColorArr:columnColorArr columnWidthType:columnWidthType];
    
    
    
    NSMutableArray *tempArr = [NSMutableArray array];
    [self.quotaLayerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary *dic = (NSDictionary *)obj;
        NSString *key = [dic allKeys].firstObject;
        [tempArr addObject:key];
        
    }];
    NSDictionary *quotaLayerDic = [NSDictionary dictionaryWithObjectsAndKeys:MA5Layer,subName,nil];
    if ([tempArr containsObject:subName]) {
        
        NSInteger idx = [tempArr indexOfObject:subName];
        
        NSDictionary *tempQuotaLayerDic = self.quotaLayerArr[idx];
        CAShapeLayer *quotaLayer = tempQuotaLayerDic[subName];
        [quotaLayer removeFromSuperlayer];
        quotaLayer = nil;
        [self.quotaLayerArr replaceObjectAtIndex:idx withObject:quotaLayerDic];
    }else{
        [self.quotaLayerArr addObject:quotaLayerDic];
    }
    
    [self.tableView.layer addSublayer:MA5Layer];
    
}
//线状
- (void)drawQuotaLinewithDataArr:(NSArray *)dataArr maxValue:(double)maxValue minValue:(double)minValue quotaName:(NSString *)quotaName subName:(NSString *)subName lineColor:(UIColor *)lineColor{
    //如果指标名不同时；移除以前所有的，重新添加
    if (![self.quotaName isEqualToString:quotaName]) {
        if (self.quotaLayerArr.count>0) {
            for (NSDictionary *dic in self.quotaLayerArr) {
                CAShapeLayer *quotaLayer = [dic allValues].firstObject;
                [quotaLayer removeFromSuperlayer];
            }
            [self.quotaLayerArr removeAllObjects];
        }
    }
    self.quotaName = quotaName;
    self.quotaMaxAssert = maxValue;
    self.quotaMinAssert = minValue;
    
    if (maxValue!=minValue) {
        
        self.quotaHeightPerPoint = self.quotaChartHeight/(self.quotaMaxAssert - self.quotaMinAssert);

    }else{
        self.quotaHeightPerPoint = 0;
    }
    
    ZXQuotaLineLayer * MA5Layer = [[ZXQuotaLineLayer alloc] initQuotaDataArr:dataArr currentDrawStartIndex:self.needDrawStartIndex rowHeight:self.candleWidth minValue:self.quotaMinAssert heightPerpoint:self.quotaHeightPerPoint lineColor:lineColor quotaName:quotaName];
    
    //在同一个指标中，不同的指标线或者指标柱，数组中包含了同名的就提换，没有就新增
    NSMutableArray *tempArr = [NSMutableArray array];
    [self.quotaLayerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary *dic = (NSDictionary *)obj;
        NSString *key = [dic allKeys].firstObject;
        [tempArr addObject:key];
        
    }];
    NSDictionary *quotaLayerDic = [NSDictionary dictionaryWithObjectsAndKeys:MA5Layer,subName,nil];
    if ([tempArr containsObject:subName]) {
        
        NSInteger idx = [tempArr indexOfObject:subName];
        
        NSDictionary *tempQuotaLayerDic = self.quotaLayerArr[idx];
        CAShapeLayer *quotaLayer = tempQuotaLayerDic[subName];
        [quotaLayer removeFromSuperlayer];
        quotaLayer = nil;
        [self.quotaLayerArr replaceObjectAtIndex:idx withObject:quotaLayerDic];
    }else{
        [self.quotaLayerArr addObject:quotaLayerDic];
    }
    [self.tableView.layer addSublayer:MA5Layer];
}
#pragma mark - 返回数据
- (NSArray *)getAllKlineModelDataArr
{
    return [self.kLineModelArr copy];
}
- (NSArray *)getCurrentDrawKlineModelArr
{
    return self.needDrawKlineArr;
}
#pragma mark - 绘制历史candle
- (void)drawHistoryKlineWithDataArr:(NSArray *)dataArr
{
    [self.kLineModelArr removeAllObjects];
    self.kLineModelArr = nil;
    [self.kLineModelArr addObjectsFromArray:dataArr];
    [self drawTopKline];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView setContentOffset:CGPointMake(0, (self.kLineModelArr.count)*self.candleWidth-self.subViewWidth-0.5)];
    });
    
} 
#pragma mark - 绘制最后一个candle
- (void)drawLastKlineWithNewKlineModel:(KlineModel *)klineModel isNew:(BOOL)isNew
{
    self.isNew = isNew;
    //如果在底部的话就添加新cell
    if (self.isScrollToBottom) {
        
        [self handleNewestCellWhenScrollToBottomWithNewKlineModel:klineModel];
       
    }else{
        //没有在底部的话就仅仅添加数据不插入cell
        [self handleNewestCellWhenNotScrollToBottomWithNewKlineModel:klineModel];
    }
    
}
- (void)handleNewestCellWhenNotScrollToBottomWithNewKlineModel:(KlineModel *)klineModel
{
    
    
    if (self.isNew) {
        if (klineModel) {
            
            [self.kLineModelArr addObject:klineModel];
        }
        
    }else{
        if (klineModel) {
            
            [self.kLineModelArr replaceObjectAtIndex:self.kLineModelArr.count-1 withObject:klineModel];
        }
        
    }
    
}

//如果要修改最后一个蜡烛实时绘制的bug，需要注释掉这个方法
- (void)handleNewestCellWhenScrollToBottomWithNewKlineModel:(KlineModel *)klineModel
{
    //==0的时候需要插入一个新的cell；否则只需要刷新最后一个cell
    if (self.isNew) {
        
        KlineModel *newsDataModel =  [self calulatePositionWithKlineModel:klineModel];
        [self.kLineModelArr addObject:newsDataModel];
        [self drawTopKline];
        [self.tableView setContentOffset:CGPointMake(0, (self.kLineModelArr.count-self.needDrawKlineCount)*self.candleWidth+(self.needDrawKlineCount*self.candleWidth-self.subViewWidth))];
    }else{
        
        
        KlineModel *newsDataModel =  [self calulatePositionWithKlineModel:klineModel];
        [self.kLineModelArr replaceObjectAtIndex:self.kLineModelArr.count-1 withObject:newsDataModel];
        [self drawTopKline];
    }
}
//如果要修改最后一个蜡烛实时绘制的bug，可以打开这个方法
//- (void)handleNewestCellWhenScrollToBottomWithNewKlineModel:(KlineModel *)klineModel
//{
//    //==0的时候需要插入一个新的cell；否则只需要刷新最后一个cell
//    if (self.isNew) {
//        
//        KlineModel *newsDataModel =  [self calulatePositionWithKlineModel:klineModel];
//        [self.kLineModelArr addObject:newsDataModel];
//        
//        double oldMax = self.maxAssert;
//        double oldMin = self.minAssert;
//        
//        
//        [self calculateNeedDrawKlineArr];
//        [self calculateMaxAndMinValueWithNeedDrawArr:self.needDrawKlineArr];
//        
//        //不等的话就重绘
//        if (oldMax<self.maxAssert||oldMin>self.minAssert) {
//            
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                [self.tableView setContentOffset:CGPointMake(0, (self.kLineModelArr.count-self.needDrawKlineCount)*self.candleWidth+(self.needDrawKlineCount*self.candleWidth-self.subViewWidth))];
//            });
//            
//            [self drawTopKline];
//            
//        }else{
//            //否则就插入
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.kLineModelArr.count-1 inSection:0];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                //先增加  再偏移
//                [self.tableView beginUpdates];
//                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//                [self.tableView endUpdates];
//                [self.tableView setContentOffset:CGPointMake(0, (self.kLineModelArr.count-self.needDrawKlineCount)*self.candleWidth+(self.needDrawKlineCount*self.candleWidth-self.subViewWidth))];
//            });
//            
//            [self delegateToReturnKlieArr];
//        }
//        
//    }else{
//        
//        
//        KlineModel *newsDataModel =  [self calulatePositionWithKlineModel:klineModel];
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.kLineModelArr.count-1 inSection:0];
//        
//        [self.kLineModelArr replaceObjectAtIndex:self.kLineModelArr.count-1 withObject:newsDataModel];
//        
//        
//        CGFloat oldMax = self.maxAssert;
//        CGFloat oldMin = self.minAssert;
//        
//        
//        [self calculateNeedDrawKlineArr];
//        [self calculateMaxAndMinValueWithNeedDrawArr:self.needDrawKlineArr];
//        //如果计算出来的最新的极值不在上一次计算的极值直接的话就重绘，否则就刷新最后一个即可
//        if (oldMax<self.maxAssert||oldMin>self.minAssert) {
//            
//            [self drawTopKline];
//            
//        }else{
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                [self.tableView beginUpdates];
//                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//                [self.tableView endUpdates];
//                [self delegateToReturnKlieArr];
//            });
//            
//        }
//        
//    }
//    
//}
#pragma mark - 网络中断后填补中断数据
- (void)addBreakOffObjectsWithDataArr:(NSArray *)breakOffDataArr
{
    //约定从kliemodelArr中的最后一个model的时间作为开头，这里就只移除最后一个
    KlineModel *firstNewModel = [breakOffDataArr firstObject];
    KlineModel *lastOldModel = [self.kLineModelArr lastObject];
    
    firstNewModel.closePrice = lastOldModel.closePrice;
    if (firstNewModel.highestPrice<lastOldModel.highestPrice) {
        firstNewModel.highestPrice = lastOldModel.highestPrice;
    }
    if (firstNewModel.lowestPrice>lastOldModel.lowestPrice) {
        
        firstNewModel.lowestPrice = lastOldModel.lowestPrice;
    }
    [self.kLineModelArr removeLastObject];
    [self.kLineModelArr addObjectsFromArray:breakOffDataArr];
    [self drawTopKline];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.kLineModelArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZXCandleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSInteger intervalCount = ceil(DottedLineIntervalSpace/self.candleWidth);
    if (indexPath.row%intervalCount==0) {
        
        cell.isDrawDottedLine = YES;
    }else{
        cell.isDrawDottedLine = NO;
    }
    cell.model = self.kLineModelArr[indexPath.row];
    //这句话很关键：在cell中调用drawrect之后，cell中会出现一条线，设置透明色可以解决
    cell.backgroundColor = [UIColor clearColor];
    cell.tableViewHeight = self.subViewHeight;
    cell.candyChartHeight = self.candleChartHeight;
    cell.quotaChartHeight = self.quotaChartHeight;
    cell.middleBlankSpace = self.middleBlankSpace;
    cell.layer.backgroundColor = BackgroundColor.CGColor;
    cell.isDrawKline = self.isDrawKline;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Event Response
//TODO:拖动十字的时候在边缘的滑动处理
- (void)event_longPressMethod:(UILongPressGestureRecognizer *)longPress
{
    static CGFloat oldPositionX = 0;
    static CGFloat oldPositionY = 0;
    if(UIGestureRecognizerStateChanged == longPress.state || UIGestureRecognizerStateBegan == longPress.state)
    {
        CGPoint location = [longPress locationInView:self];
        
        //暂停滑动
        self.tableView.scrollEnabled = NO;
        oldPositionX = location.x;
        oldPositionY = location.y;
        
        //如果大于的话就bu继续走了
        if (location.x<0||location.x>self.subViewWidth) {
            
            return;
        }
        if (location.y<0||location.y>self.subViewHeight) {
            
            return;
        }
    
        [self getCandyDataWithPanPosition:location];
        
    }
    if(longPress.state == UIGestureRecognizerStateBegan)
    {
        self.tableView.scrollEnabled = NO;
    }
    if(longPress.state == UIGestureRecognizerStateEnded)
    {
        oldPositionX = 0;
        self.tableView.scrollEnabled = YES;
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.kLineModelArr.count<=self.needDrawKlineCount) {
        return;
    }
    if (!self.isGestureScroll) {
        
        [self hideCrossCurve];
    }
    [self handleMarginBugWith:scrollView];
    
    [self drawWhenScrollViewDidScrollWithScrollView:scrollView];
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.isShouldToLoadMoreData) {
        self.tableView.userInteractionEnabled = NO;
        NSLog(@"刷新");
        [self.tableView setContentInset:UIEdgeInsetsMake(44, 0, 0, 0)];
//        [self.tableView setContentOffset:CGPointMake(0, 0)];
        [self updateRefreshViewLeftSapcing:-44];
        self.refreshView.refreshState = ZXRefreshStateRefreshing;
        [self needToRequestMoreHistoryDataWithScrollView:scrollView];
        self.isShouldToLoadMoreData = NO;
        
    }else
    {
        NSLog(@"不刷新");
        self.refreshView.refreshState = ZXRefreshStateIdle;
    }
    
}

- (void)drawWhenScrollViewDidScrollWithScrollView:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y>=0) {
        self.refreshView.hidden = YES;
    }
    if (scrollView.contentOffset.y<=0) {
        if (scrollView.contentOffset.y<0) {
            self.refreshView.hidden = NO;
        }
        if (scrollView.contentOffset.y>=-43) {
            
            if (self.refreshView.refreshState==ZXRefreshStateRefreshing||self.refreshView.refreshState==ZXRefreshStateNoMoreData||self.refreshView.refreshState==ZXRefreshStateRequestFailure) {
                
                return;
            }
            self.refreshView.refreshState = ZXRefreshStatePulling;
            self.isShouldToLoadMoreData = NO;
            [self updateRefreshViewLeftSapcing:scrollView.contentOffset.y];
        }else
        {
            
            if (scrollView.contentOffset.y<-44) {
                //限制回弹的最大幅度
                //==-64的时候是第一次启动
                if (scrollView.contentOffset.y!=-64) {
                    [self.tableView setContentOffset:CGPointMake(0, (-44))];
                }
                return;
            }
            if (self.refreshView.refreshState==ZXRefreshStateRefreshing||self.refreshView.refreshState==ZXRefreshStateNoMoreData||self.refreshView.refreshState==ZXRefreshStateRequestFailure) {
                return;
            }
            self.refreshView.refreshState = ZXRefreshStateWillRefresh;
            self.isShouldToLoadMoreData = YES;
            [self updateRefreshViewLeftSapcing:scrollView.contentOffset.y];
        }
        return;
    }else if (scrollView.contentOffset.y+self.subViewWidth>=self.kLineModelArr.count*self.candleWidth)
    {
        //阻止最右侧的回弹
        [self.tableView setContentOffset:CGPointMake(0, (self.kLineModelArr.count*self.candleWidth-self.subViewWidth))];
        return;
    }else{
       
        //不在两侧的时候绘制
        [self drawTopKline];
    }
    
}
- (void)updateRefreshViewLeftSapcing:(CGFloat)leftSpacing
{
    [self.refreshView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(-44+ABS(leftSpacing));
    }];
}

- (void)needToRequestMoreHistoryDataWithScrollView:(UIScrollView *)scrollView
{
    
    if (self.kLineModelArr.count>self.needDrawKlineCount) {
        
        //请求更多数据
        if ([self.delegate respondsToSelector:@selector(shouldToRequestMoreHistoryKlineDataArr:)]) {
            
            [self.delegate shouldToRequestMoreHistoryKlineDataArr:^(RequestMoreResultType resultType, NSArray *result) {
                
                
                switch (resultType) {
                    case RequestMoreResultTypeNotRealize:
                        //模拟没有实现协议方法的时候
                        [self noMoreDataAction];
                        break;
                    case RequestMoreResultTypeSuccess:
                        
                        if (result.count>0) {
                            //成功有数据
                            [self resetTableviewPosition];
                            [self updateRefreshViewLeftSapcing:0];
                            NSInteger oldCount = self.kLineModelArr.count;
                            [self.kLineModelArr removeAllObjects];
                            [self.kLineModelArr addObjectsFromArray:result];
                            NSInteger newCount = self.kLineModelArr.count;
                            [self.tableView setContentOffset:CGPointMake(0, (newCount-oldCount)*self.candleWidth)];
                        }else{
                            //成功不再有数据
                            [self noMoreDataAction];
                        }
                        break;
                    case RequestMoreResultTypeFailure:
                        [self requestFailureAction];
                        break;
                        
                }
                
            }];
            
        }
    }
    
}

- (void)requestFailureAction
{
    self.refreshView.refreshState = ZXRefreshStateRequestFailure;
    [self performSelector:@selector(resetTableviewPosition) withObject:nil afterDelay:1];
}

- (void)noMoreDataAction
{
    self.refreshView.refreshState = ZXRefreshStateNoMoreData;
    [self performSelector:@selector(resetTableviewPosition) withObject:nil afterDelay:1];
    
}

- (void)resetTableviewPosition
{
    
    self.tableView.userInteractionEnabled = YES;
    self.refreshView.refreshState = ZXRefreshStateIdle;
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self updateRefreshViewLeftSapcing:0];
}


- (void)handleMarginBugWith:(UIScrollView *)scrollView
{
    //正对滑动到两段的绘制不全的请求，加以判断进行重绘
    if (scrollView.contentOffset.y==0||scrollView.contentOffset.y>=self.kLineModelArr.count*self.candleWidth-self.subViewWidth-self.candleWidth/2) {
        
        [self drawTopKline];
    }

}
- (void)reDrawMAWithMA1Day:(NSInteger)MA1Day MA2:(NSInteger)MA2Day MA3:(NSInteger)MA3Day
{
    self.MA1Day = MA1Day;
    self.MA2Day = MA2Day;
    self.MA3Day = MA3Day;
    [self drawTopKline];
}
- (void)drawTopKline
{
    [self.MA5Layer removeFromSuperlayer];
    self.MA5Layer = nil;
    [self.MA10Layer removeFromSuperlayer];
    self.MA10Layer = nil;
    [self.MA20Layer removeFromSuperlayer];
    self.MA20Layer = nil;
    [self.MADataArr removeAllObjects];
    [self.timeLineLayer removeFromSuperlayer];
    self.timeLineLayer = nil;
    if (self.isDrawKline) {
        
        [self drawCandle];
    }else{
        [self drawTimeLine];
    }
}
- (void)drawTimeLine
{
    [self calculateNeedDrawKlineArr];
    [self calculateTimeLineMaxAndMinValueWithNeedDrawArr:self.needDrawKlineArr];
    self.heightPerPoint = self.candleChartHeight/(self.maxAssert-self.minAssert);
    //留白计算
    //在 原来的基础上，下部留下5间距；上部留下20间距；重新计算极值
    self.minAssert = self.minAssert - CandleBottomMargin/self.heightPerPoint;
    self.maxAssert = self.maxAssert + CandleTopMargin/self.heightPerPoint;
    self.heightPerPoint = self.candleChartHeight/(self.maxAssert-self.minAssert);
    self.timeLineLayer = [[ZXTimeLineLayer alloc] initCurrentNeedDrawDataArr:self.needDrawKlineArr rowHeight:self.candleWidth minValue:self.minAssert heightPerpoint:self.heightPerPoint totalHeight:self.subViewHeight candleChartHeight:self.candleChartHeight];
    [self.tableView.layer addSublayer:self.timeLineLayer];
    [self delegateToReloadPriceView];
    [self delegateToReturnKlieArr];
    [self.tableView reloadData];
}
- (void)drawCandle
{
    if (self.kLineModelArr.count<self.needDrawKlineCount) {

        KlineModel *firstModel = self.kLineModelArr.firstObject;
        for (int i = 0; i<self.needDrawKlineCount-self.kLineModelArr.count; i++) {
            
            KlineModel *model = [KlineModel new];
            model.openPrice = firstModel.openPrice;
            model.closePrice = firstModel.openPrice;
            model.highestPrice = firstModel.openPrice;
            model.lowestPrice = firstModel.openPrice;
            model.isPlaceHolder = YES;
            [self.kLineModelArr insertObject:model atIndex:0];
        }
    }
    [self calculateNeedDrawKlineArr];
    [self calculateMaxAndMinValueWithNeedDrawArr:self.needDrawKlineArr];
    NSArray *MA5DataArr  = nil;
    NSArray *MA10DataArr = nil;
    NSArray *MA20DataArr = nil;
    if (self.isDrawMALayer) {
        
        NSMutableArray *allNeedDrawArr = [NSMutableArray array];
        MA5DataArr  = [self getNeedDrawMAArrWithNum:self.MA1Day];
        MA10DataArr = [self getNeedDrawMAArrWithNum:self.MA2Day];
        MA20DataArr = [self getNeedDrawMAArrWithNum:self.MA3Day];
        [allNeedDrawArr addObjectsFromArray:MA5DataArr];
        [allNeedDrawArr addObjectsFromArray:MA10DataArr];
        [allNeedDrawArr addObjectsFromArray:MA20DataArr];
        [self reCalculateMaxAndMinWhenDrawMALayerWithAllDataArr:allNeedDrawArr];
    }
    
    [self convertToKlinePositionModelWithNeedDrawArr:self.needDrawKlineArr];

    NSArray *newMA5Arr = [self getNewMADataArrWithOldMADataArr:MA5DataArr];
    NSArray *newMA10Arr = [self getNewMADataArrWithOldMADataArr:MA10DataArr];
    NSArray *newMA20Arr = [self getNewMADataArrWithOldMADataArr:MA20DataArr];
    if (self.isDrawMALayer) {
        
        [self drawMA5LayerWithDataArr:newMA5Arr num:self.MA1Day];
        [self drawMA10LayerWithDataArr:newMA10Arr num:self.MA2Day];
        [self drawMA20LayerWithDataArr:newMA20Arr num:self.MA3Day];
    }
    
    NSString *MA1String = [NSString stringWithFormat:@"MA%ld",(long)self.MA1Day];
    NSString *MA2String = [NSString stringWithFormat:@"MA%ld",(long)self.MA2Day];
    NSString *MA3String = [NSString stringWithFormat:@"MA%ld",(long)self.MA3Day];
    
    [self addOrReplaceMADataArrWithMADataArr:newMA5Arr MAName:MA1String];
    [self addOrReplaceMADataArrWithMADataArr:newMA10Arr MAName:MA2String];
    [self addOrReplaceMADataArrWithMADataArr:newMA20Arr MAName:MA3String];
    
    [self delegateToReloadPriceView];
    [self delegateToReturnKlieArr];

}
- (NSArray *)getNewMADataArrWithOldMADataArr:(NSArray *)oldMADataArr
{
    NSMutableArray *newDataArr = [NSMutableArray arrayWithArray:oldMADataArr];
    if (oldMADataArr.count<self.needDrawKlineCount) {
        
        for (int i = 0; i<(self.needDrawKlineCount-oldMADataArr.count); i++) {
            
            [newDataArr insertObject:@"-" atIndex:0];
        }
    }
    return newDataArr;
}


- (void)addOrReplaceMADataArrWithMADataArr:(NSArray *)MADataArr MAName:(NSString *)MAName
{
    NSDictionary *MADataDic = [NSDictionary dictionaryWithObjectsAndKeys:MADataArr,MAName,nil];
    NSMutableArray *tempArr = [NSMutableArray array];
    [self.MADataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary *dic = (NSDictionary *)obj;
        NSString *key = [dic allKeys].firstObject;
        [tempArr addObject:key];
        
    }];
    if ([tempArr containsObject:MAName]) {
        
        NSInteger idx = [tempArr indexOfObject:MAName];
        [self.MADataArr replaceObjectAtIndex:idx withObject:MADataDic];
    }else{
        [self.MADataArr addObject:MADataDic];
    }
}
#pragma mark - 切换分时图  
- (void)switchTopChartContentWithTopChartContentType:(TopChartContentType)topChartContentType
{
    switch (topChartContentType) {
        case TopChartContentTypeTineLine:
            self.isDrawKline = NO;
            break;
        case  TopChartContentTypeWithCandle:
            self.isDrawKline = YES;
            break;
        default:
            break;
    }
    [self drawTopKline];
}


#pragma mark - 绘制MA及相关计算
- (void)reCalculateMaxAndMinWhenDrawMALayerWithAllDataArr:(NSArray *)allNeedDrawArr{
    __block double tempMax = 0;
    __block double tempMin = 0;
    [allNeedDrawArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        double value = [obj doubleValue];
        if (idx==0) {
            tempMax  = value;
            tempMin = value;
        }else{
            if (tempMin>value) {
                tempMin = value;
            }else if(tempMax<value){
                tempMax = value;
            }
        }
        
    }];
    if (tempMin < self.minAssert) {
        
        self.minAssert = tempMin;
    }
    if (tempMax > self.maxAssert)
    {
        self.maxAssert = tempMax;
    }
}
- (void)drawMA20LayerWithDataArr:(NSArray *)dataArr num:(NSInteger)num
{
    [self.MA20Layer removeFromSuperlayer];
    self.MA20Layer = nil;
    NSInteger startIndex = 0;
    startIndex = self.needDrawStartIndex;
    self.MA20Layer = [[MALayer alloc] initWithNum:num needDrawMAArr:dataArr rowHeight:self.candleWidth totalHeight:self.subViewHeight minValue:self.minAssert candyChartHeight:self.candleChartHeight detailDisplayLabelHeight:0 currentDrawStartIndex:startIndex heightPerpoint:self.heightPerPoint lineColor:MA3Color];
    [self.tableView.layer addSublayer:self.MA20Layer];
}
- (void)drawMA10LayerWithDataArr:(NSArray *)dataArr num:(NSInteger)num
{
    [self.MA10Layer removeFromSuperlayer];
    self.MA10Layer = nil;
    NSInteger startIndex = 0;
    startIndex = self.needDrawStartIndex;
    self.MA10Layer = [[MALayer alloc] initWithNum:num needDrawMAArr:dataArr rowHeight:self.candleWidth totalHeight:self.subViewHeight minValue:self.minAssert candyChartHeight:self.candleChartHeight detailDisplayLabelHeight:0 currentDrawStartIndex:startIndex heightPerpoint:self.heightPerPoint lineColor:MA2Color];
    [self.tableView.layer addSublayer:self.MA10Layer];
}
- (void)drawMA5LayerWithDataArr:(NSArray *)dataArr num:(NSInteger)num
{
    [self.MA5Layer removeFromSuperlayer];
    self.MA5Layer = nil;
    NSInteger startIndex = 0;
    startIndex = self.needDrawStartIndex;
    self.MA5Layer = [[MALayer alloc] initWithNum:num needDrawMAArr:dataArr rowHeight:self.candleWidth totalHeight:self.subViewHeight minValue:self.minAssert candyChartHeight:self.candleChartHeight detailDisplayLabelHeight:0 currentDrawStartIndex:startIndex heightPerpoint:self.heightPerPoint lineColor:MA1Color];
    [self.tableView.layer addSublayer:self.MA5Layer];
}
#pragma mark - 代理返回
//return klineArr
- (void)delegateToReturnKlieArr
{
    if ([self.delegate respondsToSelector:@selector(returnCurrentDrawKlineModelArr:newKlineModel:)]) {
        
        [self.delegate returnCurrentDrawKlineModelArr:self.needDrawKlineArr newKlineModel:self.kLineModelArr.lastObject];
    }
}

//refresh priceView
- (void)delegateToReloadPriceView
{
    if ([self.delegate respondsToSelector:@selector(shouldToReloadPriceViewWithPriceArr:)]) {
        NSArray *priceArr = [self calculatePrcieArrWhenScroll];
        [self.delegate shouldToReloadPriceViewWithPriceArr:priceArr];
    }
}
- (NSArray *)calculatePrcieArrWhenScroll
{
    NSMutableArray *priceArr = [NSMutableArray array];
    
    for (int i = 4; i>=0; i--) {
        
        if (i==4) {
            
            [priceArr addObject:@(self.maxAssert)];
            continue;
        }
        if (i==0) {
            
            [priceArr addObject:@(self.minAssert)];\
            continue;
        }
        [priceArr addObject:@((self.minAssert + ((self.candleChartHeight/4)*i/self.heightPerPoint)))];;
    }
    return [priceArr copy];
}
#pragma mark - k线相关计算
- (void)calculateNeedDrawKlineArr
{
    NSInteger startIndex = 0;
    startIndex = self.needDrawStartIndex;
    [self.needDrawKlineArr removeAllObjects];
    if (startIndex < self.kLineModelArr.count) {
        if ((startIndex + self.needDrawKlineCount) < self.kLineModelArr.count) {
            
            [self.needDrawKlineArr addObjectsFromArray:[self.kLineModelArr subarrayWithRange:NSMakeRange(startIndex, self.needDrawKlineCount)]];
        }else{
            [self.needDrawKlineArr addObjectsFromArray:[self.kLineModelArr subarrayWithRange:NSMakeRange(startIndex, self.kLineModelArr.count-startIndex)]];
        }
    }
    
}
//TODO: //峰值应该为全局变量，如果最新的数据在最大最小值之间，就只刷新绘制的那个 cell，否则就要刷新全屏cell
- (void)convertToKlinePositionModelWithNeedDrawArr:(NSArray *)needDrawArr
{
    //计算   每像素的价格值 = 价格值/像素值
    self.heightPerPoint = self.candleChartHeight/(self.maxAssert-self.minAssert);
    
    //留白计算
    //在 原来的基础上，下部留下5间距；上部留下20间距；重新计算极值
    self.minAssert = self.minAssert - CandleBottomMargin/self.heightPerPoint;
    self.maxAssert = self.maxAssert + CandleTopMargin/self.heightPerPoint;
    self.heightPerPoint = self.candleChartHeight/(self.maxAssert-self.minAssert);
    
    
    //优化计算：对比计算self.kLineModelArr和self.needDrawKlineArr肯定后者更优，但是效果是一样的，在model的传输中，修改self.needDrawKlineArr中的model的时候，self.kLineModelArr数组元素中model也会跟着改变
    //经验证，地址是一个，都是指向同一个对象
    //[self calculatePositionWithOrignalArr:self.kLineModelArr];
    [self calculatePositionWithOrignalArr:self.needDrawKlineArr];
    [self.tableView reloadData];
}
- (void)calculateTimeLineMaxAndMinValueWithNeedDrawArr:(NSArray *)needDrawArr
{
    if (!needDrawArr) {
        return ;
    }
    KlineModel *modelF = needDrawArr.firstObject;
    self.minAssert = modelF.closePrice;
    self.maxAssert = modelF.closePrice;
    
    //峰值应该为全局变量，如果最新的数据在最大最小值之间，就只刷新绘制的那个 cell，否则就要刷新全屏cell
    [needDrawArr enumerateObjectsUsingBlock:^(KlineModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (model.closePrice>self.maxAssert) {
            
            self.maxAssert = model.closePrice;
        }
        if (model.closePrice<self.minAssert) {
            self.minAssert = model.closePrice;
        }
        
    }];
    
    
}

- (void)calculateMaxAndMinValueWithNeedDrawArr:(NSArray *)needDrawArr
{
    if (!needDrawArr) {
        return ;
    }
    KlineModel *modelF = needDrawArr.firstObject;
    self.minAssert = modelF.lowestPrice;
    self.maxAssert = modelF.highestPrice;
    
    //峰值应该为全局变量，如果最新的数据在最大最小值之间，就只刷新绘制的那个 cell，否则就要刷新全屏cell
    [needDrawArr enumerateObjectsUsingBlock:^(KlineModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (model.highestPrice>self.maxAssert) {
            
            self.maxAssert = model.highestPrice;
        }
        if (model.lowestPrice<self.minAssert) {
            self.minAssert = model.lowestPrice;
        }
        
    }];
    
    

}
- (void)calculatePositionWithOrignalArr:(NSMutableArray *)originalArr
{
    [originalArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KlineModel *kLineModel = obj;
        [self calulatePositionWithKlineModel:kLineModel];
    }];
}

- (KlineModel *)calulatePositionWithKlineModel:(KlineModel *)kLineModel
{
    //    KlineModel *model = [KlineModel new];
    CGFloat openPrice = (kLineModel.openPrice- self.minAssert)*self.heightPerPoint;//开盘价减去这个视图的最小价格得出差值除以每一个点代表的值 以下一样
    CGFloat closePrice = (kLineModel.closePrice- self.minAssert)*self.heightPerPoint;
    kLineModel.y = openPrice > closePrice ? closePrice : openPrice;
    kLineModel.fillColor = kLineModel.openPrice <= kLineModel.closePrice ? RISECOLOR : DROPCOLOR;
    kLineModel.strokeColor = kLineModel.openPrice <= kLineModel.closePrice ? RISECOLOR : DROPCOLOR;
    kLineModel.h = MAX(fabs(closePrice-openPrice), 1);
    kLineModel.highestPoint = (kLineModel.highestPrice - self.minAssert)*self.heightPerPoint;
    kLineModel.lowestPoint = (kLineModel.lowestPrice - self.minAssert)*self.heightPerPoint;
    kLineModel.timeStr = kLineModel.timeStr;
    return kLineModel;
}




#pragma mark - tableView—tap手势点击事件
//若有必要可以暴露接口出去
- (void)tableViewTapAction:(UIGestureRecognizer *)sender
{

    if (sender.numberOfTouches == 1) {
        
        CGPoint touchPoint = [sender locationOfTouch:0 inView:self.tableView];
//        NSLog(@"%f%f",touchPoint.x,touchPoint.y);
        CGFloat touchPointX = touchPoint.x;
        //点击事件在指标上
        if ((touchPointX>=0)&&(touchPointX<=self.quotaChartHeight))
        {
            NSLog(@"点击在指标上");
            if ([self.delegate respondsToSelector:@selector(tapActionActOnQuotaArea)]) {
                [self.delegate tapActionActOnQuotaArea];
            }
            
        }else if ((touchPointX>=self.subViewHeight-self.candleChartHeight-TimeViewHeight)&&(touchPointX<=self.subViewHeight))
        {
            NSLog(@"点击在candle上");
            if ([self.delegate respondsToSelector:@selector(tapActionActOnCandleArea)]) {
                [self.delegate tapActionActOnCandleArea];
            }
        }
        
    }
    
    [self hideCrossCurve];
    
}
- (void)hideCrossCurve
{

    if ([self.delegate respondsToSelector:@selector(shouldHideCrossCurve)]) {
        
        [self.delegate shouldHideCrossCurve];
    }
    
    //复原
    if ([self.delegate respondsToSelector:@selector(shouldRenewChartDetailView)]) {
        
        [self.delegate shouldRenewChartDetailView];
    }
    
}
#pragma mark - 根据坐标获取对应cell的数据
- (void)getCandyDataWithPanPosition:(CGPoint)position
{
    [self getCandyTimeWithPosition:position];
    [self getCandyPriceWithPositionY:position.y];
}
- (void)getCandyTimeWithPosition:(CGPoint)position
{
    CGFloat positionX = position.x;
    UIScrollView *scrollView = self.tableView;
    CGFloat startOffsetY = scrollView.contentOffset.y - self.needDrawStartIndex*self.candleWidth;
    NSLog(@"startOffsetY====%f",startOffsetY);
    //获取当前位置所在的第几个cell
    NSInteger currentPositionIndex = ABS(positionX - (self.candleWidth-startOffsetY))/self.candleWidth+1;
    
//    NSLog(@"currentPositionIndex====%ld",(long)currentPositionIndex);
    NSInteger currentPositionIndexInDataArr = 0;
    if (positionX<=(self.candleWidth - startOffsetY)) {
        
        currentPositionIndexInDataArr = self.needDrawStartIndex;
    }else{
        currentPositionIndexInDataArr = self.needDrawStartIndex + currentPositionIndex;
    }
    if (currentPositionIndexInDataArr>=self.kLineModelArr.count) {
        
        return;
    }
    // NSLog(@"当前位置的model.timeStr%@",model.timeStr);
    // NSLog(@"currentIndex===%ld",(long)currentPositionIndex);
   
    //    数据已经验证没问题
    KlineModel *moddel = self.kLineModelArr[currentPositionIndexInDataArr];
    if ([self.delegate respondsToSelector:@selector(longpressPointCandleModel:longPressPoint:)]) {
        
        [self.delegate longpressPointCandleModel:moddel longPressPoint:position];
    }
    if ([self.delegate respondsToSelector:@selector(shouldToReloadCurrentPositionTimeWithPositonX:timeStr:)]) {
        
        CGFloat newPointX = ((currentPositionIndex * self.candleWidth)+self.candleWidth/2.0)-startOffsetY;
        NSLog(@"newPointX====%f",newPointX);
        if (newPointX>self.subViewWidth) {
            
            return;
//            newPointX = self.subViewWidth;
        }
        if ((startOffsetY<self.candleWidth/2.0)&&(positionX<(self.candleWidth-startOffsetY))) {
            
            newPointX = self.candleWidth/2.0-startOffsetY;
        }else if ((startOffsetY>self.candleWidth/2.0)&&(startOffsetY<self.candleWidth)&&(positionX<(self.candleWidth-startOffsetY)))
        {
            newPointX = 0;
        }
        [self.delegate shouldToReloadCurrentPositionTimeWithPositonX:newPointX timeStr:moddel.timeStr];
        
        
        
        //滚动
        if (positionX>=(self.subViewWidth-self.candleWidth/2.0)) {
            
            self.isGestureScroll = YES;
            CGFloat offsetY = (self.needDrawStartIndex+1)*self.candleWidth;
            if (offsetY>=self.kLineModelArr.count*self.candleWidth-self.subViewWidth) {
                
                offsetY = self.kLineModelArr.count*self.candleWidth-self.subViewWidth;
            }
            [self.tableView setContentOffset:CGPointMake(0, offsetY)];
            self.isGestureScroll = NO;
        }else if (positionX<=self.candleWidth/2.0)
        {
            self.isGestureScroll = YES;
            CGFloat offsetY = (self.needDrawStartIndex-1)*self.candleWidth;
            if (offsetY<=0) {
                
                offsetY = 0;
            }
            [self.tableView setContentOffset:CGPointMake(0, offsetY)];
            self.isGestureScroll = NO;
        }
    }
    NSLog(@"highestPrice===%@,%f,%f,%f,%f,%ld",moddel.timeStr,moddel.openPrice,moddel.closePrice,moddel.highestPrice,moddel.lowestPrice,(long)moddel.timestamp);
    
    
    if (!moddel.isPlaceHolder) {
        
        [self getLongPressDetailFromQuotaWithIndexInCurrentDrawKlineModelArr:(currentPositionIndexInDataArr-self.needDrawStartIndex)];
    }

}
- (void)getLongPressDetailFromQuotaWithIndexInCurrentDrawKlineModelArr:(NSInteger)index
{
    
    NSAttributedString *quotaResultString = [self getQuotaResultStringWithDataArr:self.quotaDataArr colorArr:self.quotaColorArr index:index];
    NSAttributedString *MAResultString = [self getMAResultStringWithDataArr:self.MADataArr index:index];
    
    if ([self.delegate respondsToSelector:@selector(shouldToReloadQuotaDetailViewWithResultString:shouldToReloadCandleDetailViewWithMAResultString:)]){
        
        [self.delegate shouldToReloadQuotaDetailViewWithResultString:quotaResultString shouldToReloadCandleDetailViewWithMAResultString:MAResultString];
    }
    
}
- (NSAttributedString *)getMAResultStringWithDataArr:(NSArray *)dataArr index:(NSInteger)index
{
    __block NSMutableAttributedString *resultString = nil;
    [dataArr enumerateObjectsUsingBlock:^(NSDictionary *quotaDic, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //        NSLog(@"%@",quotaDic);
        NSArray *keys = [quotaDic allKeys];
        NSArray *values = [quotaDic allValues].firstObject;
        if (index<values.count) {
            
            if ([values[index] isKindOfClass:[NSNumber class]]) {
                
                NSNumber *value = values[index];
                NSString *result = [self transformNumberToLengthEightWithNumber:value];
                UIColor *attributedColor = nil;
                if ([keys.firstObject isEqualToString:@"MA5"]) {
                    
                    attributedColor = MA1Color;
                }else if ([keys.firstObject isEqualToString:@"MA10"])
                {
                    attributedColor = MA2Color;
                }else if ([keys.firstObject isEqualToString:@"MA20"])
                {
                    attributedColor = MA3Color;
                }
                if (!resultString) {
                    NSString *MAString = [NSString stringWithFormat:@"%@:%@",keys.firstObject,result];
                    resultString = [[NSMutableAttributedString alloc] initWithAttributedString:[self setupAttributeString:MAString color:attributedColor]];
                }else{
                    NSString *MAString = [NSString stringWithFormat:@"  %@:%@",keys.firstObject,result];
                    [resultString appendAttributedString:[self setupAttributeString:MAString color:attributedColor]];
                }
            }
        }
        
    }];
    return resultString;
}

- (NSAttributedString *)getQuotaResultStringWithDataArr:(NSArray *)dataArr colorArr:(NSArray *)colorArr index:(NSInteger)index
{
    __block NSMutableAttributedString *resultString = nil;
    [dataArr enumerateObjectsUsingBlock:^(NSDictionary *quotaDic, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //        NSLog(@"%@",quotaDic);
        NSArray *keys = [quotaDic allKeys];
        NSArray *values = [quotaDic allValues].firstObject;
        if (index<values.count) {

            if ([values[index] isKindOfClass:[NSNumber class]]) {
                
                NSNumber *value = values[index];
                NSString *result = [self transformNumberToLengthEightWithNumber:value];
                UIColor *attributedColor = nil;
                if (idx<colorArr.count) {
                    
                    NSDictionary *colorDic = colorArr[idx];
                    if ([colorDic[keys.firstObject] isKindOfClass:[UIColor class]]) {
                        attributedColor = colorDic[keys.firstObject];
                    }else{
                        attributedColor = [UIColor cyanColor];
                    }
                }else{
                    //TODO
                    attributedColor = [UIColor cyanColor];
                }
                if (![keys.firstObject isEqualToString:@"NOUSE"]) {
                    
                    if (!resultString) {
                        NSString *quotaString = [NSString stringWithFormat:@"%@:%@",keys.firstObject,result];
                        resultString = [[NSMutableAttributedString alloc] initWithAttributedString:[self setupAttributeString:quotaString color:attributedColor]];
                    }else{
                        NSString *quotaString = [NSString stringWithFormat:@"  %@:%@",keys.firstObject,result];
                        [resultString appendAttributedString:[self setupAttributeString:quotaString color:attributedColor]];
                    }
                }
            }
        }
    }];
    return resultString;
}
- (NSAttributedString *)setupAttributeString:(NSString *)text color:(UIColor *)attributedColor
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSForegroundColorAttributeName value:attributedColor range:NSMakeRange(0, text.length)];
    return [attributedString copy];
}

- (NSString *)transformNumberToLengthEightWithNumber:(NSNumber *)number
{
    NSString *priceStr = [NSString stringWithFormat:@"%.*f",self.precision,[number doubleValue]];
    return priceStr;
}
- (void)getCandyPriceWithPositionY:(CGFloat)positionY
{
    double currentPositionPrice = 0;
    NSString *currentPositionPriceStr = nil;

    if (positionY<=self.candleChartHeight+TimeViewHeight) {
        currentPositionPrice = (self.minAssert + ((self.candleChartHeight-positionY)/self.heightPerPoint));
        currentPositionPriceStr = [NSString stringWithFormat:@"%.6f",currentPositionPrice];
        
        if ([self.delegate respondsToSelector:@selector(shouldToReloadCurrentPositionPriceJumpViewWithPositonY:price:)]) {
            
            [self.delegate shouldToReloadCurrentPositionPriceJumpViewWithPositonY:positionY price:currentPositionPriceStr];
        }
   
    }else if (positionY>=self.candleChartHeight&&positionY<=self.subViewHeight)
    {
      
        currentPositionPrice = (self.quotaMinAssert + ((self.subViewHeight-positionY)/self.quotaHeightPerPoint));
        currentPositionPriceStr = [NSString stringWithFormat:@"%.6f",currentPositionPrice];
        
        if ([self.delegate respondsToSelector:@selector(shouldToReloadCurrentPositionPriceJumpViewWithPositonY:price:)]) {
            
            [self.delegate shouldToReloadCurrentPositionPriceJumpViewWithPositonY:positionY price:currentPositionPriceStr];
        }
    }
}
#pragma mark - 附件  
- (void)increaseCandleWidthWithisLongPress:(BOOL)isLongPress
{
    CGFloat   oldCandleWidth = self.candleWidth;
    NSInteger oldStartIndex = self.needDrawStartIndex;
    NSInteger oldNeedDrawCount = self.needDrawKlineCount;
    
    if (isLongPress) {
        
        self.candleWidth = CandleMaxWidth;
    }else{
        if (self.candleWidth<CandleMaxWidth) {
            
            self.candleWidth = oldCandleWidth * 1.1;
            
            if (self.candleWidth>CandleMaxWidth) {
                
                self.candleWidth = CandleMaxWidth;
            }
        }
    }
    self.tableView.rowHeight = self.candleWidth;
    [self drawTopKline];
    
    self.tableView.rowHeight = self.candleWidth;
    [self drawTopKline];
    
    //将candle宽度保存到本地
    [[NSUserDefaults standardUserDefaults] setObject:@(self.candleWidth) forKey:kCandleWidth];
    CGFloat pinchOffsetY  = (oldStartIndex+oldNeedDrawCount)*self.candleWidth-self.subViewWidth;
    [self.tableView setContentOffset:CGPointMake(0, pinchOffsetY)];
}
-  (void)decreaseCandleWidthWithisLongPress:(BOOL)isLongPress
{
    CGFloat oldCandleWidth = self.candleWidth;
    NSInteger oldStartIndex = self.needDrawStartIndex;
    NSInteger oldNeedDrawCount = self.needDrawKlineCount;
    if (isLongPress) {
        
        self.candleWidth = CandleMinWidth;
        
    }else{
        
        if (self.candleWidth>CandleMinWidth) {
            
            self.candleWidth = oldCandleWidth * 0.9;
            if (self.candleWidth<CandleMinWidth) {
                
                self.candleWidth = CandleMinWidth;
            }
        }
    }
    self.tableView.rowHeight = self.candleWidth;
    [self drawTopKline];
    //将candle宽度保存到本地
    [[NSUserDefaults standardUserDefaults] setObject:@(self.candleWidth) forKey:kCandleWidth];
    CGFloat pinchOffsetY  = (oldStartIndex+oldNeedDrawCount)*self.candleWidth-self.subViewWidth;
    if (pinchOffsetY<=0) {
        pinchOffsetY = 0;
    }
    [self.tableView setContentOffset:CGPointMake(0, pinchOffsetY)];
    
    if ((pinchOffsetY+self.subViewWidth)==self.kLineModelArr.count*self.candleWidth) {
        [self drawTopKline];
    }
}

- (void)candleFullScreen
{
    self.isCandleFullScreen = !self.isCandleFullScreen;
    [self updateConstrsinsForLandscape];
    
}


#pragma mark - Getters & Setters
- (UITableView *)tableView
{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.transform = CGAffineTransformMakeRotation(-M_PI/2);
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        NSString *candleWidth = [[NSUserDefaults standardUserDefaults] objectForKey:kCandleWidth];
        if (!candleWidth) {
            
            self.candleWidth = CandleMaxWidth;
        }else
        {
            self.candleWidth = [candleWidth floatValue];
        }
        _tableView.backgroundColor = BackgroundColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = self.candleWidth;
        _tableView.tableFooterView = [UIView new];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTapAction:)];
        [_tableView addGestureRecognizer:tap];
    }
    return _tableView;
}
- (NSInteger)needDrawStartIndex
{
    CGFloat scrollViewOffsetX = 0;
    UIScrollView *scrollView = (UIScrollView *)self.tableView;
    if (self.isFirst) {
        
        scrollViewOffsetX = (self.kLineModelArr.count-self.needDrawKlineCount)*self.candleWidth;
        self.isFirst = NO;
    }else{
        scrollViewOffsetX = scrollView.contentOffset.y<= 0 ? 0 : scrollView.contentOffset.y;
    }
    NSUInteger leftArrCount = ABS(scrollViewOffsetX/self.candleWidth);
    _needDrawStartIndex = leftArrCount;
    return _needDrawStartIndex;
}
- (NSMutableArray *)needDrawKlineArr
{
    if (!_needDrawKlineArr) {
        _needDrawKlineArr = [NSMutableArray array];
    }
    return _needDrawKlineArr;
}

-(NSMutableArray *)kLineModelArr
{
    if (!_kLineModelArr) {
        _kLineModelArr = [NSMutableArray array];
    }
    return _kLineModelArr;
}
- (NSInteger)needDrawKlineCount
{
    CGFloat width = self.subViewWidth;
    _needDrawKlineCount = ceil(width/self.candleWidth);
    return _needDrawKlineCount;
}
- (BOOL)isScrollToBottom
{
    _isScrollToBottom = self.needDrawStartIndex+1 < (self.kLineModelArr.count-self.needDrawKlineCount)?NO:YES;
    return _isScrollToBottom;
}

- (NSMutableArray *)needDrawDottLineIndexArr
{
    if (!_needDrawDottLineIndexArr) {
        _needDrawDottLineIndexArr
        = [NSMutableArray array];
    }
    return _needDrawDottLineIndexArr;
}

- (ZXJumpView *)jumpView
{
    if (!_jumpView) {
        _jumpView = [[ZXJumpView alloc] init];
        _jumpView.backgroundColor = [UIColor clearColor];
        _jumpView.hidden = YES;
    }
    return _jumpView;
}

- (NSMutableArray *)quotaLayerArr
{
    if (!_quotaLayerArr) {
        
        _quotaLayerArr = [NSMutableArray array];
    }
    return _quotaLayerArr;
}
- (NSMutableArray *)quotaDataArr
{
    if (!_quotaDataArr) {
        _quotaDataArr = [NSMutableArray array];
    }
    return _quotaDataArr;
}
- (NSMutableArray *)MADataArr
{
    if (!_MADataArr) {
        _MADataArr = [NSMutableArray array];
    }
    return _MADataArr;
}
- (UIInterfaceOrientation)orientation
{
    return [[UIApplication sharedApplication] statusBarOrientation];
}
- (NSMutableArray *)quotaColorArr
{
    if (!_quotaColorArr) {
        _quotaColorArr = [NSMutableArray array];
    }
    return _quotaColorArr;
}
- (CGFloat)subViewWidth
{
    return CandleWidth;
}
-(CGFloat)subViewHeight
{
    return self.candleChartHeight+QuotaChartHeight+MiddleBlankSpace+TimeViewHeight;
}

- (CGFloat)candleChartHeight
{

    if (self.isCandleFullScreen) {
        
        return ([UIScreen mainScreen].bounds.size.height-TimeViewHeight);
        
    }else{
        return CandleChartHeight;
    }
}
- (CGFloat)quotaChartHeight
{
    return QuotaChartHeight;
}
- (CGFloat)middleBlankSpace
{

    return MiddleBlankSpace;
}
- (BOOL)isDrawMALayer
{
    return YES;
}
- (ZXRefresh *)refreshView
{
    if (!_refreshView) {
        
        _refreshView = [[ZXRefresh alloc] init];
        [self addSubview:self.refreshView];
        [self.refreshView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self);
            make.bottom.mas_equalTo(self).offset(-(QuotaChartHeight+MiddleBlankSpace+TimeViewHeight));
            make.width.mas_equalTo(44);
            make.left.mas_equalTo(self).offset(-44);
        }];
        _refreshView.hidden = YES;
    }
    return _refreshView;
}
- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = BackgroundColor;
    }
    return _maskView;
}
@end
