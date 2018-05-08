//
//  ZXDropDownView.m
//  ZXDropDownMenuDemo
//
//  Created by 郑旭 on 2017/9/11.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ZXDropDownView.h"
#import "ZXDropDownCell.h"
#import <Masonry.h>
@interface ZXDropDownView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,copy) NSString *cellName;

@end

@implementation ZXDropDownView
#pragma mark - Private Methods
- (instancetype)init
{
    self = [super init];
    if (self) {

        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1].CGColor;
        self.layer.shadowColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1].CGColor;
        self.layer.shadowOpacity = 1;
        self.layer.shadowOffset = CGSizeMake(1, 4);
        self.layer.shadowRadius = 2;
        self.tableView.layer.masksToBounds = YES;
        self.tableView.layer.cornerRadius = 2;
        [self addSubviews];
        [self addConstrains];
    }
    return self;
}

- (void)addSubviews
{
    [self addSubview:self.tableView];
    self.alpha = 0;
    [self.tableView registerNib:[UINib nibWithNibName:self.cellName bundle:nil] forCellReuseIdentifier:self.cellName];
}
- (void)addConstrains
{
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.mas_equalTo(self);
        make.left.right.height.mas_equalTo(self);
        
    }];
}
#pragma mark - Public Methods
- (void)shouldToShowDropDownView
{
    //用于第一次的时候
    if (self.tableView.frame.size.height!=0) {
        
        self.tableView.frame = CGRectMake(0, 0, self.frame.size.width, 0);
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        
        
        self.tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.alpha = 1;
    }];
}

- (void)shouldToHideDropDownView
{
    [UIView animateWithDuration:0.25 animations:^{
        
        self.tableView.frame = CGRectMake(0, 0, self.frame.size.width, 0);
        [self.tableView setContentOffset:CGPointMake(0, 0)];
        self.alpha = 0;
    }];
}

- (void)reloadData
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.dataSource respondsToSelector:@selector(numberOfRowsForDropDownView)]) {
        
        return [self.dataSource numberOfRowsForDropDownView];
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZXDropDownCell *cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellName];
    if ([self.dataSource respondsToSelector:@selector(titleForRow:)]) {
        
        cell.title = [self.dataSource titleForRow:indexPath.row];
    }
    if (indexPath.row==self.currentSelectedIndex) {
        
        cell.textColor = [UIColor colorWithRed:218/255.0 green:47/255.0 blue:53/255.0 alpha:1];
    }else{
        cell.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==self.currentSelectedIndex) {
        return;
    }
    ZXDropDownCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textColor = [UIColor colorWithRed:218/255.0 green:47/255.0 blue:53/255.0 alpha:1];
    if ([self.delegate respondsToSelector:@selector(didSelectAtRow:)]) {
        
        [self.delegate didSelectAtRow:indexPath.row];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
#pragma mark - Getters & Setters
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}
- (NSString *)cellName
{
    if (!_cellName) {
        _cellName = NSStringFromClass([ZXDropDownCell class]);
    }
    return _cellName;
}

@end
