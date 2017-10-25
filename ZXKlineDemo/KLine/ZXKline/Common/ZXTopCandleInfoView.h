//
//  ZXTopCandleInfoView.h
//  GJB
//
//  Created by 郑旭 on 2017/9/30.
//  Copyright © 2017年 汇金集团SR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KlineModel.h"
@interface ZXTopCandleInfoView : UIView
- (instancetype)init;
- (void)updateInfoWithModel:(KlineModel *)model precision:(int)precision;

@end

