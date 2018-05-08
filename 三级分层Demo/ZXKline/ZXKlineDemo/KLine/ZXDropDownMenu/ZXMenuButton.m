//
//  ZXMenuButtonView.m
//  ZXDropDownMenuDemo
//
//  Created by 郑旭 on 2017/9/8.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ZXMenuButton.h"
#import <Masonry.h>
@interface ZXMenuButton()
@property (nonatomic,strong) UILabel *menuLabel;
@property (nonatomic,strong) UIImageView *arrowImageView;
@end
@implementation ZXMenuButton

- (instancetype)initWithMenuTitle:(NSString *)menuTitle
{
    self = [super init];
    if (self) {
        self.menuTitle =  menuTitle;
        [self addSubView];
        [self addConstrains];
        [self configureUI];
        self.currentSelectedIndex = 0;
    }
    return self;
}
- (void)addSubView
{
    [self addSubview:self.menuLabel];
    [self addSubview:self.arrowImageView];
}

- (void)addConstrains
{
   
    [self.menuLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.bottom.mas_equalTo(self);
        make.width.mas_equalTo(self.mas_width).offset(-20);
        
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.menuLabel.mas_right);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(8);

    }];
    
}
- (void)configureUI
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4;
 
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self setSelected:!self.isSelected];
    [self shouldToRotateArrowImageView];
    if ([self.delegate respondsToSelector:@selector(menuButtonActionWithSender:)]) {
        
        [self.delegate menuButtonActionWithSender:self];
    }
}
- (void)shouldToRotateArrowImageView
{
    if (self.isSelected) {
        [UIView animateWithDuration:0.25 animations:^{
            
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    }else{
        [UIView animateWithDuration:0.25 animations:^{
            
            self.arrowImageView.transform = CGAffineTransformMakeRotation(0);
        }];
    }
}

- (UILabel *)menuLabel
{
    if (!_menuLabel) {
        _menuLabel = [[UILabel alloc] init];
        _menuLabel.textAlignment = NSTextAlignmentCenter;
        _menuLabel.font = [UIFont systemFontOfSize:14];
        _menuLabel.text = self.menuTitle;
        _menuLabel.textColor = [UIColor whiteColor];
    }
    return _menuLabel;
}
- (UIImageView *)arrowImageView
{
    if (!_arrowImageView) {
        _arrowImageView= [[UIImageView alloc] init];
        _arrowImageView.image = [UIImage imageNamed:@"triangle"];
    }
    return _arrowImageView;
}
- (void)setMenuTitle:(NSString *)menuTitle
{
    self.menuLabel.text = menuTitle;
}
@end
