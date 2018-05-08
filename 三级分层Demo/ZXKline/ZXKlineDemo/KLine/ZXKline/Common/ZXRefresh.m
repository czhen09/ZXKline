//
//  ZXRefresh.m
//  GJB
//
//  Created by 郑旭 on 2017/9/20.
//  Copyright © 2017年 汇金集团SR. All rights reserved.
//

#import "ZXRefresh.h"
#import <Masonry.h>
@interface ZXRefresh()
@property (nonatomic,strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;
@property (nonatomic,assign) BOOL isObserverLive;
@property (nonatomic,strong) UILabel *noMoreDataLabel;
@end
@implementation ZXRefresh

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self addSubViews];
        [self addConstrains];
        self.isObserverLive = YES;
        [self addObserver:self forKeyPath:@"refreshState" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)willRemoveSubview:(UIView *)subview
{
    [super willRemoveSubview:subview];
    if (self.isObserverLive) {
        [self removeObserver];
        self.isObserverLive = NO;
    }
}
- (void)removeObserver
{
    [self removeObserver:self forKeyPath:@"refreshState"];
}
- (void)addSubViews
{
    [self addSubview:self.arrowImageView];
    [self addSubview:self.activityIndicator];
    [self addSubview:self.noMoreDataLabel];
}

- (void)addConstrains
{
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.center.mas_equalTo(self);
        make.width.mas_equalTo(15);
        make.height.mas_equalTo(40);
        
    }];
    [self.activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.center.mas_equalTo(self);
        make.width.height.mas_equalTo(40);
        
    }];
    [self.noMoreDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.center.mas_equalTo(self);
        make.width.mas_equalTo(9);
        make.height.mas_equalTo(self);
    }];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{

    ZXRefreshState refreshState = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
    switch (refreshState) {
        case ZXRefreshStateIdle:
            self.noMoreDataLabel.hidden = YES;
            self.arrowImageView.hidden = NO;
            self.arrowImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
            break;
        case ZXRefreshStatePulling:
            self.noMoreDataLabel.hidden = YES;
            self.arrowImageView.hidden = NO;
            self.arrowImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            self.activityIndicator.hidden = YES;
            break;
        case ZXRefreshStateWillRefresh:
            self.noMoreDataLabel.hidden = YES;
            self.arrowImageView.hidden = NO;
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
            self.activityIndicator.hidden = YES;
            break;
            
        case ZXRefreshStateRefreshing:
            NSLog(@"刷新ing");
            self.noMoreDataLabel.hidden = YES;
            self.arrowImageView.hidden = YES;
            self.activityIndicator.hidden = NO;
            [self.activityIndicator startAnimating];
            break;
        case  ZXRefreshStateNoMoreData:
            self.noMoreDataLabel.hidden = NO;
            self.noMoreDataLabel.text = @"没有更多数据了";
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
            self.arrowImageView.hidden = YES;
            break;
        case  ZXRefreshStateRequestFailure:
            self.noMoreDataLabel.hidden = NO;
            self.noMoreDataLabel.text = @"数据请求失败";
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
            self.arrowImageView.hidden = YES;
            break;
    }
    
}


- (UIImageView *)arrowImageView
{
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = [UIImage imageNamed:@"arrow"];
        _arrowImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    return _arrowImageView;
}
- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidden = YES;
    }
    return _activityIndicator;
}
- (UILabel *)noMoreDataLabel
{
    if (!_noMoreDataLabel) {
        _noMoreDataLabel = [[UILabel alloc] init];
        _noMoreDataLabel.font = [UIFont systemFontOfSize:9];
        _noMoreDataLabel.numberOfLines = 0;
        _noMoreDataLabel.textAlignment = NSTextAlignmentCenter;
        _noMoreDataLabel.textColor = [UIColor lightGrayColor];
        _noMoreDataLabel.hidden = YES;
    }
    return _noMoreDataLabel;
}
@end
