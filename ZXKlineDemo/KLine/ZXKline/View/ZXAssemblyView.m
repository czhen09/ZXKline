//
//  ZXAssemblyView.m
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/8/10.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ZXAssemblyView.h"
#import "ZXJumpView.h"
#import "ZXMainView.h"
#import <Masonry.h>
#import "ZXPriceView.h"
#import "ZXCandleDetailView.h"
#import "ZXTimeLineView.h"
#import "ZXAccessoryView.h"
#import <AFNetworking/AFNetworking.h>
#import "ZXMessageBoxView.h"
#import "ZXTopCandleInfoView.h"
#import "ExtremumView.h"
static NSString *const kRise = @"kRise";
static NSString *const kDrop = @"kDrop";

@interface ZXAssemblyView ()<ZXMainViewDelegate,ZXAccessoryDelegate>
@property (nonatomic,strong) ZXMainView *klineMainView;
/**
 * subView宽度；tableView高度
 */
@property (nonatomic,assign) CGFloat klineMainViewWidth;
/**
 * subView高度；tableView宽度
 */
@property (nonatomic,assign) CGFloat klineMainViewHeight;

/**
 *  上部分蜡烛图高度
 */
@property (nonatomic,assign) CGFloat candleChartHeight;
/**
 *  下部指标图高度
 */
@property (nonatomic,assign) CGFloat quotaChartHeight;
/**
 *  中部预留高度
 */
@property (nonatomic,assign) CGFloat middleBlankSpace;
/**
 *横竖屏方向
 */
@property (nonatomic,assign) UIInterfaceOrientation orientation;

/**
 *右侧价格View
 */
@property (nonatomic,strong) ZXPriceView *priceView;

/**
 *  顶部蜡烛的细节显示view
 */
@property (nonatomic,strong) ZXCandleDetailView *candleDetailView;
/**
 *  中下部指标细节显示view
 */
@property (nonatomic,strong) ZXCandleDetailView *quotaDetailView;
/**
 *  下部指标右侧坐标值显示
 */
@property (nonatomic,strong) ZXPriceView *quotaView;



/**
 *随最新价格跳动的横线和label
 */
@property (nonatomic,strong) ZXJumpView *jumpView;
/**
 *附件view 包含蜡烛图的全屏---点击放大缩小
 */
@property (nonatomic,strong) ZXAccessoryView *accessoryView;

/**
 *  长按后显示的水平View和label
 */
@property (nonatomic,strong) ZXJumpView *horizontalView;


//前个界面传值
@property (nonatomic,strong) NSString *currentRequestStockName;
@property (nonatomic,strong) NSString *currentRequestType;

//
@property (nonatomic,strong) NSString *currentQuotaName;




@property (nonatomic,assign) int precision;

@property (nonatomic,strong) UIView *priceMaskView;

@property (nonatomic,strong) ZXTimeLineView *timeLineView;

@property (nonatomic,assign) NSInteger serviceTime;


@property (nonatomic,strong) NSTimer *timer;

@property (nonatomic,assign) BOOL isCandleFullScreen;

//旋转
@property (nonatomic,strong) UIButton *rotateBtn;


@property (nonatomic,strong) AFHTTPSessionManager *manager;

@property (nonatomic,strong) ZXMessageBoxView *messageBoxView;

@property (nonatomic,assign) PresetQuotaName presetQuotaName;


@property (nonatomic,strong) CAShapeLayer *topBorder;
@property (nonatomic,strong) CAShapeLayer *bottomBorder;


@property (nonatomic,strong) ZXTopCandleInfoView *topCandleInfoView;

//止盈止损委托价格线
@property (nonatomic,strong) ZXJumpView  *stopProfitLineView;
@property (nonatomic,strong) ZXJumpView  *stopLossLineView;
@property (nonatomic,strong) ZXJumpView  *delegateLineView;
@property (nonatomic,assign) double stopProfitPrice;
@property (nonatomic,assign) double stopLossPrice;
@property (nonatomic,assign) double delegatePrice;
@property (nonatomic,assign) BOOL isShowingStopHoldLine;
@property (nonatomic,assign) BOOL isShowingAllReferenceLine;

//显示极大值视图
@property (nonatomic,strong) ExtremumView  *maximumView;
@property (nonatomic,strong) ExtremumView  *minimumView;

//
@property (nonatomic,assign) ZXTopChartType topChartType;
@end

@implementation ZXAssemblyView
- (instancetype)initWithDrawJustKline:(BOOL)drawJustKline
{
    self = [super init];
    if (self) {
        [[NSUserDefaults standardUserDefaults] setBool:drawJustKline forKey:kDrawJustKline];
        self.backgroundColor = BackgroundColor;
        self.isCandleFullScreen = NO;
        [self addSubviews];
        [self addConstrains];
        [self drawBorder];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [self initWithDrawJustKline:NO];
    }
    return self;
}
#pragma mark - 旋转事件
- (void)statusBarOrientationChange:(NSNotification *)notification
{
    
    self.orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (self.orientation == UIDeviceOrientationPortrait || self.orientation == UIDeviceOrientationPortraitUpsideDown) {
        [self drawBorder];
        //翻转为竖屏时
        [self updateConstrainsForPortrait];
        self.accessoryView.hidden = YES;
        [self.rotateBtn setSelected:NO];
        if (self.isCandleFullScreen) {
            
            [self accessoryActionWithAccessoryName:AccessoryNameFullScreen isLongPress:NO];
           
        }
    }
    if (self.orientation==UIDeviceOrientationLandscapeLeft || self.orientation == UIDeviceOrientationLandscapeRight) {
        
        [self drawBorder];
        [self updateConstrsinsForLandscape];
        self.accessoryView.hidden = NO;
        [self.rotateBtn setSelected:YES];
        [self.accessoryView setFullScreenButtonSelectedWithIsFullScreen:self.isCandleFullScreen];
    }
}
#pragma mark - Private Methods
- (void)addSubviews
{
    [self addSubview:self.klineMainView];
    [self addSubview:self.priceMaskView];
    [self addSubview:self.priceView];
    [self addSubview:self.candleDetailView];
    if (!DrawJustKline) {
        [self addSubview:self.quotaDetailView];
        [self addSubview:self.quotaView];
        [self addSubview:self.accessoryView];
        [self addSubview:self.rotateBtn];
    }
    [self addSubview:self.jumpView];
    [self addSubview:self.timeLineView];
    //
    if (IsDisplayCandelInfoInTop) {
        [self addSubview:self.topCandleInfoView];
    }else{
        [self addSubview:self.messageBoxView];
    }
}

