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
- (void)bulidNewKlineModelWithNewPrice:(double)newPrice timestamp:(NSInteger)timestamp volumn:(NSNumber *)volumn dataArray:(NSMutableArray<KlineModel *> *)dataArray isFakeData:(BOOL)isFakeData;
@property (nonatomic,weak) id<ZXSocketDataReformerDelegate> delegate;
@end
