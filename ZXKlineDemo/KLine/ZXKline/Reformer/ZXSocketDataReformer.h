//
//  ZXSocketDataReformer.h
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/9/13.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KlineModel.h"
@class ZXSocketDataReformer;
@protocol ZXSocketDataReformerDelegate <NSObject>

- (void)bulidSuccessWithNewKlineModel:(KlineModel *)newKlineModel;

@end


@interface ZXSocketDataReformer : NSObject
+ (instancetype)sharedInstance;
- (void)shouldToCreatTimerWithDataArray:(NSArray *)dataArray;
- (void)bulidNewKlineModelWithNewPrice:(double)newPrice timestamp:(NSInteger)timestamp volumn:(NSNumber *)volumn dataArray:(NSMutableArray<KlineModel *> *)dataArray isFakeData:(BOOL)isFakeData;
- (void)shouldToInvalidTimer;
@property (nonatomic,weak) id<ZXSocketDataReformerDelegate> delegate;
@end
