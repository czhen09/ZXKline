//
//  ZXDropDownCell.m
//  ZXDropDownMenuDemo
//
//  Created by 郑旭 on 2017/9/11.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ZXDropDownCell.h"
#import "ZXHeader.h"
@interface ZXDropDownCell()
@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;
@end

@implementation ZXDropDownCell

- (void)setTitle:(NSString *)title
{
    self.headlineLabel.text = title;
    
}

- (void)setTextColor:(UIColor *)textColor
{
    self.headlineLabel.textColor = textColor;
}

@end
