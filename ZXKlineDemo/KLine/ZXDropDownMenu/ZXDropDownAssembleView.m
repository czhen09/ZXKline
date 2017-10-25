//
//  ZXDropDownAssembleView.m
//  ZXDropDownMenuDemo
//
//  Created by 郑旭 on 2017/9/11.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ZXDropDownAssembleView.h"
#import "ZXMenuButton.h"
#import "ZXDropDownView.h"
#import <Masonry.h>


static CGFloat const margin = 4;
@interface ZXDropDownAssembleView()<ZXMenuButtonDelegate,ZXDropDownViewDataSource,ZXDropDownViewDelegate>
@property (nonatomic,strong) ZXMenuButton *currentSelectedMenuButton;
@property (nonatomic,assign) NSInteger currentSelectedMenuIndex;
@property (nonatomic,strong) ZXDropDownView *dropDownView;
@property (nonatomic,strong) NSArray *menuTitleArray;
@property (nonatomic,strong) NSArray *widthsArray;
@property (nonatomic,strong) NSMutableArray *menuButtonArray;
@property (nonatomic,strong) NSArray *subTitleArray;
@property (nonatomic,assign) CGFloat dropDownMenuHeight;

@end
@implementation ZXDropDownAssembleView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self creatUI];
        [self addSubviews];
        [self addConstrains];
        
    }
    return self;
}
#pragma mark - Private Methods
- (void)creatUI
{
    __block UIView *previousView = self;
    
    [self.menuTitleArray enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
        ZXMenuButton *menuButton = [[ZXMenuButton alloc] initWithMenuTitle:title];
        menuButton.backgroundColor = [UIColor redColor];
        menuButton.tag = 300+idx;
        menuButton.delegate = self;
        [self addSubview:menuButton];
        [menuButton mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(self);
            if (idx==0) {
                make.left.mas_equalTo(self);
            }else{
                make.left.mas_equalTo(previousView.mas_right).offset(margin);
            }
            make.width.mas_equalTo([self.widthsArray[idx] floatValue]);
            make.height.mas_equalTo(28);
        }];
        previousView = menuButton;
        [self.menuButtonArray addObject:menuButton];
    }];
}

- (void)addSubviews
{
    [self addSubview:self.dropDownView];
}

- (void)addConstrains
{
    self.currentSelectedMenuButton = [self viewWithTag:300];
    [self.dropDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        
    make.top.mas_equalTo(self.currentSelectedMenuButton.mas_bottom).offset(5);
        make.left.mas_equalTo(self);
        make.width.mas_equalTo([self.widthsArray[0] floatValue]);
        make.height.mas_equalTo(self.dropDownMenuHeight);
    }];
}

- (void)menuButtonActionWithSender:(ZXMenuButton *)menuButton
{

    self.dropDownView.currentSelectedIndex = menuButton.currentSelectedIndex;
    
    //记录一个当前选中的view，如果选中的和以前的不同，就进行如下操作
    if (menuButton != self.currentSelectedMenuButton) {
        
        if (self.currentSelectedMenuButton.isSelected) {
            
            [self resetArrowAngle];
        }
    }
    //记录当前
    self.currentSelectedMenuButton = menuButton;
    
    //更新约束
    NSInteger index = menuButton.tag-300;
    [self.dropDownView mas_updateConstraints:^(MASConstraintMaker *make) {
        CGFloat leftSpacing = 0;
        if (index==0) {
            
            leftSpacing = 0;
        }else
        {
            for (int i = 0; i<index; i++) {
                
                leftSpacing += [self.widthsArray[i] floatValue];
                leftSpacing += margin;
            }
        }
        make.left.mas_equalTo(self).offset(leftSpacing);
        make.width.mas_equalTo([self.widthsArray[index] floatValue]);
        make.height.mas_equalTo(self.dropDownMenuHeight);
    }];
    //动画操作
    if (menuButton.isSelected)
    {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 160+30+30+2);
        [self.dropDownView shouldToShowDropDownView];
    }else
    {
  
        [self shouldToHideDropDownView];
        
    }
    self.isShowBottom = menuButton.isSelected;
    //刷新
    [self.dropDownView reloadData];
    
}
- (void)resetArrowAngle
{
    [self.currentSelectedMenuButton setSelected:NO];
    [self.currentSelectedMenuButton shouldToRotateArrowImageView];
}

- (void)shouldToHideDropDownView
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width,30+30);
    [self.dropDownView shouldToHideDropDownView];
    [self resetArrowAngle];
    self.isShowBottom = NO;
}

#pragma mark - Public Methods
- (void)hideDropDownMenu
{
    [self shouldToHideDropDownView];
    
}
#pragma mark - ZXDropDownViewDataSource
- (NSInteger)numberOfRowsForDropDownView
{
    return ((NSArray *)self.subTitleArray[self.currentSelectedMenuIndex]).count;
}

- (NSString *)titleForRow:(NSInteger)row
{
    NSArray *dataArr = self.subTitleArray[self.currentSelectedMenuIndex];
    return dataArr[row];
}
#pragma mark - ZXDropDownViewDelegate
- (void)didSelectAtRow:(NSInteger)row
{
    
    NSString *currentSelectedTitle = ((NSArray *)self.subTitleArray[self.currentSelectedMenuIndex])[row];
    self.currentSelectedMenuButton.menuTitle = currentSelectedTitle;
    [self shouldToHideDropDownView];
    if ([self.delegate respondsToSelector:@selector(didSelectAtColumn:Row:)]) {
        
        [self.delegate didSelectAtColumn:self.currentSelectedMenuIndex Row:row];
    }
    
    self.currentSelectedMenuButton.currentSelectedIndex = row;
    
    
    //隐藏
//    self.angleDoubleDownButton.hidden  = NO;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //手势不会被阻挡，但是touch只会执行在touchsview，可以阻挡
    [self shouldToHideDropDownView];
//    self.angleDoubleDownButton.hidden = NO;
}
#pragma mark - Getters & Setters
- (NSArray *)menuTitleArray
{
    return @[@"现货黄金",@"M1",@"K线图",@"MA均线"];
}
- (ZXDropDownView *)dropDownView
{
    if (!_dropDownView) {
        _dropDownView = [[ZXDropDownView alloc] init];
        _dropDownView.dataSource = self;
        _dropDownView.delegate = self;
    }
    return _dropDownView;
}
- (NSArray *)widthsArray
{
    return @[@(100),@(60),@(80),@(100)];
}
- (NSMutableArray *)menuButtonArray
{
    if (!_menuButtonArray) {
        _menuButtonArray = [NSMutableArray array];
    }
    return _menuButtonArray;
}
- (NSArray *)subTitleArray
{
    if (!_subTitleArray) {
        
        _subTitleArray = @[@[@"现货黄金",@"现货白银"],@[@"M1",@"M5",@"M10",@"D1"],@[@"K线图",@"山形图"],@[@"MA均线",@"RSI",@"KDJ",@"MACD",@"BOLL"]];
    }
    return _subTitleArray;
}
- (NSInteger)currentSelectedMenuIndex
{
    return (self.currentSelectedMenuButton.tag-300);
}
- (CGFloat)dropDownMenuHeight
{
    NSInteger count = ((NSArray *)self.subTitleArray[self.currentSelectedMenuIndex]).count;
    CGFloat height = count*40;
    if (height>160) {
        
        height = 160;
    }
    return height;
}

@end
