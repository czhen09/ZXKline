//
//  ZXHeader.h
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/8/11.
//  Copyright © 2017年 郑旭. All rights reserved.
//


static NSString *const kOpen  = @"kOpen";
static NSString *const kClose = @"kClose";
static NSString *const kHigh  = @"kHigh";
static NSString *const kLow   = @"kLow";
//
static NSString *const kDrawJustKline   = @"kDrawJustKline";
/**
 * 请求更多的回掉
 */
typedef NS_ENUM(NSUInteger, RequestMoreResultType) {
    //成功(包括成功后数据个数为0)
    RequestMoreResultTypeSuccess = 0,
    //网络请求失败
    RequestMoreResultTypeFailure,
    //没有实现请求更多的代理方法
    RequestMoreResultTypeNotRealize,
};

typedef void (^SuccessBlock) (RequestMoreResultType resultType,NSArray *result);
/**
 * 上半部分
 */
typedef NS_ENUM(NSUInteger, TopChartContentType) {
    TopChartContentTypeWithCandle = 0,
    TopChartContentTypeTineLine,
};
/**
 * 绘制的指标类型
 */
typedef NS_ENUM(NSUInteger, QuotaType) {
    QuotaTypeLine = 0,
    QuotaTypeColumn,
    QuotaTypeSynthsis,
};
/**
 * 预置指标的名称，暂时只预置了MACD和KDJ
 */
typedef NS_ENUM(NSUInteger, PresetQuotaName) {
    PresetQuotaNameWithMACD = 0,
    PresetQuotaNameWithKDJ,
    PresetQuotaNameWithBOLL,
    PresetQuotaNameWithRSI,
    PresetQuotaNameWithVOL,
};
/**
 * 线状柱或者柱状柱
 */
typedef NS_ENUM(NSUInteger, ColumnWidthType) {
    ColumnWidthTypeEqualCandle = 0,
    ColumnWidthTypeEqualLine,
};
//只绘制k线
#define DrawJustKline [[NSUserDefaults standardUserDefaults] boolForKey:kDrawJustKline]
//字体
#define FontSize 10

#define BlueColor [UIColor colorWithRed:0.08 green:0.46 blue:0.70 alpha:1]
#define PurpleColor [UIColor colorWithRed:0.91 green:0.28 blue:0.51 alpha:1]
#define YellowColor [UIColor colorWithRed:0.93 green:0.71 blue:0.40 alpha:1]
/**
 * 蜡烛图-上涨颜色
 */
#define RISECOLOR [UIColor colorWithRed:227.0/255.0 green:102.0/255.0 blue:92.0/255.0 alpha:1]
/**
 * 蜡烛图-下跌颜色
 */
#define DROPCOLOR [UIColor colorWithRed:64.0/255.0 green:184.0/255.0 blue:172.0/255.0 alpha:1]

//颜色背景系列
#define DarkBackgroundColor //WhiteBackgroundColor

//均线颜色
#define MA1Color  PurpleColor
#define MA2Color  YellowColor
#define MA3Color  BlueColor


//指标线颜色
#ifdef  DarkBackgroundColor
#define QuotaDIFFCOLOR [UIColor whiteColor]
#define QuotaDEACOLOR  YellowColor

#define QuotaKCOLOR [UIColor whiteColor]
#define QuotaDCOLOR YellowColor
#define QuotaJCOLOR PurpleColor

#define QuotaBOOLUPCOLOR YellowColor
#define QuotaBOOLMBCOLOR [UIColor whiteColor]
#define QuotaBOOLDNCOLOR PurpleColor

#define QuotaRSI_6 [UIColor whiteColor]
#define QuotaRSI_12 YellowColor
#define QuotaRSI_24 PurpleColor
#else
#define QuotaDIFFCOLOR [UIColor darkGrayColor]
#define QuotaDEACOLOR [UIColor blueColor]

#define QuotaKCOLOR [UIColor darkGrayColor]
#define QuotaDCOLOR YellowColor
#define QuotaJCOLOR PurpleColor

