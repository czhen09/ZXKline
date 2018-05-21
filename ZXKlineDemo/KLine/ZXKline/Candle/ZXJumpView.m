//
//  ZXJumpView.m
//  LandscapeTableviewAndKLine
//
//  Created by 郑旭 on 2017/8/2.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ZXJumpView.h"
#import <Masonry/Masonry.h>
#import "ZXHeader.h"
@interface ZXJumpView()
@property (nonatomic,strong) UIView *jumpLine;
@property (nonatomic,strong) UILabel *priceLabel;
@property (nonatomic,assign) BOOL isJump;
@property (nonatomic,strong) CAShapeLayer *horizontalLineLayer;
@property (nonatomic,strong) UILabel  *typeLabel;
@end
@implementation ZXJumpView

- (instancetype)initWithIsJump:(BOOL)isJump;
{
    if (self=[super init]) {

        self.isJump = isJump;
        [self creatUI];
        [self addConstrains];
    }
    return self;
}
- (void)creatUI
{
    self.jumpLine = [[UIView alloc] init];
    if (self.isJump) {
        self.jumpLine.backgroundColor = CoordinateDisPlayLabelColor;
//        [self.jumpLine.layer addSublayer:[self creatLayerWithColor:CoordinateDisPlayLabelColor]];
    }else{
        self.jumpLine.backgroundColor = CoordinateDisPlayLabelColor;
    }
    [self addSubview:self.jumpLine];
    //
    self.priceLabel = [[UILabel alloc] init];
    self.priceLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.priceLabel.backgroundColor = CoordinateDisPlayLabelColor;
    self.priceLabel.text = @"";
    self.priceLabel.textColor = [UIColor whiteColor];
    self.priceLabel.textAlignment = NSTextAlignmentCenter;
    self.priceLabel.font = [UIFont systemFontOfSize:FontSize];
    [self addSubview:self.priceLabel];
    //
    self.typeLabel = [[UILabel alloc] init];
    self.typeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.typeLabel.backgroundColor = [UIColor clearColor];
    self.typeLabel.text = @"";
    self.typeLabel.hidden = YES;
    self.typeLabel.textColor = [UIColor whiteColor];
    self.typeLabel.textAlignment = NSTextAlignmentCenter;
    self.typeLabel.font = [UIFont systemFontOfSize:FontSize];
    [self addSubview:self.typeLabel];
}

- (CAShapeLayer *)creatLayerWithColor:(UIColor *)color
{
    [self.horizontalLineLayer removeFromSuperlayer];
    self.horizontalLineLayer = nil;
    self.horizontalLineLayer = [CAShapeLayer layer];
    UIBezierPath *topLine = [UIBezierPath bezierPath];
    [topLine moveToPoint:CGPointMake(0,0)];
    if (!Portrait) {
        [topLine addLineToPoint:CGPointMake(LanscapeCandleWidth-VerticalCoordinatesWidth,0)];
    }else{
        [topLine addLineToPoint:CGPointMake(PortraitCandleWidth-VerticalCoordinatesWidth,0)];
    }
    self.horizontalLineLayer.lineWidth = 1;
    self.horizontalLineLayer.lineDashPattern = @[@4, @4];
    self.horizontalLineLayer.path = topLine.CGPath;
    self.horizontalLineLayer.strokeColor = color.CGColor;
    return self.horizontalLineLayer;
}

- (void)addConstrains
{
    [self.jumpLine mas_makeConstraints:^(MASConstraintMaker *make) {
        
        
        if (PriceCoordinateIsInRight) {
            make.right.mas_equalTo(self).offset(-VerticalCoordinatesWidth);
            make.left.mas_equalTo(self);
        }else{
            make.right.mas_equalTo(self);
            make.left.mas_equalTo(self).offset(VerticalCoordinatesWidth);
        }
        make.height.equalTo(@0.5);
        make.centerY.mas_equalTo(self);
 
    }];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (PriceCoordinateIsInRight) {
            make.left.mas_equalTo(self.jumpLine.mas_right);
            make.right.mas_equalTo(self.mas_right);
        }else{
            make.left.mas_equalTo(self);
            make.right.mas_equalTo(self.jumpLine.mas_left);
        }
        make.height.mas_equalTo(14);
        make.centerY.mas_equalTo(self);
        
    }];
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.jumpLine);
        make.bottom.mas_equalTo(self.jumpLine.mas_top);
        make.height.mas_equalTo(14);
    }];
}
- (void)updateJumpViewWithNewPrice:(NSString *)newPrice backgroundColor:(UIColor *)color
{
    self.priceLabel.text = newPrice;
    if (color) {

        self.priceLabel.backgroundColor = color;
        self.jumpLine.backgroundColor = color;
        if (self.isJump)
            self.jumpLine.backgroundColor = [UIColor clearColor];
            [self.jumpLine.layer addSublayer:[self creatLayerWithColor:color]];
    }
}
- (void)updateJumpViewWithNewPrice:(NSString *)newPrice backgroundColor:(UIColor *)color typeText:(NSString *)typeText
{
    self.priceLabel.text = newPrice;
    self.priceLabel.backgroundColor = color;
    self.jumpLine.backgroundColor = color;
    self.typeLabel.hidden = NO;
    self.typeLabel.textColor = color;
    self.typeLabel.text = typeText;
}
@end