- (void)addConstrains
{
    
    if (self.orientation == UIDeviceOrientationPortrait || self.orientation == UIDeviceOrientationPortraitUpsideDown) {
        
        [self initPortraitContrains];
        
    }else{
        [self initLandscapeConstrains];
    }
    
}
- (void)initLandscapeConstrains
{
    
    [self initConstrainsWithWidth:self.klineMainViewWidth height:self.klineMainViewHeight];
}
- (void)initPortraitContrains
{
    
    [self initConstrainsWithWidth:self.klineMainViewWidth height:self.klineMainViewHeight];
    
}
- (void)initConstrainsWithWidth:(CGFloat)width height:(CGFloat)height
{

    [self.klineMainView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self).offset(TopMargin);
        make.left.mas_equalTo(self).offset(ZXLeftMargin);
        make.width.mas_equalTo(self.klineMainViewWidth);
        make.height.mas_equalTo(self.klineMainViewHeight);
    }];
    
    [self.priceView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.klineMainView);
        if (PriceCoordinateIsInRight) {
            
            make.left.mas_equalTo(self.klineMainView.mas_right);
        }else{
            make.left.mas_equalTo(ZXLeftMargin);
        }
        make.width.mas_equalTo(VerticalCoordinatesWidth);
        make.height.mas_equalTo(self.candleChartHeight);
        
    }];
    [self.priceView updateFrameWithHeight:self.candleChartHeight];
    if (!DrawJustKline) {
        [self.quotaView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.candleChartHeight+self.middleBlankSpace+TimeViewHeight+TopMargin);
            make.left.mas_equalTo(self.priceView.mas_left);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(self.quotaChartHeight);
        }];
        [self.quotaView updateFrameWithHeight:(self.quotaChartHeight)];
    }
    

    [self.candleDetailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.klineMainView);
        if (PriceCoordinateIsInRight) {
            make.left.mas_equalTo(self.klineMainView).offset(10);
            
        }else{
           make.left.mas_equalTo(self.priceView.mas_right).offset(4);
            
        }
        make.right.mas_equalTo(self.klineMainView);
        make.height.mas_equalTo(14);
        
    }];
    if (!DrawJustKline) {
        [self.quotaDetailView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(self.klineMainView).offset(self.candleChartHeight+self.middleBlankSpace+TimeViewHeight);
            if (PriceCoordinateIsInRight) {
                
                make.left.mas_equalTo(self.klineMainView).offset(10);
                
            }else
            {
                
                make.left.mas_equalTo(self.candleDetailView.mas_left);
            }
            
            make.right.mas_equalTo(self.klineMainView);
            make.height.mas_equalTo(14);
        }];
    }
   
    [self.jumpView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.mas_equalTo(100);
        make.height.mas_equalTo(14);
        make.left.mas_equalTo(self.klineMainView);
        if (PriceCoordinateIsInRight) {
            make.right.mas_equalTo(self.priceView);
        }else{
            make.right.mas_equalTo(self.klineMainView);
        }
        
    }];
    [self.priceMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.klineMainView.mas_top);
        make.bottom.mas_equalTo(self.klineMainView.mas_bottom);
        make.left.mas_equalTo(self.klineMainView.mas_right);
        make.width.mas_equalTo(VerticalCoordinatesWidth);
    }];
    [self.timeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.bottom.mas_equalTo(self.klineMainView);
        make.width.mas_equalTo(1);
        make.left.mas_equalTo(20);
    }];
    if (!DrawJustKline) {
        [self.accessoryView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            if (PriceCoordinateIsInRight) {
                make.right.mas_equalTo(self.priceView.mas_left).offset(-4);
            }else
            {
                make.right.mas_equalTo(self.klineMainView).offset(-2);
            }
            make.top.mas_equalTo(self).offset(self.candleChartHeight-26+TopMargin);
            make.width.mas_equalTo(26*3+20);
            make.height.mas_equalTo(26);
        }];
        [self.rotateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            if (PriceCoordinateIsInRight) {
                make.right.mas_equalTo(self.priceView.mas_left).offset(-4);
            }else
            {
                make.right.mas_equalTo(self.klineMainView).offset(-2);
            }
            make.bottom.mas_equalTo(self).offset(-BottomMargin);
            
            make.width.height.mas_equalTo(26);
        }];
    }
    if (IsDisplayCandelInfoInTop) {
        [self.topCandleInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_top);
            make.right.mas_equalTo(self);
            make.width.mas_equalTo(KSCREEN_WIDTH);
            make.height.mas_equalTo(40);
        }];
    }
}
- (void)updateConstrainsForPortrait
{
    
    [self updateConstrainsWithWidth:self.klineMainViewWidth height:self.klineMainViewHeight];
    if (IsDisplayCandelInfoInTop) {
        self.topCandleInfoView.backgroundColor = lightGrayBackGroundColor;
        [self.topCandleInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_top);
            make.right.mas_equalTo(self);
        }];
    }
    
}
- (void)updateConstrsinsForLandscape
{
    //翻转为横屏时
    [self updateConstrainsWithWidth:self.klineMainViewWidth height:self.klineMainViewHeight];
    if (IsDisplayCandelInfoInTop) {
        self.topCandleInfoView.backgroundColor = [UIColor clearColor];
        [self.topCandleInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_top).offset(40+TopMargin);
                if (PriceCoordinateIsInRight) {
                    
                     if (ZX_IS_IPHONE_X&&!Portrait) {
                         make.right.mas_equalTo(self).offset(-SafeAreaBottomMargin-VerticalCoordinatesWidth);
                     }else{
                         make.right.mas_equalTo(self).offset(-VerticalCoordinatesWidth);
                     }
                }else{
                    if (ZX_IS_IPHONE_X&&!Portrait) {
                        make.right.mas_equalTo(self).offset(-SafeAreaBottomMargin);
                    }
                }
        }];
    }
}
- (void)updateConstrainsWithWidth:(CGFloat)width height:(CGFloat)height
{
    [self.klineMainView mas_updateConstraints:^(MASConstraintMaker *make) {
        if (ZX_IS_IPHONE_X&&!Portrait) {
            make.left.mas_equalTo(self).offset(SafeAreaTopMargin);
        }else{
            
            make.left.mas_equalTo(self).offset(ZXLeftMargin);
        }
        make.top.mas_equalTo(self).offset(TopMargin);
        make.width.mas_equalTo(self.klineMainViewWidth);
        make.height.mas_equalTo(self.klineMainViewHeight);
    }];
    [self.priceView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(self.candleChartHeight);
        if (ZX_IS_IPHONE_X&&!Portrait) {
           
            if (PriceCoordinateIsInRight) {
                make.left.mas_equalTo(self.klineMainView.mas_right);
            }else{
                make.left.mas_equalTo(SafeAreaTopMargin);
            }
        }else{
            if (PriceCoordinateIsInRight) {
                
                make.left.mas_equalTo(self.klineMainView.mas_right);
            }else{
                make.left.mas_equalTo(ZXLeftMargin);
            }
        }
    }];
    [self.priceView updateFrameWithHeight:self.candleChartHeight];
    if (!DrawJustKline) {
        [self.quotaView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.candleChartHeight+self.middleBlankSpace+TimeViewHeight+TopMargin);
            make.height.mas_equalTo(self.quotaChartHeight);
        }];
        [self.quotaView updateFrameWithHeight:self.quotaChartHeight];
    }
    if (!DrawJustKline) {
        [self.quotaDetailView mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(self.klineMainView).offset(self.candleChartHeight+self.middleBlankSpace+TimeViewHeight);
        }];
        
        [self.accessoryView mas_updateConstraints:^(MASConstraintMaker *make) {
            if (self.isCandleFullScreen) {
                make.top.mas_equalTo(self).offset(self.candleChartHeight);
            }else{
                make.top.mas_equalTo(self).offset(self.candleChartHeight-31+TopMargin);
            }
        }];

    }
}
- (void)drawBorder
{
    [self.topBorder removeFromSuperlayer];
    self.topBorder = nil;
    self.topBorder = [CAShapeLayer layer];
    UIBezierPath *topBorderBeizer = nil;
    if (PriceCoordinateIsInRight) {
        if (ZX_IS_IPHONE_X&&!Portrait) {
            topBorderBeizer = [UIBezierPath bezierPathWithRect:CGRectMake(SafeAreaTopMargin, TopMargin, LanscapeCandleWidth, self.candleChartHeight)];
        }else{
            topBorderBeizer = [UIBezierPath bezierPathWithRect:CGRectMake(ZXLeftMargin, TopMargin, TotalWidth-ZXLeftMargin-ZXRightMargin-VerticalCoordinatesWidth, self.candleChartHeight)];
        }
       
    }else{
        if (ZX_IS_IPHONE_X&&!Portrait) {
            topBorderBeizer = [UIBezierPath bezierPathWithRect:CGRectMake(SafeAreaTopMargin, TopMargin, LanscapeCandleWidth, self.candleChartHeight)];
        }else{
            
            topBorderBeizer = [UIBezierPath bezierPathWithRect:CGRectMake(ZXLeftMargin, TopMargin, TotalWidth-ZXLeftMargin-ZXRightMargin, self.candleChartHeight)];
        }
        
    }
    self.topBorder.lineWidth = 0.2;
    self.topBorder.path = topBorderBeizer.CGPath;
    self.topBorder.strokeColor = GrateLineColor.CGColor;
    self.topBorder.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:self.topBorder];
    
    if (!DrawJustKline) {
        [self.bottomBorder removeFromSuperlayer];
        self.bottomBorder = nil;
        self.bottomBorder = [CAShapeLayer layer];
        UIBezierPath *bottomBorderBeizer = nil;
        if (PriceCoordinateIsInRight) {
            if (ZX_IS_IPHONE_X&&!Portrait) {
                bottomBorderBeizer = [UIBezierPath bezierPathWithRect:CGRectMake(SafeAreaTopMargin, self.candleChartHeight+TimeViewHeight+self.middleBlankSpace+TopMargin,LanscapeCandleWidth, self.quotaChartHeight)];
            }else{
                bottomBorderBeizer = [UIBezierPath bezierPathWithRect:CGRectMake(ZXLeftMargin, self.candleChartHeight+TimeViewHeight+self.middleBlankSpace+TopMargin,TotalWidth-ZXLeftMargin-ZXRightMargin-VerticalCoordinatesWidth, self.quotaChartHeight)];
            }
        }else{
            if (ZX_IS_IPHONE_X&&!Portrait) {
                bottomBorderBeizer = [UIBezierPath bezierPathWithRect:CGRectMake(SafeAreaTopMargin, self.candleChartHeight+TimeViewHeight+self.middleBlankSpace+TopMargin,LanscapeCandleWidth, self.quotaChartHeight)];
            }else{
                bottomBorderBeizer = [UIBezierPath bezierPathWithRect:CGRectMake(ZXLeftMargin, self.candleChartHeight+TimeViewHeight+self.middleBlankSpace+TopMargin,TotalWidth-ZXLeftMargin-ZXRightMargin, self.quotaChartHeight)];
            }
        }
        self.bottomBorder.lineWidth = 0.2;
        self.bottomBorder.path = bottomBorderBeizer.CGPath;
        self.bottomBorder.strokeColor = GrateLineColor.CGColor;
        self.bottomBorder.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:self.bottomBorder];
    }
    
}
#pragma mark - PublicMethods_指标相关
- (void)drawPresetQuotaWithQuotaName:(PresetQuotaName)presetQuotaName
{
    if (!DrawJustKline) {
        self.presetQuotaName = presetQuotaName;
        
        NSArray *currentDrawKlineModelArr = [self.klineMainView getCurrentDrawKlineModelArr];
        [self drawPresetQuotaWithQuotaName:presetQuotaName currentDrawKlineModelArr:currentDrawKlineModelArr];
    }
    
}

