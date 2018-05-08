//
//  ZXJumpView.h
//  LandscapeTableviewAndKLine
//
//  Created by 郑旭 on 2017/8/2.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZXJumpView : UIView
- (instancetype)initWithIsJump:(BOOL)isJump;
- (void)updateJumpViewWithNewPrice:(NSString *)newPrice backgroundColor:(UIColor *)color;
- (void)updateJumpViewWithNewPrice:(NSString *)newPrice backgroundColor:(UIColor *)color typeText:(NSString *)typeText;
@end
