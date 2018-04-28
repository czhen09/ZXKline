//
//  ZXTestCell.h
//  LandscapeTableviewAndKLine
//
//  Created by 郑旭 on 2017/7/17.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KlineModel.h"
#import "ZXHeader.h"
@interface ZXCandleCell : UITableViewCell

@property (nonatomic,strong) KlineModel *model;
@property (nonatomic,assign) BOOL isDrawDottedLine;
@property (nonatomic,assign) CGFloat candyChartHeight;
@property (nonatomic,assign) CGFloat quotaChartHeight;
@property (nonatomic,assign) CGFloat middleBlankSpace;
@property (nonatomic,assign) CGFloat tableViewHeight;
@property (nonatomic,assign) CGFloat detailDisplayLabelHeight;
@property (nonatomic,assign) ZXTopChartType topChartType;
@property (nonatomic,strong) NSString  *timeLineTime;
@end