- (void)drawPresetQuotaWithQuotaName:(PresetQuotaName)presetQuotaName     currentDrawKlineModelArr:(NSArray *)currentDrawKlineModelArr
{
    switch (presetQuotaName) {
        case PresetQuotaNameWithMACD:
            [self drawPresetMACDQuotaWithCurrentDrawKlineModelArr:currentDrawKlineModelArr];
            break;
        case PresetQuotaNameWithKDJ:
            [self drawPresetKDJQuotaWithCurrentDrawKlineModelArr:currentDrawKlineModelArr];
            break;
        case PresetQuotaNameWithBOLL:
            [self drawPresetBOLLQuotaWithCurrentDrawKlineModelArr:currentDrawKlineModelArr];
            break;
        case PresetQuotaNameWithRSI:
            [self drawPresetRSIQuotaWithCurrentDrawKlineModelArr:currentDrawKlineModelArr];
            break;
        case PresetQuotaNameWithVOL:
            [self drawPresetVOLQuotaWithCurrentDrawKlineModelArr:currentDrawKlineModelArr];
            break;
        default:
            break;
    }
    
}
//VOL
- (void)drawPresetVOLQuotaWithCurrentDrawKlineModelArr:(NSArray *)currentDrawKlineModelArr
{
    //VOL
    NSMutableArray *VOLDataArr = [NSMutableArray array];
    //VOL_MA5
    NSMutableArray *VOL_MA5DataArr = [NSMutableArray array];
    //VOL_MA10
    NSMutableArray *VOL_MA10DataArr = [NSMutableArray array];
    //VOL_MA20
    NSMutableArray *VOL_MA20DataArr = [NSMutableArray array];
    //COlORARR
    NSMutableArray *VOLColorArr = [NSMutableArray array];
    [currentDrawKlineModelArr enumerateObjectsUsingBlock:^(KlineModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!model.isPlaceHolder) {
            [VOLDataArr addObject:model.volumn];
            if (model.x>=4) {
                [VOL_MA5DataArr addObject:model.volumn_MA5];
            }
            if (model.x>=9) {
                [VOL_MA10DataArr addObject:model.volumn_MA10];
            }
            if (model.x>=19) {
                [VOL_MA20DataArr addObject:model.volumn_MA20];
            }
            if (model.openPrice<=model.closePrice) {
                [VOLColorArr addObject:RISECOLOR];
            }else{
                [VOLColorArr addObject:DROPCOLOR];
            }
        }
        
    }];
    //极值
    NSDictionary *resultDic = [[ZXCalculator sharedInstance] calculateMaxAndMinValueWithDataArr:@[VOLDataArr,VOL_MA5DataArr,VOL_MA10DataArr,VOL_MA20DataArr]];
    CGFloat maxValue = [resultDic[kMaxValue] floatValue];
    CGFloat minValue = 0;
    CGFloat quotaHeightPerPoint = QuotaChartHeight/(maxValue - minValue);
    minValue = minValue - QuotaBottomMargin/quotaHeightPerPoint;
    maxValue = maxValue + QuotaTopMargin/quotaHeightPerPoint;
    
    
    [self drawQuotaWithType:QuotaTypeColumn dataArr:VOLDataArr maxValue:maxValue minValue:minValue quotaName:@"VOL" subName:@"VOL" lineColor:nil columnColorArr:VOLColorArr columnWidthType:ColumnWidthTypeEqualCandle];
    [self drawQuotaWithType:QuotaTypeLine dataArr:VOL_MA5DataArr maxValue:maxValue minValue:minValue quotaName:@"VOL" subName:@"MA5" lineColor:MA1Color columnColorArr:nil columnWidthType:0];
    [self drawQuotaWithType:QuotaTypeLine dataArr:VOL_MA10DataArr maxValue:maxValue minValue:minValue quotaName:@"VOL" subName:@"MA10" lineColor:MA2Color columnColorArr:nil columnWidthType:0];
    [self drawQuotaWithType:QuotaTypeLine dataArr:VOL_MA20DataArr maxValue:maxValue minValue:minValue quotaName:@"VOL" subName:@"MA20" lineColor:MA3Color columnColorArr:nil columnWidthType:0];
}
//RSI
- (void)drawPresetRSIQuotaWithCurrentDrawKlineModelArr:(NSArray *)currentDrawKlineModelArr
{
 
    //RSI_6
    NSMutableArray *RSI_6DataArr = [NSMutableArray array];
    //RSI_12
    NSMutableArray *RSI_12DataArr = [NSMutableArray array];
    //RSI_24
    NSMutableArray *RSI_24DataArr = [NSMutableArray array];
    
    [currentDrawKlineModelArr enumerateObjectsUsingBlock:^(KlineModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (model.x>=5) {
            [RSI_6DataArr addObject:model.RSI_6];
        }
        if (model.x>=11) {
            [RSI_12DataArr addObject:model.RSI_12];
        }
        if (model.x>=23) {
            [RSI_24DataArr addObject:model.RSI_24];
        }
        
    }];
    //极值
    NSDictionary *resultDic = [[ZXCalculator sharedInstance] calculateMaxAndMinValueWithDataArr:@[RSI_6DataArr,RSI_12DataArr,RSI_24DataArr]];
    CGFloat maxValue = [resultDic[kMaxValue] floatValue];
    CGFloat minValue = [resultDic[kMinValue] floatValue];
    CGFloat quotaHeightPerPoint = QuotaChartHeight/(maxValue - minValue);
    minValue = minValue - QuotaBottomMargin/quotaHeightPerPoint;
    maxValue = maxValue + QuotaTopMargin/quotaHeightPerPoint;
    
    [self drawQuotaWithType:QuotaTypeLine dataArr:RSI_6DataArr maxValue:maxValue minValue:minValue quotaName:@"RSI(6,12,24)" subName:@"RSI6" lineColor:QuotaRSI_6 columnColorArr:nil columnWidthType:0];
    [self drawQuotaWithType:QuotaTypeLine dataArr:RSI_12DataArr maxValue:maxValue minValue:minValue quotaName:@"RSI(6,12,24)" subName:@"RSI12" lineColor:QuotaRSI_12 columnColorArr:nil columnWidthType:0];
    [self drawQuotaWithType:QuotaTypeLine dataArr:RSI_24DataArr maxValue:maxValue minValue:minValue quotaName:@"RSI(6,12,24)" subName:@"RSI24" lineColor:QuotaRSI_24 columnColorArr:nil columnWidthType:0];
}
- (void)drawPresetBOLLQuotaWithCurrentDrawKlineModelArr:(NSArray *)currentDrawKlineModelArr
{
    //
    NSMutableArray *openDataArr = [NSMutableArray array];
    //
    NSMutableArray *closeDataArr = [NSMutableArray array];
    //
    NSMutableArray *highDataArr = [NSMutableArray array];
    //
    NSMutableArray *lowDataArr = [NSMutableArray array];
    
 
    //K
    NSMutableArray *BOOL_UPataArr = [NSMutableArray array];
    //D
    NSMutableArray *BOOL_MBataArr = [NSMutableArray array];
    //J
    NSMutableArray *BOOL_DNataArr = [NSMutableArray array];
    

    [currentDrawKlineModelArr enumerateObjectsUsingBlock:^(KlineModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (model.isPlaceHolder) {
            [openDataArr addObject:@"-"];
            [closeDataArr addObject:@"-"];
            [highDataArr addObject:@"-"];
            [lowDataArr addObject:@"-"];
        }else{
            [openDataArr addObject:@(model.openPrice)];
            [closeDataArr addObject:@(model.closePrice)];
            [highDataArr addObject:@(model.highestPrice)];
            [lowDataArr addObject:@(model.lowestPrice)];
        }
        if (model.x>=19) {
            
            [BOOL_UPataArr addObject:model.BOLL_UP];
            [BOOL_MBataArr addObject:model.BOLL_MB];
            [BOOL_DNataArr addObject:model.BOLL_DN];
        }
    }];
    //极值
    NSDictionary *resultDic = [[ZXCalculator sharedInstance] calculateMaxAndMinValueWithDataArr:@[openDataArr,closeDataArr,highDataArr,lowDataArr,BOOL_DNataArr,BOOL_MBataArr,BOOL_UPataArr]];
    CGFloat maxValue = [resultDic[kMaxValue] floatValue];
    CGFloat minValue = [resultDic[kMinValue] floatValue];
    CGFloat quotaHeightPerPoint = QuotaChartHeight/(maxValue - minValue);
    minValue = minValue - QuotaBottomMargin/quotaHeightPerPoint;
    maxValue = maxValue + QuotaTopMargin/quotaHeightPerPoint;

    
    //价格折线
    NSArray *synthsisArr = @[openDataArr,closeDataArr,highDataArr,lowDataArr];
    [self drawQuotaWithType:QuotaTypeSynthsis dataArr:synthsisArr maxValue:maxValue minValue:minValue quotaName:@"BOLL" subName:@"NOUSE" lineColor:BlueColor columnColorArr:nil columnWidthType:0];
    
    //
    [self drawQuotaWithType:QuotaTypeLine dataArr:BOOL_UPataArr maxValue:maxValue minValue:minValue quotaName:@"BOLL" subName:@"UPPER" lineColor:QuotaBOOLUPCOLOR columnColorArr:nil columnWidthType:0];
    [self drawQuotaWithType:QuotaTypeLine dataArr:BOOL_MBataArr maxValue:maxValue minValue:minValue quotaName:@"BOLL" subName:@"MID" lineColor:QuotaBOOLMBCOLOR columnColorArr:nil columnWidthType:0];
    [self drawQuotaWithType:QuotaTypeLine dataArr:BOOL_DNataArr maxValue:maxValue minValue:minValue quotaName:@"BOLL" subName:@"LOWER" lineColor:QuotaBOOLDNCOLOR columnColorArr:nil columnWidthType:0];
    

}
- (void)drawPresetKDJQuotaWithCurrentDrawKlineModelArr:(NSArray *)currentDrawKlineModelArr
{
    //K
    NSMutableArray *KDJ_KDataArr = [NSMutableArray array];
    //D
    NSMutableArray *KDJ_DDataArr = [NSMutableArray array];
    //J
    NSMutableArray *KDJ_JDataArr = [NSMutableArray array];
    
    [currentDrawKlineModelArr enumerateObjectsUsingBlock:^(KlineModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (model.x>=8) {
            
            [KDJ_KDataArr addObject:model.KDJ_K];
            [KDJ_DDataArr addObject:model.KDJ_D];
            [KDJ_JDataArr addObject:model.KDJ_J];
        }
        
    }];
    //极值
    NSDictionary *resultDic = [[ZXCalculator sharedInstance] calculateMaxAndMinValueWithDataArr:@[KDJ_KDataArr,KDJ_DDataArr,KDJ_JDataArr]];
    CGFloat maxValue = [resultDic[kMaxValue] floatValue];
    CGFloat minValue = [resultDic[kMinValue] floatValue];
    CGFloat quotaHeightPerPoint = QuotaChartHeight/(maxValue - minValue);
    minValue = minValue - QuotaBottomMargin/quotaHeightPerPoint;
    maxValue = maxValue + QuotaTopMargin/quotaHeightPerPoint;
    
    [self drawQuotaWithType:QuotaTypeLine dataArr:KDJ_KDataArr maxValue:maxValue minValue:minValue quotaName:@"KDJ" subName:@"K" lineColor:QuotaKCOLOR columnColorArr:nil columnWidthType:0];
    [self drawQuotaWithType:QuotaTypeLine dataArr:KDJ_DDataArr maxValue:maxValue minValue:minValue quotaName:@"KDJ" subName:@"D" lineColor:QuotaDCOLOR columnColorArr:nil columnWidthType:0];
    [self drawQuotaWithType:QuotaTypeLine dataArr:KDJ_JDataArr maxValue:maxValue minValue:minValue quotaName:@"KDJ" subName:@"J" lineColor:QuotaJCOLOR columnColorArr:nil columnWidthType:0];
}

