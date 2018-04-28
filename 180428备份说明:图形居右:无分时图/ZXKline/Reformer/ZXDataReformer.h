//
//  ZXDataReformer.h
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/9/13.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KlineModel.h"
@interface ZXDataReformer : NSObject
+ (instancetype)sharedInstance;
- (NSArray <KlineModel *>*)transformDataWithOriginalDataArray:(NSArray *)dataArray currentRequestType:(NSString *)currentRequestType;
@property (nonatomic,strong) NSString *currentRequestType;
@end
