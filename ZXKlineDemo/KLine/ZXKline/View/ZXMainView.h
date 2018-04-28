//
//  ZXMainView.h
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/8/8.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXHeader.h"
@class ZXMainView,KlineModel;
@protocol  ZXMainViewDelegate<NSObject>
/**
 * 刷新右侧价格：价格数组
 */
- (void)shouldToReloadPriceViewWithPriceArr:(NSArray *)priceArr;
/**
 * @brief 长按点取得的蜡烛模型
 * @param klineModel 长按点返回的模型，可以在里面取到开收高低等值
 */
- (void)longpressPointCandleModel:(KlineModel *)klineModel longPressPoint:(CGPoint)point;
/**
 * @brief 恢复细节显示
 */
- (void)shouldRenewChartDetailView;
/**
 * @brief 长按的水平回调
 * @param positionY 水平位置
 * @param price 价格
 */
- (void)shouldToReloadCurrentPositionPriceJumpViewWithPositonY:(CGFloat)positionY price:(NSString *)price;
/**
 * @brief 长按的竖直回调
 * @param positionX 竖直位置
 * @param timeStr 时间
 */
- (void)shouldToReloadCurrentPositionTimeWithPositonX:(CGFloat)positionX timeStr:(NSString *)timeStr;
/**
 * @brief 隐藏长按十字线
 */
- (void)shouldHideCrossCurve;

/**
 * @brief 回调当前index，根据index获取数据
 */
- (void)shouldToReloadQuotaDetailViewWithResultString:(NSAttributedString *)QuotaResultString shouldToReloadCandleDetailViewWithMAResultString:(NSAttributedString *)MAResultString;

@optional
/**
 * @brief 返回计算指标所需数据
 * @param currentDrawKlineModelArr 当前绘制的数据模型数组；里面就暗藏了startindex和needdrawcount参数
 */
- (void)returnCurrentDrawKlineModelArr:(NSArray *)currentDrawKlineModelArr newKlineModel:(KlineModel *)newKlineModel;
/**
 * @brief 请求更多的历史数据
 * @param succ block回调请求的数据
 */
- (void)shouldToRequestMoreHistoryKlineDataArr:(SuccessBlock)succ;
/**
 * 作用在蜡烛区域的点击事件
 */
- (void)tapActionActOnCandleArea;
/**
 * 作用在指标区域的点击事件
 */
- (void)tapActionActOnQuotaArea;
/**
 * 返回显示一屏最大最小值所需要的坐标
 */
- (void)updateMaxAndMinViewWithMaxPoint:(CGPoint)maxPoint minPoint:(CGPoint)minPoint maxValue:(double)maxValue minValue:(double)minValue;
@end
@class KlineModel;
@interface ZXMainView : UIView
@property (nonatomic,weak) id<ZXMainViewDelegate> delegate;
/**
 * 峰值
 */
@property (nonatomic,assign) double minAssert;
/**
 *低值
 */
@property (nonatomic,assign) double maxAssert;
/**
 *单位价格的高度值
 */
@property (nonatomic,assign) CGFloat heightPerPoint;
/**
 * 峰值
 */
@property (nonatomic,assign) double quotaMinAssert;
/**
 *低值
 */
@property (nonatomic,assign) double quotaMaxAssert;
/**
 *单位价格的高度值
 */
@property (nonatomic,assign) CGFloat quotaHeightPerPoint;
 
@property (nonatomic,assign) int precision;

/**
 *判断滑动位置，如果滑动是在最后的位置的话，在增加cell的时候就滚动到最底部，否则就不滚动
 */
@property (nonatomic,assign) BOOL isScrollToBottom;
- (instancetype)init;
/**
 * 根据历史数据绘制k线
 */
- (void)drawHistoryKlineWithDataArr:(NSArray *)dataArr;

/**
 * 根据长连接返回最新数据绘制最后一个cadle
 */
- (void)drawLastKlineWithNewKlineModel:(KlineModel *)klineModel isNew:(BOOL)isNew;
/**
 * 画底部指标
 */
- (void)drawQuotaWithType:(QuotaType)quotaType
                  dataArr:(NSArray *)dataArr
                 maxValue:(double)maxValue
                 minValue:(double)minValue
                quotaName:(NSString *)quotaName
                  subName:(NSString *)subName
                lineColor:(UIColor *)lineColor
           columnColorArr:(NSArray *)columnColorArr
          columnWidthType:(ColumnWidthType)columnWidthType;
/**
 * @brief 填补长连接中断后的中断数据（后台，通话，断网）
 * @param breakOffDataArr 中断数据数组
 */
- (void)addBreakOffObjectsWithDataArr:(NSArray *)breakOffDataArr;
- (NSArray *)getAllKlineModelDataArr;
- (NSArray *)getCurrentDrawKlineModelArr;
/**
 * @brief 切换分时图和蜡烛图
 */
- (void)switchTopChartWithTopChartType:(ZXTopChartType)topChartType;
/**
 * @brief 改变MA的天数绘制不同的均线
 * @param MA1Day  天数
 */
- (void)reDrawMAWithMA1Day:(NSInteger)MA1Day MA2:(NSInteger)MA2Day MA3:(NSInteger)MA3Day;
/**
 * @brief 宽度增加
 */
- (void)increaseCandleWidthWithisLongPress:(BOOL)isLongPress;
/**
 * @brief 宽度减少
 */
-  (void)decreaseCandleWidthWithisLongPress:(BOOL)isLongPress;
/**
 * @brief 蜡烛图继续全屏
 */
- (void)candleFullScreen;
@end
