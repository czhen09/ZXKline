//
//  ZXAccessoryView.m
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/9/5.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ZXAccessoryView.h"

@implementation ZXAccessoryView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self creatButton];
    }
    return self;
}
- (void)creatButton
{
    CGFloat width = 26;
    CGFloat height = 26;
    for (int i = 0; i<3; i++) {
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i%3*(width+10), 0, width, height)];
        button.tag = 200+i;
        if (i==0) {
            [button setImage:[UIImage imageNamed:@"decrease-h"] forState:UIControlStateNormal];
            UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(decreaseButtonLongPressAction:)];
            [button addGestureRecognizer:longGesture];
            
        }
        if (i==1) {
            [button setImage:[UIImage imageNamed:@"increase-h"] forState:UIControlStateNormal];
            UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(increaseButtonLongPressAction:)];
            [button addGestureRecognizer:longGesture];
        }
        if (i==2) {
            [button setImage:[UIImage imageNamed:@"bigger"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"smaller"] forState:UIControlStateSelected];
        }
        button.adjustsImageWhenHighlighted = NO;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}
- (void)decreaseButtonLongPressAction:(UIGestureRecognizer *)recognizer
{
    self.accessoryName = AccessoryNameDecrease;
    if ([self.delegate respondsToSelector:@selector(accessoryActionWithAccessoryName:isLongPress:)]) {
        
        [self.delegate accessoryActionWithAccessoryName:self.accessoryName isLongPress:YES];
    }
}
- (void)increaseButtonLongPressAction:(UIGestureRecognizer *)recognizer
{
    self.accessoryName = AccessoryNameIncrease;
    if ([self.delegate respondsToSelector:@selector(accessoryActionWithAccessoryName:isLongPress:)]) {
        
        [self.delegate accessoryActionWithAccessoryName:self.accessoryName isLongPress:YES];
    }
}
- (void)buttonAction:(UIButton *)sender
{
    switch (sender.tag) {
        case 200:
            self.accessoryName = AccessoryNameDecrease;
            break;
        case 201:
            self.accessoryName = AccessoryNameIncrease;
            break;
        case 202:
            [sender setSelected:!sender.selected];
            self.accessoryName = AccessoryNameFullScreen;
            break;

    }
    if ([self.delegate respondsToSelector:@selector(accessoryActionWithAccessoryName:isLongPress:)]) {
        
        [self.delegate accessoryActionWithAccessoryName:self.accessoryName isLongPress:NO];
    }
}
- (void)setFullScreenButtonSelectedWithIsFullScreen:(BOOL)isFullScreen
{
    UIButton *fullscreenButton = [self viewWithTag:200];
    [fullscreenButton setSelected:isFullScreen];
}
@end
