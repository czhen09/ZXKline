//
//  ZXMessageBoxView.m
//  GJB
//
//  Created by 郑旭 on 2017/9/7.
//  Copyright © 2017年 汇金集团SR. All rights reserved.
//

#import "ZXMessageBoxView.h"
#import "ZXHeader.h"
@interface ZXMessageBoxView()
@property (nonatomic,copy) NSString *open;
@property (nonatomic,copy) NSString *close;
@property (nonatomic,copy) NSString *high;
@property (nonatomic,copy) NSString *low;
@property (nonatomic,assign) ArrowPosition arrowPosition;
@property (nonatomic,strong) CAShapeLayer *borderLayer;
@end

@implementation ZXMessageBoxView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
        self.open = @"0";
        self.close = @"0";
        self.high = @"0";
        self.low = @"0";
    }
    return self;
}
- (void)setUI
{
    self.backgroundColor = [UIColor clearColor];
    
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self updateMessageWithOpen:self.open close:self.close high:self.high low:self.low];
    [self drawBorder];
}

- (void)updateMessageWithOpen:(NSString *)open close:(NSString *)close high:(NSString *)high low:(NSString *)low

{
    NSArray *titles = @[[@"开: " stringByAppendingString:open], [@"收: " stringByAppendingString:close], [@"高: " stringByAppendingString:high], [@"低: " stringByAppendingString:low]];
    
    CGFloat padding = 0;
    if (KSCREEN_WIDTH==320) {
        
        padding = 5;
    }else{
        
        padding = 10;
    }
    CGFloat width = (self.frame.size.width-10-3*padding)/2;
    CGFloat height = (self.frame.size.height-3*padding)/2;
    for (int i = 0; i < 4; i ++) {
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByClipping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:titles[i] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:FontSize],NSParagraphStyleAttributeName:paragraphStyle}];
        if (KSCREEN_WIDTH==320) {
            
            [attString drawInRect:CGRectMake(10+i%2*(width+padding), 10+i/2*(height+padding), width, height)];
        }else{
            
            [attString drawInRect:CGRectMake(20+i%2*(width+padding), 10+i/2*(height+padding), width, height)];
        }
        
    }
}
- (void)drawBorder
{
    [self.borderLayer removeFromSuperlayer];
    self.borderLayer = nil;
    switch (self.arrowPosition) {
        case ArrowPositionLeftTop:
            [self drawBorderWithArrowLeftTop];
            break;
        case ArrowPositionRightTop:
            [self drawBorderWithArrowRightTop];
            break;
        case ArrowPositionLeftBottom:
            [self drawBorderWithArrowLeftBottom];
            break;
        case ArrowPositionRightBottom:
            [self drawBorderWithArrowRightBottom];
            break;
        case ArrowPositionLeftCenter:
            [self drawBorderWithArrowLeftCenter];
            break;
        case ArrowPositionRightCenter:
            [self drawBorderWithArrowRightCenter];
            break;
    }
}

- (void)setNeedsDisplayWithOpen:(NSString *)open close:(NSString *)close high:(NSString *)high low:(NSString *)low arrowPosition:(ArrowPosition)arrowPosition
{
    
    self.arrowPosition = arrowPosition;
    self.open = open;
    self.close = close;
    self.high = high;
    self.low = low;
    [self setNeedsDisplay];
}