- (void)drawPresetMACDQuotaWithCurrentDrawKlineModelArr:(NSArray *)currentDrawKlineModelArr
{
    
    //DIF
    NSMutableArray *DIFDataArr = [NSMutableArray array];
    //DEA
    NSMutableArray *DEADataArr = [NSMutableArray array];
    //MACD
    NSMutableArray *MACDDataArr = [NSMutableArray array];
    
    for (KlineModel *model in currentDrawKlineModelArr) {
        if (!model.isPlaceHolder) {
            [DIFDataArr addObject:model.DIF];
            [DEADataArr addObject:model.DEA];
            [MACDDataArr addObject:model.MACD];
        }
    }
    //极值
    NSDictionary *resultDic = [[ZXCalculator sharedInstance] calculateMaxAndMinValueWithDataArr:@[DIFDataArr,DEADataArr,MACDDataArr]];
    CGFloat maxValue = [resultDic[kMaxValue] floatValue];
    CGFloat minValue = [resultDic[kMinValue] floatValue];
    CGFloat quotaHeightPerPoint = QuotaChartHeight/(maxValue - minValue);
    minValue = minValue - QuotaBottomMargin/quotaHeightPerPoint;
    maxValue = maxValue + QuotaTopMargin/quotaHeightPerPoint;

 
    [self drawQuotaWithType:QuotaTypeColumn dataArr:MACDDataArr maxValue:maxValue minValue:minValue quotaName:@"MACD" subName:@"MACD" lineColor:nil columnColorArr:nil columnWidthType:ColumnWidthTypeEqualCandle];
    [self drawQuotaWithType:QuotaTypeLine dataArr:DIFDataArr maxValue:maxValue minValue:minValue quotaName:@"MACD" subName:@"DIFF" lineColor:QuotaDIFFCOLOR columnColorArr:nil columnWidthType:0];
    [self drawQuotaWithType:QuotaTypeLine dataArr:DEADataArr maxValue:maxValue minValue:minValue quotaName:@"MACD" subName:@"DEA" lineColor:QuotaDEACOLOR columnColorArr:nil columnWidthType:0];
    
}
//画指标
- (void)drawQuotaWithType:(QuotaType)quotaType dataArr:(NSArray *)dataArr maxValue:(double)maxValue minValue:(double)minValue quotaName:(NSString *)quotaName subName:subName lineColor:(UIColor *)lineColr columnColorArr:(NSArray *)columnColorArr columnWidthType:(ColumnWidthType)columnWidthType
{

    [self.klineMainView drawQuotaWithType:quotaType dataArr:dataArr maxValue:maxValue minValue:minValue quotaName:quotaName subName:subName lineColor:lineColr columnColorArr:columnColorArr columnWidthType:columnWidthType];
    if (![self.currentQuotaName isEqualToString:quotaName]) {
        
        [self.quotaDetailView reloadQuotaDetailViewWithQuotaDetailString:quotaName];
    }
    self.currentQuotaName = quotaName;
    if (!DrawJustKline) {
        [self.quotaView reloadPriceLabelTextWithPriceArr:@[@(maxValue),@(minValue)] precision:self.precision];
        
        if (minValue<0&&maxValue>0) {
            
            double quotaHeightPerPoint = (self.quotaChartHeight)/(maxValue - minValue);
            double zeroValue = ABS(minValue*quotaHeightPerPoint);
            
            [self.quotaView refreshCurrentPositionPriceLabelPositonY:zeroValue];
        }else{
            [self.quotaView hideZeroLabel:YES];
        }
    }
    
    
}
#pragma mark - PublicMethods_重绘MA  
- (void)reDrawMAWithMA1Day:(NSInteger)MA1Day MA2:(NSInteger)MA2Day MA3:(NSInteger)MA3Day
{
    [self.klineMainView reDrawMAWithMA1Day:MA1Day MA2:MA2Day MA3:MA3Day];
}

