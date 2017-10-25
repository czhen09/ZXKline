//
//  ZXAssemblyView.h
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/8/10.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXHeader.h"
#import "KlineModel.h"
#import "ZXCalculator.h"
#import "ZXDataReformer.h"
#import "ZXQuotaDataReformer.h"
#import "ZXSocketDataReformer.h"
#import "ZXCandleDataReformer.h"
@class ZXAssemblyView;
@protocol AssemblyViewDelegate <NSObject>
@optional
/**
 * @brief 返回计算指标所需数据
 * @param currentDrawKlineModelArr 当前绘制的数据模型数组；里面就暗藏了startindex和needdrawcount参数
 */
- (void)returnCurrentDrawKlineModelArr:(NSArray *)currentDrawKlineModelArr;
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
 * @brief 填补长连接中断后的中断数据（后台，通话，断网）
 * @param startTime 缺陷开始时间
 * @param endTime   缺陷结束时间
 * @param success   请求成功回调
 */
- (void)mustToPerfectDataWithStartTime:(NSInteger)startTime endTime:(NSInteger)endTime successResult:(void(^)(NSArray *resultArr))success;


- (void)didSelectAtColumn:(NSInteger)column Row:(NSInteger)row;

@end


@class KlineModel;
@interface ZXAssemblyView : UIView
- (instancetype)init;
/**
 * @brief 传入历史数据绘制kline
 * @param dataArr 所有已经处理的历史数据
 * @param precision   小数点后面的进度
 * @param stackName   股票名
 * @param needDrawQuotaName   初始绘制指标名
 */
- (void)drawHistoryCandleWithDataArr:(NSArray <KlineModel *>*)dataArr precision:(int)precision stackName:(NSString *)stackName needDrawQuota:(NSString *)needDrawQuotaName;
/**
 * @brief 传入最新数据实时绘制
 * @param klineModel 最新的数据模型
 */
- (void)drawLastKlineWithNewKlineModel:(KlineModel *)klineModel;
/**
 * @brief 传入股票名和请求类型M1.M5进行更新蜡烛信息显示
 * @param quotaType 请求类型
 * @param dataArr 需要绘制的坐标Y值数组  
 * @param maxValue 计算所得最大值 
 * @param minValue 计算所得最小值 
 * @param quotaName 指标名
 * @param subName   子指标名
 * @param lineColor 画线的时候需要传递（画线的时候线和详情显示的文字颜色一致），画柱状的时候不需要传递（不过可以通过传递此颜色用来设置文字颜色，如果不传的话也有默认颜色）
 * @param columnColorArr 柱状数组，当只传一个元素的时候，默认全都都是同一颜色；否则遍历数组取色
 * @param columnWidthType 柱状指标宽度类型
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
 * @brief 绘制预置的指标
 * @param presetQuotaName 预置指标名
 */
- (void)drawPresetQuotaWithQuotaName:(PresetQuotaName)presetQuotaName;
/**
 * @brief 切换分时图和蜡烛图
 */
- (void)switchTopChartContentWithTopChartContentType:(TopChartContentType)topChartContentType;

/**
 * @brief 改变MA的天数绘制不同的均线
 * @param MA1Day  天数
 */
- (void)reDrawMAWithMA1Day:(NSInteger)MA1Day MA2:(NSInteger)MA2Day MA3:(NSInteger)MA3Day;

@property (nonatomic,weak) id<AssemblyViewDelegate> delegate;
@end






