//
//  ZXMenuButton.h
//  ZXDropDownMenuDemo
//
//  Created by 郑旭 on 2017/9/8.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZXMenuButton;
@protocol ZXMenuButtonDelegate<NSObject>

- (void)menuButtonActionWithSender:(ZXMenuButton *)menuButton;

@end


@interface ZXMenuButton : UIView
- (instancetype)initWithMenuTitle:(NSString *)menuTitle;
@property (nonatomic,weak) id<ZXMenuButtonDelegate> delegate;
@property (nonatomic,assign,getter=isSelected) BOOL selected;
- (void)shouldToRotateArrowImageView;
@property (nonatomic,assign) NSInteger currentSelectedIndex;
@property (nonatomic,copy) NSString *menuTitle;
@end