- (void)drawBorderWithArrowRightCenter
{
    CGFloat arrowLong = 10;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat radius = 4;
    self.borderLayer = [CAShapeLayer layer];
    UIBezierPath *beizerPath = [UIBezierPath bezierPath];
    [beizerPath moveToPoint:CGPointMake(radius, 0)];
    [beizerPath addLineToPoint:CGPointMake(width-arrowLong-radius, 0)];
    [beizerPath addArcWithCenter:CGPointMake(width-arrowLong-radius, radius) radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    
    
    
    [beizerPath addLineToPoint:CGPointMake(width-arrowLong,(height-arrowLong)/2.0)];
    [beizerPath addLineToPoint:CGPointMake(width,(height)/2.0)];
    [beizerPath addLineToPoint:CGPointMake(width-arrowLong,(height-arrowLong)/2.0+arrowLong)];
    
    
    
    //
    [beizerPath addLineToPoint:CGPointMake(width-arrowLong,height)];
    [beizerPath addArcWithCenter:CGPointMake(width-arrowLong-radius, height-radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    
    
    //
    [beizerPath addLineToPoint:CGPointMake(radius,height)];
    [beizerPath addArcWithCenter:CGPointMake(radius, height-radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [beizerPath addLineToPoint:CGPointMake(0,radius)];
    [beizerPath addArcWithCenter:CGPointMake(radius,radius) radius:radius startAngle:M_PI endAngle:M_PI_2*3 clockwise:YES];
    self.borderLayer.lineWidth = 0.5;
    self.borderLayer.path = beizerPath.CGPath;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.borderLayer.strokeColor = [UIColor redColor].CGColor;
    [self.layer addSublayer:self.borderLayer];
}

- (void)drawBorderWithArrowLeftCenter
{
    CGFloat arrowLong = 10;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat radius = 4;
    self.borderLayer = [CAShapeLayer layer];
    UIBezierPath *beizerPath = [UIBezierPath bezierPath];
    [beizerPath moveToPoint:CGPointMake(arrowLong+radius, 0)];
    [beizerPath addLineToPoint:CGPointMake(width-radius, 0)];
    [beizerPath addArcWithCenter:CGPointMake(width-radius, radius) radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    //
    [beizerPath addLineToPoint:CGPointMake(width,height-radius)];
    [beizerPath addArcWithCenter:CGPointMake(width-radius, height-radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    //
    [beizerPath addLineToPoint:CGPointMake(arrowLong+radius,height)];
    [beizerPath addArcWithCenter:CGPointMake(arrowLong+radius, height-radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    //
    [beizerPath addLineToPoint:CGPointMake(arrowLong, (height-arrowLong)/2.0+arrowLong)];
    [beizerPath addLineToPoint:CGPointMake(0, (height/2.0))];
    [beizerPath addLineToPoint:CGPointMake(arrowLong, (height-arrowLong)/2.0)];
    //
    [beizerPath addLineToPoint:CGPointMake(arrowLong,radius)];
    [beizerPath addArcWithCenter:CGPointMake(arrowLong+radius,radius) radius:radius startAngle:M_PI endAngle:M_PI_2*3 clockwise:YES];
    self.borderLayer.lineWidth = 0.5;
    self.borderLayer.path = beizerPath.CGPath;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.borderLayer.strokeColor = [UIColor redColor].CGColor;
    [self.layer addSublayer:self.borderLayer];
}


- (void)drawBorderWithArrowLeftTop
{
    CGFloat arrowLong = 10;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat radius = 4;
    self.borderLayer = [CAShapeLayer layer];
    UIBezierPath *beizerPath = [UIBezierPath bezierPath];
    [beizerPath moveToPoint:CGPointMake(arrowLong, 0)];
    [beizerPath addLineToPoint:CGPointMake(width-radius, 0)];
    [beizerPath addArcWithCenter:CGPointMake(width-radius, radius) radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    
    //
    [beizerPath addLineToPoint:CGPointMake(width,height-radius)];
    [beizerPath addArcWithCenter:CGPointMake(width-radius, height-radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    
    //
    [beizerPath addLineToPoint:CGPointMake(arrowLong+radius,height)];
    [beizerPath addArcWithCenter:CGPointMake(arrowLong+radius, height-radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    
    //
    [beizerPath addLineToPoint:CGPointMake(arrowLong, arrowLong)];
    [beizerPath addLineToPoint:CGPointMake(0, arrowLong/2.0)];
    [beizerPath addLineToPoint:CGPointMake(arrowLong, 0)];

    self.borderLayer.lineWidth = 0.5;
    self.borderLayer.path = beizerPath.CGPath;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.borderLayer.strokeColor = [UIColor redColor].CGColor;
    [self.layer addSublayer:self.borderLayer];
}

- (void)drawBorderWithArrowLeftBottom
{
    CGFloat arrowLong = 10;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat radius = 4;
    self.borderLayer = [CAShapeLayer layer];
    UIBezierPath *beizerPath = [UIBezierPath bezierPath];
    [beizerPath moveToPoint:CGPointMake(arrowLong+radius, 0)];
    [beizerPath addLineToPoint:CGPointMake(width-radius, 0)];
    [beizerPath addArcWithCenter:CGPointMake(width-radius, radius) radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    
    //
    [beizerPath addLineToPoint:CGPointMake(width,height-radius)];
    [beizerPath addArcWithCenter:CGPointMake(width-radius, height-radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    
    //
    [beizerPath addLineToPoint:CGPointMake(arrowLong,height)];
    [beizerPath addLineToPoint:CGPointMake(0, (height-arrowLong/2.0))];
    [beizerPath addLineToPoint:CGPointMake(arrowLong, (height-arrowLong))];
    
    //
    [beizerPath addLineToPoint:CGPointMake(arrowLong, radius)];
    [beizerPath addArcWithCenter:CGPointMake(arrowLong+radius, radius) radius:radius startAngle:M_PI endAngle:M_PI_2*3 clockwise:YES];
    
    
    self.borderLayer.lineWidth = 0.5;
    self.borderLayer.path = beizerPath.CGPath;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.borderLayer.strokeColor = [UIColor redColor].CGColor;
    [self.layer addSublayer:self.borderLayer];
}

- (void)drawBorderWithArrowRightBottom
{
    CGFloat arrowLong = 10;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat radius = 4;
    self.borderLayer = [CAShapeLayer layer];
    UIBezierPath *beizerPath = [UIBezierPath bezierPath];
    [beizerPath moveToPoint:CGPointMake(radius, 0)];
    [beizerPath addLineToPoint:CGPointMake(width-arrowLong-radius, 0)];
    [beizerPath addArcWithCenter:CGPointMake(width-arrowLong-radius, radius) radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    //
    [beizerPath addLineToPoint:CGPointMake(width-arrowLong,height-arrowLong)];
    [beizerPath addLineToPoint:CGPointMake(width,height-arrowLong/2.0)];
    [beizerPath addLineToPoint:CGPointMake(width-arrowLong,height)];
    
    
    //
    [beizerPath addLineToPoint:CGPointMake(radius,height)];
    [beizerPath addArcWithCenter:CGPointMake(radius, height-radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [beizerPath addLineToPoint:CGPointMake(0,radius)];
    [beizerPath addArcWithCenter:CGPointMake(radius,radius) radius:radius startAngle:M_PI endAngle:M_PI_2*3 clockwise:YES];
    self.borderLayer.lineWidth = 0.5;
    self.borderLayer.path = beizerPath.CGPath;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.borderLayer.strokeColor = [UIColor redColor].CGColor;
    [self.layer addSublayer:self.borderLayer];
}
- (void)drawBorderWithArrowRightTop
{
    CGFloat arrowLong = 10;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat radius = 4;
    self.borderLayer = [CAShapeLayer layer];
    UIBezierPath *beizerPath = [UIBezierPath bezierPath];
    [beizerPath moveToPoint:CGPointMake(radius, 0)];
    [beizerPath addLineToPoint:CGPointMake(width-arrowLong, 0)];
    [beizerPath addLineToPoint:CGPointMake(width, arrowLong/2)];
    [beizerPath addLineToPoint:CGPointMake(width-arrowLong, arrowLong)];

    
    //
    [beizerPath addLineToPoint:CGPointMake(width-arrowLong,height-radius)];
    [beizerPath addArcWithCenter:CGPointMake(width-arrowLong-radius, height-radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    //
    
    [beizerPath addLineToPoint:CGPointMake(radius,height)];
    [beizerPath addArcWithCenter:CGPointMake(radius, height-radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    
    //
    [beizerPath addLineToPoint:CGPointMake(0,radius)];
    [beizerPath addArcWithCenter:CGPointMake(radius,radius) radius:radius startAngle:M_PI endAngle:M_PI_2*3 clockwise:YES];
    self.borderLayer.lineWidth = 0.5;
    self.borderLayer.path = beizerPath.CGPath;
    self.borderLayer.fillColor = [UIColor clearColor].CGColor;
    self.borderLayer.strokeColor = [UIColor redColor].CGColor;
    [self.layer addSublayer:self.borderLayer];
}




@end
