//
//  ZXDropDownView.h
//  ZXDropDownMenuDemo
//
//  Created by 郑旭 on 2017/9/11.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZXDropDownView;
@protocol ZXDropDownViewDataSource <NSObject>
- (NSInteger)numberOfRowsForDropDownView;
- (NSString *)titleForRow:(NSInteger)row;
@end
@protocol ZXDropDownViewDelegate <NSObject>
- (void)didSelectAtRow:(NSInteger)row;
@end

@interface ZXDropDownView : UIView
- (instancetype)init;
- (void)shouldToShowDropDownView;
- (void)shouldToHideDropDownView;
- (void)reloadData;
@property (nonatomic,weak) id<ZXDropDownViewDataSource> dataSource;
@property (nonatomic,weak) id<ZXDropDownViewDelegate> delegate;
@property (nonatomic,assign) NSInteger column;
@property (nonatomic,assign) NSInteger currentSelectedIndex;
@end
