//
//  ZXCandleDetailView.h
//  ZXKlineDemo
//
//  Created by 郑旭 on 2017/8/10.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZXCandleDetailView : UIView
- (instancetype)init;
- (void)jointWithNewDetailString:(NSString *)jointString;
- (void)jointWithNewAttributedString:(NSAttributedString *)jointAttributedString;
- (void)reloadQuotaDetailViewWithQuotaDetailString:(NSString *)quotaDetailString;
- (void)reloadQuotaDetailViewWithQuotaAttributedString:(NSAttributedString *)quotaAttributedString;
@end
