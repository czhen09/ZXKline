//
//  ZXTopCandleInfoView.m
//  GJB
//
//  Created by 郑旭 on 2017/9/30.
//  Copyright © 2017年 汇金集团SR. All rights reserved.
//

#import "ZXTopCandleInfoView.h"
#import "ZXHeader.h"
#import <Masonry.h>
@interface ZXTopCandleInfoView()
@property (nonatomic,strong) NSMutableArray *labelArray;
@end
@implementation ZXTopCandleInfoView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self creatUI];
        [self setUI];
    }
    return self;
}
- (void)setUI
{
    self.backgroundColor = lightGrayBackGroundColor;
    self.userInteractionEnabled = NO;
}
- (void)creatUI
{
    
    self.labelArray = [NSMutableArray array];
    UIView *previousView = self;
    CGFloat width = ([UIScreen mainScreen].bounds.size.width-ZXLeftMargin-ZXRightMargin)/4.0;
    for (int i = 0; i<4; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:12];
        label.text = @"";
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i==0) {
                make.left.mas_equalTo(previousView).offset(ZXLeftMargin);
            }else{
                make.left.mas_equalTo(previousView.mas_right);
            }
            make.width.mas_equalTo(width);
            make.top.bottom.mas_equalTo(self)
            ;
        }];
        [self.labelArray addObject:label];
        previousView = label;
    }
}
- (void)updateInfoWithModel:(KlineModel *)model precision:(int)precision
{
    
    if (model.isPlaceHolder) {
        
        [self setLabelTextWithOpen:0 close:0 high:0 low:0 precision:0];
        
    }else{
        [self setLabelTextWithOpen:model.openPrice close:model.closePrice high:model.highestPrice low:model.lowestPrice precision:precision];
    }
    
}

- (void)setLabelTextWithOpen:(double)open close:(double)close high:(double)high low:(double)low precision:(int)precision
{
    NSString *openString = [NSString stringWithFormat:@"开盘%.*f",precision,open];
    NSAttributedString *openAttributed = [[NSMutableAttributedString alloc] initWithAttributedString:[self setupAttributeString:openString color:DROPCOLOR]];
    NSString *closeString = [NSString stringWithFormat:@"收盘%.*f",precision,close];
    NSAttributedString *closeAttributed = [[NSMutableAttributedString alloc] initWithAttributedString:[self setupAttributeString:closeString color:RISECOLOR]];
    NSString *highString = [NSString stringWithFormat:@"最高%.*f",precision,high];
    NSAttributedString *highAttributed = [[NSMutableAttributedString alloc] initWithAttributedString:[self setupAttributeString:highString color:DROPCOLOR]];
    NSString *lowString = [NSString stringWithFormat:@"最低%.*f",precision,low];
    NSAttributedString *lowAttributed = [[NSMutableAttributedString alloc] initWithAttributedString:[self setupAttributeString:lowString color:RISECOLOR]];
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithObjects:openAttributed,closeAttributed,highAttributed,lowAttributed,nil];
    [tempArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UILabel *label = self.labelArray[idx];
        label.attributedText = (NSAttributedString *)obj;
    }];
}

- (NSAttributedString *)setupAttributeString:(NSString *)text color:(UIColor *)attributedColor
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSForegroundColorAttributeName value:lightGrayTextColor range:NSMakeRange(0, 2)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:attributedColor range:NSMakeRange(2, text.length-2)];
    return [attributedString copy];
}

@end
