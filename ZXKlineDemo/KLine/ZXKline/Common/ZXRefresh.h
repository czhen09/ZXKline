//
//  ZXRefresh.h
//  GJB
//
//  Created by 郑旭 on 2017/9/20.
//  Copyright © 2017年 汇金集团SR. All rights reserved.
//

#import <UIKit/UIKit.h>
/** 刷新控件的状态 */
typedef NS_ENUM(NSInteger, ZXRefreshState) {
    /** 普通闲置状态 */
    ZXRefreshStateIdle = 1,
    /** 松开就可以进行刷新的状态 */
    ZXRefreshStatePulling,
    /** 正在刷新中的状态 */
    ZXRefreshStateRefreshing,
    /** 即将刷新的状态 */
    ZXRefreshStateWillRefresh,
    /** 所有数据加载完毕，没有更多的数据了 */
    ZXRefreshStateNoMoreData,
    /** 请求失败状态 */
    ZXRefreshStateRequestFailure
};
@interface ZXRefresh : UIView
- (instancetype)init;
@property (nonatomic,assign) ZXRefreshState refreshState;
@end