#define QuotaBOOLUPCOLOR YellowColor
#define QuotaBOOLMBCOLOR [UIColor darkGrayColor]
#define QuotaBOOLDNCOLOR PurpleColor

#define QuotaRSI_6 [UIColor darkGrayColor]
#define QuotaRSI_12 YellowColor
#define QuotaRSI_24 PurpleColor
#endif


#ifdef DarkBackgroundColor
//黑色背景系列
#define BackgroundColor [UIColor colorWithRed:(54.0/255.0f) green:(57.0/255.0f) blue:(59.0/255.0f) alpha:1]
//长按横竖线和跳跃线颜色
#define CoordinateDisPlayLabelColor [UIColor colorWithRed:(168.0/255.0f) green:(168.0/255.0f) blue:(168.0/255.0f) alpha:1]
//网格线颜色
#define GrateLineColor [UIColor colorWithRed:(255/255.0f) green:(255/255.0f) blue:(255/255.0f) alpha:1]
#define lightGrayBackGroundColor [UIColor colorWithRed:(245.0/255.0f) green:(245.0/255.0f) blue:(245.0/255.0f) alpha:1]
//显示字体颜色
#define lightGrayTextColor [UIColor colorWithRed:(176.0/255.0f) green:(176.0/255.0f) blue:(176.0/255.0f) alpha:1]
//==============================================
#else
//白色背景系列
#define BackgroundColor [UIColor whiteColor]
#define CoordinateDisPlayLabelColor [UIColor blackColor]
#define GrateLineColor [UIColor colorWithRed:(235/255.0f) green:(237/255.0f) blue:(240/255.0f) alpha:1]
#define lightGrayBackGroundColor [UIColor colorWithRed:(245/255.0f) green:(245/255.0f) blue:(245/255.0f) alpha:1]
#define lightGrayTextColor [UIColor colorWithRed:(153/255.0f) green:(153/255.0f) blue:(153/255.0f) alpha:1]
//==============================================
#endif



/**
 * 价格坐标系在右边？YES->右边；NO->左边
 */
#define PriceCoordinateIsInRight NO

/**
 * 显示时间的view
 */
#define TimeViewHeight 21.0

#define VerticalCoordinatesWidth (PriceCoordinateIsInRight?46:52)
#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
/**
 * 适用于横竖屏的时候，宽度总是小值，高度总是大值
 */
#define KSCREEN_WIDTH    MIN(SCREEN_WIDTH,SCREEN_HEIGHT)
#define KSCREEN_HEIGHT   MAX(SCREEN_WIDTH,SCREEN_HEIGHT)
/**
 * 横竖屏方向
 */
#define Orientation [[UIApplication sharedApplication] statusBarOrientation]
/**
 * 当前屏幕方向是否竖屏  YES—>竖屏  NO->横屏
 */
#define Portrait (Orientation==UIDeviceOrientationPortrait||Orientation==UIDeviceOrientationPortraitUpsideDown)
#define LandscapeLeft (Orientation == UIDeviceOrientationLandscapeLeft)

//k线图边框距离画布上下左右距离
//横屏的时候顶部设置距离为40;项目需求
#define TopMargin (Portrait?5:40)
#define BottomMargin 5
#define ZXLeftMargin 5
#define ZXRightMargin 5


#define CandleTopMargin (DrawJustKline?60:20)
#define CandleBottomMargin (DrawJustKline?100:5)
#define QuotaTopMargin 20
#define QuotaBottomMargin 5


/**
 * 蜡烛高度+指标高度-->针对横屏->KSCREEN_WIDTH相当于屏高
 */
#define LandScapeChartHeight (KSCREEN_WIDTH-TopMargin-BottomMargin-TimeViewHeight-MiddleBlankSpace)
/**
 * 高度比率
 */
#define HeightScale  (KSCREEN_HEIGHT/667.0)
/**
 * 总高度-->这里根据实际情况而定，为屏幕中给k线图预留位置的高度；根据实际需求
 k线图TotalHeight = 屏幕高度 - 其他自定义控件或者系统控件高度和
 */
