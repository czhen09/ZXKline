//
//  ZXPriceView.h
//  LandscapeTableviewAndKLine
//
//  Created by 郑旭 on 2017/7/26.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZXPriceView : UIView
- (instancetype)initWithFrame:(CGRect)frame PriceArr:(NSArray *)priceArr;
@property (nonatomic,strong) NSArray *priceArr;
- (void)reloadPriceLabelTextWithPriceArr:(NSArray *)priceArr precision:(int)precision;
- (void)refreshCurrentPositionPriceLabelPositonY:(CGFloat)positionY;
- (void)hideZeroLabel:(BOOL)isHide;
//- (void)refreshCurrentPositionPriceLabelPositonY:(CGFloat)positionY price:(NSString *)price;
//- (void)hideCurrentPositionPriceLabel;
- (void)updateFrameWithHeight:(CGFloat)height;
@end