#pragma mark - PublicMethods_蜡烛图绘制最新
- (void)drawLastKlineWithNewKlineModel:(KlineModel *)klineModel

{
    BOOL isNew = klineModel.isNew;
    [self.klineMainView drawLastKlineWithNewKlineModel:klineModel isNew:isNew];
    if (!self.klineMainView.isScrollToBottom) {
        
        [self updateJumpViewWithNewKlineModel:klineModel];
    }
    
}

#pragma mark - PrivateMethods_蜡烛图绘制历史
- (void)drawHistoryCandleWithDataArr:(NSArray<KlineModel *> *)dataArr precision:(int)precision stackName:(NSString *)stackName needDrawQuota:(NSString *)needDrawQuotaName
{
    self.currentQuotaName = needDrawQuotaName;
    self.currentRequestStockName = stackName;
    self.currentRequestType = [ZXDataReformer sharedInstance].currentRequestType;
    if (IsDisplayStockOrQuotaName) {
    
        [self.candleDetailView  jointWithNewDetailString:[NSString stringWithFormat:@"%@ %@",self.currentRequestStockName,self.currentRequestType]];
    }
 
    //欢迎来到内部二层世界
    self.precision = precision;
    self.klineMainView.precision = precision;
    [self.klineMainView drawHistoryKlineWithDataArr:dataArr];

}



- (NSString *)getStringWithDouble:(double)doubleValue
{
    return [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%.*f",self.precision,doubleValue]];
}

- (void)updateJumpViewWithNewKlineModel:(KlineModel *)newKlineModel
{
    if (self.topChartType==ZXTopChartTypeTimeLine) {
        self.jumpView.hidden = YES;
        return;
    }
    //
    if (!newKlineModel) {
        
        return;
    }
    CGFloat  newPrice = newKlineModel.closePrice;
    //根据最新的价格计算对应的point的值
    if (newPrice>=self.klineMainView.minAssert&&newPrice<=self.klineMainView.maxAssert) {
        
        self.jumpView.hidden = NO;
    }else{
        self.jumpView.hidden = YES;
    }
    CGFloat newPointY = self.candleChartHeight - (newPrice-self.klineMainView.minAssert)*self.klineMainView.heightPerPoint;
    NSString *priceStr = [NSString stringWithFormat:@"%.*f",self.precision,newPrice];
    UIColor *jumpViewBackgroundColor = nil;
    if (newKlineModel.openPrice>newKlineModel.closePrice) {
        
        jumpViewBackgroundColor = DROPCOLOR;
    }else{
        jumpViewBackgroundColor = RISECOLOR;
    }
    [self.jumpView updateJumpViewWithNewPrice:priceStr backgroundColor:jumpViewBackgroundColor];
    //没有数据的时候newpointY==Nan;
    if (isnan(newPointY)) {
        newPointY = 0;
    }
    [self.jumpView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(newPointY-14/2+TopMargin));
    }];
}
-(NSString*)setTime:(NSString*)time{
    
    NSString *format = nil;
    //日周
    if ([self.currentRequestType containsString:@"D"]||[self.currentRequestType containsString:@"W"]) {
        
        format = @"MMdd";
    //分钟
    }else if ([self.currentRequestType containsString:@"M"]||[self.currentRequestType containsString:@"H"])
    {
        format = @"MMdd HH:mm";
    }//月？
    else{
        format = @"MM";
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
#pragma mark - PrivateMethods_切换蜡烛图和指标
- (void)switchTopChartWithTopChartType:(ZXTopChartType)topChartType
{
    self.topChartType = topChartType;
    if (self.topChartType==ZXTopChartTypeCandle) {
        self.maximumView.hidden =  NO;
        self.minimumView.hidden = NO;
    }else{
        self.maximumView.hidden =  YES;
        self.minimumView.hidden = YES;
    }
    [self.klineMainView switchTopChartWithTopChartType:topChartType];
}
#pragma mark - PublicMethods_刷新止盈止损委托价格线
- (void)hideStopHoldLine
{
    self.isShowingStopHoldLine = NO;
    self.stopLossLineView.hidden = YES;
    self.stopProfitLineView.hidden = YES;
}
- (void)updateStopHoldLineWithStopProfitPrice:(double)stopProfitPrice stopLossPrice:(double)stopLossPrice
{
    self.isShowingStopHoldLine = YES;
    [self updateStopProfitLineViewWithPrice:stopProfitPrice];
    [self updateStopLossLineViewWithPrice:stopLossPrice];
}
- (void)updateStopProfitLineViewWithPrice:(double)stopProfitPrice
{
    self.stopProfitPrice = stopProfitPrice;
    if (stopProfitPrice>self.klineMainView.maxAssert||stopProfitPrice<self.klineMainView.minAssert) {
        self.stopProfitLineView.hidden = YES;
        return;
    }
    CGFloat pointY = [self transformPriceToPointWithPrice:stopProfitPrice];
    self.stopProfitLineView.hidden = NO;
    NSString *priceStr = [NSString stringWithFormat:@"%.*f",self.precision,stopProfitPrice];
    [self.stopProfitLineView updateJumpViewWithNewPrice:priceStr backgroundColor:RISECOLOR typeText:@"TP"];
    [self.stopProfitLineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(pointY-14/2+TopMargin));
    }];
}
- (void)updateStopLossLineViewWithPrice:(double)stopLossPrice
{
    self.stopLossPrice = stopLossPrice;
    if (stopLossPrice>self.klineMainView.maxAssert||stopLossPrice<self.klineMainView.minAssert) {
        self.stopProfitLineView.hidden = YES;
        return;
    }
    CGFloat pointY = [self transformPriceToPointWithPrice:stopLossPrice];
    self.stopLossLineView.hidden = NO;
    NSString *priceStr = [NSString stringWithFormat:@"%.*f",self.precision,stopLossPrice];
    [self.stopLossLineView updateJumpViewWithNewPrice:priceStr backgroundColor:DROPCOLOR typeText:@"SL"];
    [self.stopLossLineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(pointY-14/2+TopMargin));
    }];
}
- (CGFloat )transformPriceToPointWithPrice:(double)price
{
    CGFloat newPointY = self.candleChartHeight - (price-self.klineMainView.minAssert)*self.klineMainView.heightPerPoint;
    //没有数据的时候newpointY==Nan;
    if (isnan(newPointY)) {
        newPointY = 0;
    }
    return newPointY;
}
- (void)updateStopHoldLineWithStopProfitPrice:(double)stopProfitPrice stopLossPrice:(double)stopLossPrice delegatePrice:(double)delegatePrice
{
    self.isShowingAllReferenceLine = YES;
    [self updateStopProfitLineViewWithPrice:stopProfitPrice];
    [self updateStopLossLineViewWithPrice:stopLossPrice];
    [self updateDelegateLineViewWithPrice:delegatePrice];
}
- (void)updateDelegateLineViewWithPrice:(double)delegatePrice
{
    self.delegatePrice = delegatePrice;
    if (delegatePrice>self.klineMainView.maxAssert||delegatePrice<self.klineMainView.minAssert) {
        self.delegateLineView.hidden = YES;
        return;
    }
    CGFloat pointY = [self transformPriceToPointWithPrice:delegatePrice];
    self.delegateLineView.hidden = NO;
    NSString *priceStr = [NSString stringWithFormat:@"%.*f",self.precision,delegatePrice];
    [self.delegateLineView updateJumpViewWithNewPrice:priceStr backgroundColor:[UIColor colorWithRed:60/255.0 green:151/255.0 blue:199/255.0 alpha:1] typeText:@"委托价格"];
    [self.delegateLineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(pointY-14/2+TopMargin));
    }];
}
- (void)hideAllReferenceLine
{
    self.isShowingAllReferenceLine = NO;
    self.delegateLineView.hidden = YES;
    self.stopLossLineView.hidden = YES;
    self.stopProfitLineView.hidden = YES;
}
#pragma mark - CustomDelegate
- (void)shouldToReloadPriceViewWithPriceArr:(NSArray *)priceArr
{
    [self.priceView reloadPriceLabelTextWithPriceArr:priceArr precision:self.precision];
}

