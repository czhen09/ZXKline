//
//  ZXDropDownAssembleView.h
//  ZXDropDownMenuDemo
//
//  Created by 郑旭 on 2017/9/11.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZXDropDownAssembleView;
@protocol ZXDropDownAssembleViewDelegate <NSObject>
- (void)didSelectAtColumn:(NSInteger)column Row:(NSInteger)row;
@end


@interface ZXDropDownAssembleView : UIView
@property (nonatomic,assign) id<ZXDropDownAssembleViewDelegate> delegate;
- (instancetype)init;
- (void)hideDropDownMenu;
@property (nonatomic,assign) BOOL isShowBottom;
@end
