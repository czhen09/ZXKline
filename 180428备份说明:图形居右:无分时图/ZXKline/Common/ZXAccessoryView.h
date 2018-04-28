//
//  ZXAccessoryView.h
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/9/5.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 * 预置指标的名称，暂时只预置了MACD和KDJ
 */
typedef NS_ENUM(NSUInteger, AccessoryName) {
    AccessoryNameFullScreen = 0,
    AccessoryNameIncrease,
    AccessoryNameDecrease,
};

@class ZXAccessoryView;
@protocol ZXAccessoryDelegate <NSObject>

- (void)accessoryActionWithAccessoryName:(AccessoryName)accessoryName isLongPress:(BOOL)isLongPress;

@end


@interface ZXAccessoryView : UIView
@property (nonatomic,assign) AccessoryName accessoryName;
@property (nonatomic,weak) id<ZXAccessoryDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame;
- (void)setFullScreenButtonSelectedWithIsFullScreen:(BOOL)isFullScreen;
@end