- (void)shouldRenewChartDetailView
{
    //手势结束的回调
    //candleDetail复原
    if (IsDisplayStockOrQuotaName) {
        [self.candleDetailView  jointWithNewDetailString:[NSString stringWithFormat:@"%@ %@",self.currentRequestStockName,self.currentRequestType]];
    }else{
        [self.candleDetailView  jointWithNewDetailString:@""];
    }
    if (!DrawJustKline) {
        //quotaDetail复原
        [self.quotaDetailView reloadQuotaDetailViewWithQuotaDetailString:self.currentQuotaName];
    }
    
}
- (void)shouldHideCrossCurve
{
    
    if (!self.horizontalView.hidden) {
        if ([self.delegate respondsToSelector:@selector(longPressEnd)]) {
            [self.delegate longPressEnd];
        }
    }
    self.horizontalView.hidden = YES;
    self.timeLineView.hidden = YES;
    if (IsDisplayCandelInfoInTop) {
        self.topCandleInfoView.hidden = YES;
    }else{
        self.messageBoxView.hidden = YES;
    }
}
- (void)shouldToReloadCurrentPositionPriceJumpViewWithPositonY:(CGFloat)positionY price:(NSString *)price
{
    //更新横线位置
    [self.horizontalView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(positionY-14/2+TopMargin);

    }];
    if (positionY>self.candleChartHeight&&positionY<self.candleChartHeight+TimeViewHeight+self.middleBlankSpace) {
        
        self.horizontalView.alpha = 0;
    }else{
        self.horizontalView.alpha = 1;
    }
    [self.horizontalView updateJumpViewWithNewPrice:price backgroundColor:nil];
    [self.horizontalView layoutIfNeeded];
    self.horizontalView.hidden = NO;
}
- (void)shouldToReloadCurrentPositionTimeWithPositonX:(CGFloat)positionX timeStr:(NSString *)timeStr
{
    [self.timeLineView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        if (ZX_IS_IPHONE_X&&!Portrait) {
            make.left.mas_equalTo(positionX+SafeAreaTopMargin);
        }else
        {
            make.left.mas_equalTo(positionX+5);
        }
        
    }];
    [self.timeLineView layoutIfNeeded];
    self.timeLineView.hidden = NO;
    if (self.topChartType==ZXTopChartTypeTimeLine) {
        timeStr = [timeStr substringWithRange:NSMakeRange(timeStr.length-5, 5)];
    }
    [self.timeLineView updateTimeWithTimeString:timeStr];
}
- (void)returnCurrentDrawKlineModelArr:(NSArray *)currentDrawKlineModelArr newKlineModel:(KlineModel *)newKlineModel
{
    
    if ([self.delegate respondsToSelector:@selector(returnCurrentDrawKlineModelArr:)]) {
        
        [self.delegate returnCurrentDrawKlineModelArr:currentDrawKlineModelArr];
    }
    
    if (!DrawJustKline) {
        [self drawPresetQuotaWithQuotaName:self.presetQuotaName currentDrawKlineModelArr:currentDrawKlineModelArr];
    }

    //在这个地方返回需要实时显示的横线，可以达到没有socket返回的时候依然能够显示横线
    if (newKlineModel) {
        
        [self updateJumpViewWithNewKlineModel:newKlineModel];
    }
    
    //刷新止盈止亏线
    if (self.isShowingStopHoldLine) {
       [self updateStopHoldLineWithStopProfitPrice:self.stopProfitPrice stopLossPrice:self.stopLossPrice];
    }else if (self.isShowingAllReferenceLine){
        [self updateStopHoldLineWithStopProfitPrice:self.stopProfitPrice stopLossPrice:self.stopLossPrice delegatePrice:self.delegatePrice];
    }
}
- (void)shouldToRequestMoreHistoryKlineDataArr:(SuccessBlock)succ
{
    
    if ([self.delegate respondsToSelector:@selector(shouldToRequestMoreHistoryKlineDataArr:)]) {
        
        [self.delegate shouldToRequestMoreHistoryKlineDataArr:^(RequestMoreResultType resultType, NSArray *result) {
            
            succ(resultType,result);
        }];
    }else
    {
        NSArray *tempArr = @[];
        succ(RequestMoreResultTypeNotRealize,tempArr);
    }
}
- (void)tapActionActOnQuotaArea
{
    if (self.timeLineView.hidden) {
        
        if ([self.delegate respondsToSelector:@selector(tapActionActOnQuotaArea)]) {
            [self.delegate tapActionActOnQuotaArea];
        }
    
    }
  
}
- (void)tapActionActOnCandleArea
{
    if (self.timeLineView.hidden) {
        
        if ([self.delegate respondsToSelector:@selector(tapActionActOnCandleArea)]) {
            [self.delegate tapActionActOnCandleArea];
        }
   
    }
}