#define TotalHeight (Portrait ? ((ZX_IS_IPHONE_X?((KSCREEN_HEIGHT-44-40-49-34)-(102+40+41+20+6)*HeightScale):(KSCREEN_HEIGHT-64-49)-(102+40+41+20+6)*HeightScale)) : KSCREEN_WIDTH)

/**
 * 蜡烛高度+指标高度-->针对竖屏
 */
#define PortraitChartHeight (TotalHeight-TopMargin-BottomMargin-TimeViewHeight-MiddleBlankSpace)
/**
 * 上部蜡烛高度;
 */
#define CandleChartHeightJustKline  (Portrait ? (PortraitChartHeight) : (LandScapeChartHeight/3.0*2))
#define CandleChartHeightKlineWithQuota  (Portrait ? (PortraitChartHeight/3.0*2) : (LandScapeChartHeight/3.0*2))
#define CandleChartHeight  DrawJustKline?CandleChartHeightJustKline:CandleChartHeightKlineWithQuota


/**
 * 下部部指标高度
 */
#define QuotaChartHeightJustKline  (Portrait ? (0.01) : (0.01))
#define QuotaChartHeightKlineWithQuota   (Portrait ? (PortraitChartHeight/3.0*1) : (LandScapeChartHeight/3.0*1))
#define QuotaChartHeight   (DrawJustKline ? QuotaChartHeightJustKline : QuotaChartHeightKlineWithQuota)
/**
 * 蜡烛和指标之间的间隔
 */
#define MiddleBlankSpace   (DrawJustKline?0:(Portrait ? 10 : 10))

#define PortraitCandleWidth      (PriceCoordinateIsInRight ? (KSCREEN_WIDTH-VerticalCoordinatesWidth-ZXLeftMargin-ZXRightMargin) : (KSCREEN_WIDTH-ZXLeftMargin-ZXRightMargin))



#define ZX_IS_IPHONE_X (KSCREEN_HEIGHT == 812.0)
#define SafeAreaTopMargin  (LandscapeLeft ? 44 : 34)
#define SafeAreaBottomMargin (LandscapeLeft ? 34 : 44)

#define LanscapeCandleWidth      (PriceCoordinateIsInRight ? (ZX_IS_IPHONE_X?(KSCREEN_HEIGHT-VerticalCoordinatesWidth-SafeAreaTopMargin-SafeAreaBottomMargin):(KSCREEN_HEIGHT-VerticalCoordinatesWidth-ZXLeftMargin-ZXRightMargin)) :(ZX_IS_IPHONE_X?(KSCREEN_HEIGHT-SafeAreaTopMargin-SafeAreaBottomMargin):(KSCREEN_HEIGHT-ZXLeftMargin-ZXRightMargin)))


#define PortraitTotalWidth    KSCREEN_WIDTH
#define LanscapeTotalWidth    KSCREEN_HEIGHT
/**
 * 蜡烛图宽度
 */
#define CandleWidth      (Portrait ? (PortraitCandleWidth) : (LanscapeCandleWidth))
/**
 * 总宽度
 */
#define TotalWidth      (Portrait ? (PortraitTotalWidth) : (LanscapeTotalWidth))

/**
 * 竖虚线之间的距离
 */
#define DottedLineIntervalSpace 80
/**
 * 蜡烛缩放的最大宽度
 */
#define CandleMaxWidth 22
/**
 * 蜡烛缩放的最小宽度
 */
#define CandleMinWidth 5



//k线图中是否需要显示股票名和M1...
#define IsDisplayStockOrQuotaName  NO


//蜡烛的信息配置的位置：YES->单独的view显示在view顶部；NO->弹框覆盖在蜡烛上
#define IsDisplayCandelInfoInTop YES


#ifndef ZXHeader_h
#define ZXHeader_h


#endif /* ZXHeader_h */
