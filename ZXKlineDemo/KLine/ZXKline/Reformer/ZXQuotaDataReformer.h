//
//  ZXQuotaDataReformer.h
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/9/13.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KlineModel.h"
@interface ZXQuotaDataReformer : NSObject
+ (instancetype)sharedInstance;
- (void)handleQuotaDataWithDataArr:(NSArray *)dataArr model:(KlineModel *)model index:(NSInteger)idx;
- (NSArray <KlineModel *>*)initializeQuotaDataWithArray:(NSArray <KlineModel *>*)dataArray;
@end