- (void)shouldToReloadQuotaDetailViewWithResultString:(NSAttributedString *)QuotaResultString shouldToReloadCandleDetailViewWithMAResultString:(NSAttributedString *)MAResultString
{
    if (!DrawJustKline) {
        NSMutableAttributedString *attriQuota = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  ",self.currentQuotaName]];
        if (QuotaResultString) {
            [attriQuota appendAttributedString:QuotaResultString];
        }
        [self.quotaDetailView reloadQuotaDetailViewWithQuotaAttributedString:attriQuota];
    }
    if (IsDisplayStockOrQuotaName) {
        NSMutableAttributedString *attriMA = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@  ",self.currentRequestStockName,self.currentRequestType]];
        if (MAResultString) {
            [attriMA appendAttributedString:MAResultString];
        }
        [self.candleDetailView jointWithNewAttributedString:attriMA];
    }else{
        [self.candleDetailView jointWithNewAttributedString:MAResultString];
    }
    
}
- (void)longpressPointCandleModel:(KlineModel *)klineModel longPressPoint:(CGPoint)point
{
    if ([self.delegate respondsToSelector:@selector(longPressBegin)]) {
        [self.delegate longPressBegin];
    }
    if (IsDisplayCandelInfoInTop) {
        //项目中单独k线图的时候不显示
        if (!DrawJustKline) {
            //上部
            self.topCandleInfoView.hidden = NO;
            [self.topCandleInfoView updateInfoWithModel:klineModel precision:self.precision];
        }
    }else{
        
        //下部
        if (point.y>self.candleChartHeight) {
            
            self.messageBoxView.hidden  = YES;
            return;
        }
        
        self.messageBoxView.hidden = NO;
        
        ArrowPosition arrowPosition = 0;
        
        CGFloat candleChartCenterX = self.klineMainViewWidth/2.0;
        CGFloat candleChartCenterY = self.candleChartHeight/2.0;
        
        
        CGFloat height = 60;
        CGFloat width = 0;
        if (KSCREEN_WIDTH==414) {
            
            width = (self.klineMainViewWidth-20)/2;
        }else{
            
            width = (self.klineMainViewWidth)/2;
        }
        
        if (width>180) {
            
            width=180;
        }
        
        //第一象限
        if (point.x>candleChartCenterX&&point.y<candleChartCenterY) {
            
            arrowPosition = ArrowPositionRightTop;
            [self.messageBoxView mas_updateConstraints:^(MASConstraintMaker *make) {
                
                make.centerY.mas_equalTo(self.horizontalView).offset(height/2+2);
                make.right.mas_equalTo(self.timeLineView);
                make.width.mas_equalTo(width);
                make.height.mas_equalTo(60);
            }];
        }
        //第二象限
        else if (point.x<candleChartCenterX&&point.y<candleChartCenterY)
        {
            arrowPosition = ArrowPositionLeftTop;
            [self.messageBoxView mas_updateConstraints:^(MASConstraintMaker *make) {
                
                make.centerY.mas_equalTo(self.horizontalView).offset(height/2+2);
                make.right.mas_equalTo(self.timeLineView).offset(width);
                make.width.mas_equalTo(width);
                make.height.mas_equalTo(60);
            }];
        }
        //第三象限
        else if (point.x<candleChartCenterX&&point.y>candleChartCenterY)
        {
            arrowPosition = ArrowPositionLeftBottom;
            [self.messageBoxView mas_updateConstraints:^(MASConstraintMaker *make) {
                
                make.centerY.mas_equalTo(self.horizontalView).offset(-(height/2+2));
                make.right.mas_equalTo(self.timeLineView).offset(width);
                make.width.mas_equalTo(width);
                make.height.mas_equalTo(60);
            }];
        }
        //第四象限
        else if (point.x>candleChartCenterX&&point.y>candleChartCenterY)
        {
            arrowPosition = ArrowPositionRightBottom;
            [self.messageBoxView mas_updateConstraints:^(MASConstraintMaker *make) {
                
                make.centerY.mas_equalTo(self.horizontalView).offset(-(height/2+2));
                make.right.mas_equalTo(self.timeLineView);
                make.width.mas_equalTo(width);
                make.height.mas_equalTo(60);
            }];
        }
        else if (point.x<candleChartCenterX&&point.y==candleChartCenterY)
        {
            arrowPosition = ArrowPositionLeftCenter;
            [self.messageBoxView mas_updateConstraints:^(MASConstraintMaker *make) {
                
                make.centerY.mas_equalTo(self.horizontalView);
                make.right.mas_equalTo(self.timeLineView).offset(width);
                make.width.mas_equalTo(width);
                make.height.mas_equalTo(60);
            }];
        }
        else if (point.x>candleChartCenterX&&point.y==candleChartCenterY)
        {
            arrowPosition = ArrowPositionRightCenter;
            [self.messageBoxView mas_updateConstraints:^(MASConstraintMaker *make) {
                
                make.centerY.mas_equalTo(self.horizontalView);
                make.right.mas_equalTo(self.timeLineView);
                make.width.mas_equalTo(width);
                make.height.mas_equalTo(60);
            }];
        }
        
        UIColor *textColor = nil;
        if (klineModel.openPrice>klineModel.closePrice) {
            
            textColor = DROPCOLOR;
        }else{
            textColor = RISECOLOR;
        }
        
        if (klineModel.isPlaceHolder) {
            
            [self.messageBoxView setNeedsDisplayWithOpen:@"0.0" close:@"0.0" high:@"0.0" low:@"0.0" arrowPosition:arrowPosition];
        }else{
            [self.messageBoxView setNeedsDisplayWithOpen:[NSString stringWithFormat:@"%.*f",self.precision,klineModel.openPrice] close:[NSString stringWithFormat:@"%.*f",self.precision,klineModel.closePrice] high:[NSString stringWithFormat:@"%.*f",self.precision,klineModel.highestPrice] low:[NSString stringWithFormat:@"%.*f",self.precision,klineModel.lowestPrice] arrowPosition:arrowPosition];
        }
        
    }

}
#pragma mark - 显示/更新极值
- (void)updateMaxAndMinViewWithMaxPoint:(CGPoint)maxPoint minPoint:(CGPoint)minPoint maxValue:(double)maxValue minValue:(double)minValue
{

    //60是视图宽度
    if (maxPoint.x>SCREEN_WIDTH/2.0) {
        [self.maximumView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(maxPoint.x-60+ZXLeftMargin);
            make.bottom.mas_equalTo(self).offset(-maxPoint.y);
        }];
        [self.maximumView updateExtremumViewWithArrowPositionLeft:NO price:maxValue];
    }else{
        [self.maximumView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(maxPoint.x+ZXLeftMargin);
            make.bottom.mas_equalTo(self).offset(-maxPoint.y);
        }];
        [self.maximumView updateExtremumViewWithArrowPositionLeft:YES price:maxValue];
    }
    
    
    //
    if (minPoint.x>SCREEN_WIDTH/2.0) {
        [self.minimumView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(minPoint.x-60+ZXLeftMargin);
            make.bottom.mas_equalTo(self).offset(-minPoint.y+10);
        }];
        [self.minimumView updateExtremumViewWithArrowPositionLeft:NO price:minValue];
    }else{
        [self.minimumView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(minPoint.x+ZXLeftMargin);
            make.bottom.mas_equalTo(self).offset(-minPoint.y+10);
        }];
        [self.minimumView updateExtremumViewWithArrowPositionLeft:YES price:minValue];
    }
}
#pragma mark - ZXAccessoryDelegate
- (void)accessoryActionWithAccessoryName:(AccessoryName)accessoryName isLongPress:(BOOL)isLongPress
{
    switch (accessoryName) {
        case AccessoryNameFullScreen:
            self.isCandleFullScreen = !self.isCandleFullScreen;
            [self updateConstrsinsForLandscape];
            [self.klineMainView candleFullScreen];
            if (self.isCandleFullScreen) {
                
                self.rotateBtn.hidden = YES;
            }else{
                self.rotateBtn.hidden = NO;
            }
            [self drawBorder];
            [self.timeLineView updateFrameWhenCandleFullScreenWithCandleHeight:self.candleChartHeight];
            break;
        case AccessoryNameIncrease:
            [self.klineMainView increaseCandleWidthWithisLongPress:isLongPress];
            break;
        case AccessoryNameDecrease:
            [self.klineMainView decreaseCandleWidthWithisLongPress:isLongPress];
            break;
        default:
            break;
    }
}
#pragma mark - RorateButtonAction
- (void)changeScreenOrientation:(UIButton *)sender
{
    [sender setSelected:!sender.selected];
    if (sender.selected) {
        
        [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
    }else{
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
    }
}
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}
#pragma mark - ZXDropDownAssembleViewDelegate
- (void)didSelectAtColumn:(NSInteger)column Row:(NSInteger)row
{
    if ([self.delegate respondsToSelector:@selector(didSelectAtColumn:Row:)]) {
        
        [self.delegate didSelectAtColumn:column Row:row];
    }
}
#pragma mark - Getters & Setters
- (UIInterfaceOrientation)orientation
{
    return [[UIApplication sharedApplication] statusBarOrientation];
}
- (CGFloat)klineMainViewHeight
{
    return self.candleChartHeight+QuotaChartHeight+MiddleBlankSpace+TimeViewHeight;
}
- (CGFloat)klineMainViewWidth
{
    return CandleWidth;
}
- (CGFloat)candleChartHeight
{
    if (self.isCandleFullScreen) {
        
        return ([UIScreen mainScreen].bounds.size.height-TimeViewHeight-TopMargin);
        
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
- (ZXMainView *)klineMainView
{
    if (!_klineMainView) {
        _klineMainView = [[ZXMainView alloc] init];
        _klineMainView.delegate = self;
        
    }
    return _klineMainView;
}

- (ZXPriceView *)priceView
{
    if (!_priceView) {
        _priceView = [[ZXPriceView alloc] initWithFrame:CGRectMake(0,0,0,0) PriceArr:@[@"",@"",@"",@"",@""]];
        _priceView.backgroundColor = [UIColor clearColor];
        _priceView.userInteractionEnabled = NO;
    }
    return _priceView;
}

- (ZXCandleDetailView *)candleDetailView
{
    if (!_candleDetailView) {
        _candleDetailView = [[ZXCandleDetailView alloc] init];
        _candleDetailView.userInteractionEnabled = NO;
    }
    return _candleDetailView;
}
- (ZXCandleDetailView *)quotaDetailView
{
    if (!_quotaDetailView) {
        _quotaDetailView = [[ZXCandleDetailView alloc] init];
        _quotaDetailView.userInteractionEnabled = NO;
    }
    return _quotaDetailView;
}
- (ZXJumpView *)jumpView
{
    if (!_jumpView) {
        _jumpView = [[ZXJumpView alloc] initWithIsJump:YES];
        _jumpView.hidden = YES;
        _jumpView.userInteractionEnabled = NO;
    }
    return _jumpView;
}
- (ZXJumpView *)stopProfitLineView
{
    if (!_stopProfitLineView) {
        _stopProfitLineView = [[ZXJumpView alloc] initWithIsJump:NO];
        _stopProfitLineView.hidden = YES;
        _stopProfitLineView.userInteractionEnabled = NO;
        [self addSubview:_stopProfitLineView];
        [_stopProfitLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(100);
            make.height.mas_equalTo(14);
            make.left.mas_equalTo(self.klineMainView);
            if (PriceCoordinateIsInRight) {
                make.right.mas_equalTo(self.priceView);
            }else{
                make.right.mas_equalTo(self.klineMainView);
            }
        }];
    }
    return _stopProfitLineView;
}
- (ZXJumpView *)stopLossLineView
{
    if (!_stopLossLineView) {
        _stopLossLineView = [[ZXJumpView alloc] initWithIsJump:NO];
        _stopLossLineView.hidden = YES;
        _stopLossLineView.userInteractionEnabled = NO;
        [self addSubview:_stopLossLineView];
        [_stopLossLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(100);
            make.height.mas_equalTo(14);
            make.left.mas_equalTo(self.klineMainView);
            if (PriceCoordinateIsInRight) {
                make.right.mas_equalTo(self.priceView);
            }else{
                make.right.mas_equalTo(self.klineMainView);
            }
        }];
    }
    return _stopLossLineView;
}
- (ZXJumpView *)delegateLineView
{
    if (!_delegateLineView) {
        _delegateLineView = [[ZXJumpView alloc] initWithIsJump:NO];
        _delegateLineView.hidden = YES;
        _delegateLineView.userInteractionEnabled = NO;
        [self addSubview:_delegateLineView];
        [_delegateLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(100);
            make.height.mas_equalTo(14);
            make.left.mas_equalTo(self.klineMainView);
            if (PriceCoordinateIsInRight) {
                make.right.mas_equalTo(self.priceView);
            }else{
                make.right.mas_equalTo(self.klineMainView);
            }
        }];
    }
    return _delegateLineView;
}
- (ZXJumpView *)horizontalView
{
    if (!_horizontalView) {
        _horizontalView = [[ZXJumpView alloc] initWithIsJump:NO];
        _horizontalView.clipsToBounds = YES;
        _horizontalView.userInteractionEnabled = NO;
        _horizontalView.backgroundColor = [UIColor clearColor];
        [self addSubview:_horizontalView];
        [_horizontalView mas_makeConstraints:^(MASConstraintMaker *make) {

            make.top.mas_equalTo(self).offset(TopMargin);
            make.left.mas_equalTo(self.klineMainView);
            if (PriceCoordinateIsInRight) {
               make.right.mas_equalTo(self.priceView);
            }else{
                make.right.mas_equalTo(self.klineMainView);
            }
            make.height.mas_equalTo(14);
        }];
    }
    return _horizontalView;
}
- (ZXPriceView *)quotaView
{
    if (!_quotaView) {
        _quotaView = [[ZXPriceView alloc] initWithFrame:CGRectZero PriceArr:@[@"",@""]];
        _quotaView.userInteractionEnabled = NO;
    }
    return _quotaView;
}

