//
//  ZXMessageBoxView.h
//  GJB
//
//  Created by 郑旭 on 2017/9/7.
//  Copyright © 2017年 汇金集团SR. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, ArrowPosition) {
    ArrowPositionLeftTop = 0,
    ArrowPositionLeftBottom,
    ArrowPositionRightTop,
    ArrowPositionRightBottom,
    ArrowPositionLeftCenter,
    ArrowPositionRightCenter,
};
@interface ZXMessageBoxView : UIView

- (void)setNeedsDisplayWithOpen:(NSString *)open close:(NSString *)close high:(NSString *)high low:(NSString *)low arrowPosition:(ArrowPosition)arrowPosition;
@end
