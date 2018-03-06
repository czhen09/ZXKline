//
//  ZXCandleDetailView.m
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/8/10.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ZXCandleDetailView.h"
#import <Masonry.h>
#import "ZXHeader.h"
@interface ZXCandleDetailView()
@property (nonatomic,strong) UILabel *candleDetailLabel;
@property (nonatomic,strong) NSString *preString;
@end
@implementation ZXCandleDetailView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubviews];
        [self addConstrains];
    }
    return self;
}

#pragma mark - Private Methods
- (void)addSubviews
{
    [self addSubview:self.candleDetailLabel];
}
- (void)addConstrains
{
    [self.candleDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}
#pragma mark - Public Methods

- (void)jointWithNewDetailString:(NSString *)jointString
{

    self.candleDetailLabel.text = [NSString stringWithFormat:@"%@",jointString];
}
- (void)jointWithNewAttributedString:(NSAttributedString *)jointAttributedString
{
    self.candleDetailLabel.attributedText = jointAttributedString;
}
- (void)reloadQuotaDetailViewWithQuotaDetailString:(NSString *)quotaDetailString
{
    self.candleDetailLabel.text = quotaDetailString;
}
- (void)reloadQuotaDetailViewWithQuotaAttributedString:(NSAttributedString *)quotaAttributedString
{
    self.candleDetailLabel.attributedText = quotaAttributedString;
}

#pragma mark - Getters & Setters
- (UILabel *)candleDetailLabel
{
    if (!_candleDetailLabel) {
        
        _candleDetailLabel = [[UILabel alloc] init];
        _candleDetailLabel.numberOfLines = 0;
        _candleDetailLabel.font = [UIFont systemFontOfSize:FontSize];
        _candleDetailLabel.textColor = lightGrayTextColor;
    }
    return _candleDetailLabel;
}

@end