- (UIView *)priceMaskView
{
    if (!_priceMaskView) {
        _priceMaskView = [[UIView alloc] init];
        _priceMaskView.backgroundColor = BackgroundColor;
        _priceMaskView.userInteractionEnabled = NO;
    }
    return _priceMaskView;
}
- (ZXTimeLineView *)timeLineView
{
    if (!_timeLineView) {
        _timeLineView = [[ZXTimeLineView alloc] init];
        _timeLineView.backgroundColor = [UIColor clearColor];
        _timeLineView.hidden = YES;
        _timeLineView.userInteractionEnabled = NO;
    }
    return _timeLineView;
}
- (ZXAccessoryView *)accessoryView
{
    if (!_accessoryView) {
        _accessoryView = [[ZXAccessoryView alloc] initWithFrame:CGRectMake(0, 0, 26*3+20, 26)];
        _accessoryView.delegate = self;
        if (self.orientation == UIDeviceOrientationPortrait || self.orientation == UIDeviceOrientationPortraitUpsideDown) {
            
            _accessoryView.hidden = YES;
            
        }else{
            _accessoryView.hidden = NO;
        }
    }
    return _accessoryView;
}
- (UIButton *)rotateBtn
{
    if (!_rotateBtn) {
        _rotateBtn = [[UIButton alloc] init];
        _rotateBtn.backgroundColor = [UIColor redColor];
        [_rotateBtn setImage:[UIImage imageNamed:@"bigger"] forState:UIControlStateNormal];
        [_rotateBtn setImage:[UIImage imageNamed:@"smaller"] forState:UIControlStateSelected];
        _rotateBtn.contentMode = UIViewContentModeScaleAspectFit;
        _rotateBtn.adjustsImageWhenHighlighted = NO;
        [_rotateBtn addTarget:self action:@selector(changeScreenOrientation:) forControlEvents:UIControlEventTouchUpInside];
        _rotateBtn.backgroundColor = [UIColor clearColor];
        
    }
    return _rotateBtn;
}
- (AFHTTPSessionManager *)manager
{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}
- (ZXMessageBoxView *)messageBoxView
{
    if (!_messageBoxView) {
        _messageBoxView = [[ZXMessageBoxView alloc] initWithFrame:CGRectMake(100, 100, (self.klineMainViewWidth-20)/2, 60)];
        _messageBoxView.hidden = YES;
    }
    return _messageBoxView;
}
- (ZXTopCandleInfoView *)topCandleInfoView
{
    if (!_topCandleInfoView) {
        _topCandleInfoView = [[ZXTopCandleInfoView alloc] init];
        _topCandleInfoView.hidden = YES;
        _topCandleInfoView.userInteractionEnabled = YES;
    }
    return _topCandleInfoView;
}
- (ExtremumView *)maximumView
{
    if (!_maximumView) {
        _maximumView = [[ExtremumView alloc] init];
        [self addSubview:_maximumView];
        [_maximumView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self);
            make.bottom.mas_equalTo(self);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(20);
        }];
    }
    return _maximumView;
}
- (ExtremumView *)minimumView
{
    if (!_minimumView) {
        _minimumView = [[ExtremumView alloc] init];
        [self addSubview:_minimumView];
        [_minimumView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self);
            make.bottom.mas_equalTo(self);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(20);
        }];
    }
    return  _minimumView;
}
@end
