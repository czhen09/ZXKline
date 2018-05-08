//
//  ZXPriceView.m
//  LandscapeTableviewAndKLine
//
//  Created by 郑旭 on 2017/7/26.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ZXPriceView.h"
#import <Masonry/Masonry.h>
#import "ZXHeader.h"
static CGFloat const priceLabelHeight = 14;
@interface ZXPriceView()
@property (nonatomic,strong) NSMutableArray *priceLabelArr;
//@property (nonatomic,strong) UILabel *currentPositionPriceLabel;
@property (nonatomic,strong) UILabel *zeroLabel;
@end
@implementation ZXPriceView

- (instancetype)initWithFrame:(CGRect)frame PriceArr:(NSArray *)priceArr
{
    self = [super initWithFrame:frame];
    if (self) {
        self.priceArr = priceArr;
        [self creatPriceLabel];
//        [self creatCurrentPositionPriceLabel];
//        [self creatXZeroLabel];
    }
    return self;
}
- (void)updateFrameWithHeight:(CGFloat)height
{
    
    CGFloat intervalSpace = height/(self.priceArr.count-1);
    [self.priceLabelArr enumerateObjectsUsingBlock:^(UILabel *priceLabel, NSUInteger idx, BOOL * _Nonnull stop) {
        [priceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            
            if (idx==0) {
                
                make.top.mas_equalTo(self);
            }else if (idx==self.priceLabelArr.count-1){
                
                make.bottom.mas_equalTo(self);
            }else
            {
            make.top.mas_equalTo(self).offset(intervalSpace*idx-priceLabelHeight/2);
            }
           
            
            make.left.mas_equalTo(self);
            make.right.mas_equalTo(self);
            make.height.mas_equalTo(priceLabelHeight);
            
        }];
  
    }];
    
}
- (void)creatPriceLabel
{
    
    CGFloat intervalSpace = self.frame.size.height/(self.priceArr.count-1);
    for (int i = 0; i<self.priceArr.count; i++) {
        
        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.textColor = lightGrayTextColor;
        priceLabel.font = [UIFont systemFontOfSize:FontSize];
        priceLabel.textAlignment = NSTextAlignmentCenter;
        priceLabel.lineBreakMode = NSLineBreakByWordWrapping;
        priceLabel.text = self.priceArr[i];
        priceLabel.frame = CGRectMake(4, intervalSpace*i-priceLabelHeight/2, self.frame.size.width-4, priceLabelHeight);
        [self.priceLabelArr addObject:priceLabel];
        [self addSubview:priceLabel];
    }
}
- (void)reloadPriceLabelTextWithPriceArr:(NSArray *)priceArr precision:(int)precision
{
    
    [self.priceLabelArr enumerateObjectsUsingBlock:^(UILabel *priceLabel, NSUInteger idx, BOOL * _Nonnull stop) {
        
//        NSString *priceStr = [NSString stringWithFormat:@"%@",priceArr[idx]];
//        NSArray *componentArr = [priceStr componentsSeparatedByString:@"."];
//        NSString *previousStr = componentArr[0];
//        NSNumber *previousLength = @(previousStr.length);
//        int nextLength = 8-[previousLength intValue]-1;
        NSString *priceStrr = [NSString stringWithFormat:@"%.*f",precision,[[priceArr[idx] stringValue] doubleValue]];
        priceLabel.text = priceStrr;
    }];
}
- (void)creatXZeroLabel
{
    [self addSubview:self.zeroLabel];
    [self.zeroLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.mas_equalTo(self);
        make.left.mas_equalTo(self);
        make.height.mas_equalTo(priceLabelHeight);
    }];
    [self bringSubviewToFront:self.zeroLabel];
    self.zeroLabel.hidden = YES;
}
- (void)refreshCurrentPositionPriceLabelPositonY:(CGFloat)positionY
{
//    self.zeroLabel.hidden = NO;
//    [self.zeroLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//
//        make.bottom.mas_equalTo(self).offset(-(positionY-priceLabelHeight/2));
//    }];
}
- (void)hideZeroLabel:(BOOL)isHide
{
//    if (isHide) {
//
//        self.zeroLabel.hidden = YES;
//    }else{
//        self.zeroLabel.hidden = NO;
//    }
}
//- (void)creatCurrentPositionPriceLabel
//{
//    [self addSubview:self.currentPositionPriceLabel];
//    [self.currentPositionPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.right.mas_equalTo(self);
//        make.left.mas_equalTo(self).offset(4);
//        make.height.mas_equalTo(priceLabelHeight);
//    }];
//    [self bringSubviewToFront:self.currentPositionPriceLabel];
//    self.currentPositionPriceLabel.hidden = YES;
//}
//- (void)refreshCurrentPositionPriceLabelPositonY:(CGFloat)positionY price:(NSString *)price
//{
//    self.currentPositionPriceLabel.hidden = NO;
//    [self.currentPositionPriceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        
//        make.top.mas_equalTo(self).offset(positionY-priceLabelHeight/2);
//    }];
//    self.currentPositionPriceLabel.text = price;
////}
//- (void)hideCurrentPositionPriceLabel
//{
//    self.currentPositionPriceLabel.hidden = YES;
//}
- (NSMutableArray *)priceLabelArr
{
    if (!_priceLabelArr) {
        _priceLabelArr = [NSMutableArray array];
    }
    return _priceLabelArr;
}
- (UILabel *)zeroLabel
{
    if (!_zeroLabel) {
        _zeroLabel = [UILabel new];
        _zeroLabel.text = @"0";
        _zeroLabel.backgroundColor = [UIColor clearColor];
        _zeroLabel.textAlignment = NSTextAlignmentCenter;
        _zeroLabel.textColor = lightGrayTextColor;
        _zeroLabel.font = [UIFont systemFontOfSize:FontSize];
        
    }
    return _zeroLabel;
}
//- (UILabel *)currentPositionPriceLabel
//{
//    if (!_currentPositionPriceLabel) {
//        _currentPositionPriceLabel = [UILabel new];
//        _currentPositionPriceLabel.backgroundColor = [UIColor whiteColor];
//        _currentPositionPriceLabel.textColor = [UIColor blackColor];
//        _currentPositionPriceLabel.font = [UIFont systemFontOfSize:9];
//        
//    }
//    return _currentPositionPriceLabel;
//}
//- (void)setPriceArr:(NSArray *)priceArr
//{
//
//    [self.priceLabelArr enumerateObjectsUsingBlock:^(UILabel *priceLabel, NSUInteger idx, BOOL * _Nonnull stop) {
//        
//        priceLabel.text = priceArr[idx];
//    }];
//}
@end
