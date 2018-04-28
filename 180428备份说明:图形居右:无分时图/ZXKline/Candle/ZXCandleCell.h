//
//  ZXTestCell.h
//  LandscapeTableviewAndKLine
//
//  Created by 郑旭 on 2017/7/17.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KlineModel.h"
@interface ZXCandleCell : UITableViewCell

@property (nonatomic,strong) KlineModel *model;
@property (nonatomic,assign) BOOL isDrawDottedLine;
@property (nonatomic,assign) CGFloat candyChartHeight;
@property (nonatomic,assign) CGFloat quotaChartHeight;
@property (nonatomic,assign) CGFloat middleBlankSpace;
@property (nonatomic,assign) CGFloat tableViewHeight;
@property (nonatomic,assign) CGFloat detailDisplayLabelHeight;
//用于判断是绘制蜡烛线还是山形图
@property (nonatomic,assign) BOOL isDrawKline;
@end
