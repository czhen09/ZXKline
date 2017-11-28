# ZXKLine  

![image](https://github.com/czhen09/ZXKline/blob/master/Resource/Animation.gif)



## 1.简介篇   
* 蜡烛图和山形图绘制切换  
* 5种指标绘制切换
* 长按蜡烛和指标线详情展示  
* 触底加载更多   
* 实时蜡烛绘制实现 
* 二级横屏和蜡烛三级横屏 
![image](https://github.com/czhen09/ZXKline/blob/master/Resource/fullScreen1.png)
![image](https://github.com/czhen09/ZXKline/blob/master/Resource/fullScreen2.png)
* 适配两种布局   
![image](https://github.com/czhen09/ZXKline/blob/master/Resource/UI1.png)
![image](https://github.com/czhen09/ZXKline/blob/master/Resource/UI2.png)


## 2.原理篇 
## 2.1 tableView作为画布依耐   
### 为什么选择了tableView
* 尝试是否能对绘制有candle的Cell进行复用；   
* 换个思维造轮子;    

### 需要解决的问题：变纵向滚动为纵向滚动  
![image](https://github.com/czhen09/ZXKline/blob/master/Resource/%E6%97%8B%E8%BD%AC.png)

* 如图所示：在旋转时，是绕tableView中心进行旋转的，为了使旋转后的tableView的frame能够和superView的大小一致，那么就要使旋转前的tableView偏移一定距离；  


		.
		.
		self.tableView.transform = CGAffineTransformMakeRotation(-M_PI/2);
		.
		.
		[self.view addSubview:self.tableView];
		.
		.
		[self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
       	   	make.left.mas_equalTo((width-height)/2);
       		make.top.mas_equalTo(-(width-height)/2);
       		make.width.mas_equalTo(height);
      	   	make.height.mas_equalTo(width);
    	}];  
    	

* 优缺点:虽然进行到后面，蜡烛全是用CAShapeLayer+UIBeizerPath绘制的，cell的复用并没有起到多大的作用，并且旋转之后涉及到了tableView的x，y坐标在使用中的转换(这点大家注意下),但是能感到庆幸的是：使用了cell之后，在计算蜡烛横坐标的时候就是cell.indexPath.row*rowHeight;再者就是在缩放的时候，可以直接修改cell的高度就可以达到缩放的目的；


## 2.2 缩放   
### 缩放有度  

	- (void)pinchAction:(UIPinchGestureRecognizer *)sender
	{ 
		static CGFloat oldScale = 1.0f;
   	    CGFloat difValue = sender.scale - oldScale;
    	NSLog(@"difValue=====%f",difValue);
   	    NSLog(@"oldScale=====%f",oldScale);
   	    if (ABS(difValue)>StockChartScaleBound) {
        
        CGFloat oldKlineWidth = self.candleWidth;
        // NSLog(@"原来的index%ld",oldNeedDrawStartIndex);
        self.candleWidth = oldKlineWidth * ((difValue > 0) ? (1+StockChartScaleFactor):(1-StockChartScaleFactor));
        oldScale = sender.scale;
        if (self.candleWidth < scale_MinValue) {
            
            self.candleWidth = scale_MinValue;
        }else if (self.candleWidth > scale_MaxValue)
        {
            self.candleWidth = scale_MaxValue;
        }
      }
    }
	  
	  
- 在每次缩放的时候，进行判断：    
1)只有触发的缩放大于某个预订值的时候才进行缩放  
2）控制每次缩放的比率；  
3）控制缩放的总体范围；

`2017-11-28新增变动:关乎缩放`由于之前阀值在大于0.03的时候才进行缩放,每次缩放的幅度也是0.03;导致了缩放过程假象的"卡顿";后面将StockChartScaleBound设置为了0, StockChartScaleFactor设置为了1;增强了缩放的灵敏性.

### 定点缩放  

	//这句话达到让tableview在缩放的时候能够保持缩放中心点不变；
    //实现原理：在放大缩小的时候，计算出变化后和变化前中心点的距离，然后为了保持中心点的偏移值始终保持不变，就直接在原来的偏移上加减变换的距离
    //ceil(centerPoint.y/oldKlineWidth)中心点前面的cell个数
    //self.rowHeight-oldKlineWidth每个cell的高度的变化
    CGFloat pinchOffsetY  = ceil(centerPoint.y/oldKlineWidth)*(self.candleWidth-oldKlineWidth)+oldNeedDrawStartPointY;
    if (pinchOffsetY<0) {
        
        pinchOffsetY = 0;
    }
    if (pinchOffsetY+self.subViewWidth>self.kLineModelArr.count*self.candleWidth) {
        
        pinchOffsetY = self.kLineModelArr.count*self.candleWidth - self.subViewWidth;
    }
    
    [self.tableView setContentOffset:CGPointMake(0, pinchOffsetY)];
    
    
##2.3 实现原理   
### 宏观布局  
#### 两个关键参数:  
  
  * 屏幕中显示的第一个蜡烛图的X坐标:  

		NSUInteger leftArrCount = ABS(scrollViewOffsetX/self.candleWidth);
  	 	_needDrawStartIndex = leftArrCount;      
  	 	
  * 屏幕中能够显示的蜡烛个数:
   
		 - (NSInteger)needDrawKlineCount
		{
		    CGFloat width = self.subViewWidth;
		    _needDrawKlineCount = ceil(width/self.candleWidth);
		    return _needDrawKlineCount;
		}    
	根据这两个参数，起点和长度，就可以从数据源数组中准确的取出当前屏幕显示的蜡烛图的数据;然后滑动过程中实时计算并进行坐标转换    


#### 坐标相关换算  
* 极值：从当前屏幕显示的数据源数组获取的最大值和最小值  
* 单位价格所代表的像素值   
		  
		self.heightPerPoint = self.candleChartHeight/(self.maxAssert-self.minAssert);  
      
* 开收高低值从价格转换成像素值  

### 蜡烛绘制     
CAShapeLayer+UIBeizerPath     
## 2.4 Socket数据结算  
`详见ZXSocketDataReformer`   
针对服务器返回的数据格式：@"时间戳,实时价格";我们需要利用这一个个的数据自己构建蜡烛模型;     

* 第一模型构建:假如一分钟返回80个数据, 那么我们需要判断这一分钟开始的时候,并且取出这一分钟的第一个数据First,构建一个全新的模型A;模型A的开.收.高.低价都是第一数据的实时价格;   
* 模型替换:第一个模型构建之后,新的数据Second到来,那么我们比较得出高值和低值替换模型A的高低值,并且此时模型A的收盘价为数据Second的实时价格;   
* 模型结算(重点):   
结算:就是对个M1\M5\M15..中返回的所有数据自己结算出一个蜡烛模型,也就是四个值:开\收\高\低;   
结算的事件点判断方式:  
	1)以socket返回数据的时间戳结算:这样结算在数据上不会有什么误差,但是时间上会有误差;  eg:针对M1而言,假如在6'58''的时候返回此分蜡烛的最后一个值,如果用socket的时间作为结算的话,那么我们必须等到下一个socket返回值的时间戳到来才能结算,假如socket在7'00''-7'01''之间返回了数据的话,很好,我们可以直接结算上一个蜡烛,并且及时的创建一个新的蜡烛模型;但是数据并不是每次都会变化如此频繁,如果下一个数据的到来是7'16'';那么中间这18'',k线图会静止18'',那么相当于6'的那个蜡烛会延迟16''进行推进,便造成了时间上的误差;并且当数据涨停或者停牌的时候,socket数据没有变动,便不会返回数据,那么这个时间k线图也是不会有任何动作;      
	2)以请求服务器时间戳结算:会导致数据上的误差;eg:在7'00''需要结算,但是这个时间socket在7'00''的时候返回了多个数据,但是结算的时候只会取到其中一个数据作为6'的收盘价,其他数据将遗留到下个蜡烛;      
解决:   
	1)以socket和服务器的时间戳相结合的方式进行结算:我在`ZXSocketDataReformer `中也是这么做的,第一次请求服务器时间,然后本地安装定时器进行服务器时间同步; 由socket时间戳进行模型构造,到了整点,优先socket进行模型推进,如果整点的时候没有socket返回,就由服务器时间进行推进;     
	2)定时器由服务器创建,最好就是在整点延迟1秒的时候,如果在00''-01''的时候已经有socket数据传送到移动端的话,那么就不需要推送假数据,如果没有socket数据产生,就推送一个假数据到移动端,告诉移动端,数据需要进行结算,移动端只需要用socket进行结算; (好吧,自己都绕晕了,如果要求不是那么高其实仅仅按照socket进行数据结算也够用了);
	
`2017-11-28新增变动:关乎Socket`最后挣扎中抛弃了定时器;定时器虽然可以一定程度保证时间上的准确性,但是有时候会导致误判,比如服务器真的崩了的时候,但是本地依然在画横线;所以为了不造成对用户的误判,数据的正确性就交个服务器去保证.没有数据的时候没有k线返回也总比返回错误的k线好!

## 2.5 实时绘制  
考虑如下情况：    
![image](https://github.com/czhen09/ZXKline/blob/master/Resource/%E5%AE%9E%E6%97%B6%E7%BB%98%E5%88%B6.png)  


代码大概是这样的 : 

	- (void)handleNewestCellWhenScrollToBottomWithNewKlineModel:(KlineModel *)klineModel

	{
   			
	   	 //==0的时候需要插入一个新的cell；否则只需要刷新最后一个cell
	    if (self.isNew) {
	        
	        KlineModel *newsDataModel =  [self calulatePositionWithKlineModel:klineModel];
	        [self.kLineModelArr addObject:newsDataModel];
	        
	        double oldMax = self.maxAssert;
	        double oldMin = self.minAssert;
	        
	        
	        [self calculateNeedDrawKlineArr];
	        [self calculateMaxAndMinValueWithNeedDrawArr:self.needDrawKlineArr];
	        
	        //不等的话就重绘
	        if (oldMax<self.maxAssert||oldMin>self.minAssert) {
	            
	            
	            dispatch_async(dispatch_get_main_queue(), ^{
	                
	                [self.tableView setContentOffset:CGPointMake(0, (self.kLineModelArr.count-self.needDrawKlineCount)*self.candleWidth+(self.needDrawKlineCount*self.candleWidth-self.subViewWidth))];
	            });
	            
	            [self drawTopKline];
	            
	        }else{
	            //否则就插入
	            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.kLineModelArr.count-1 inSection:0];
	            dispatch_async(dispatch_get_main_queue(), ^{
	                
	                //先增加  再偏移
	                [self.tableView beginUpdates];
	                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
	                [self.tableView endUpdates];
	                [self.tableView setContentOffset:CGPointMake(0, (self.kLineModelArr.count-self.needDrawKlineCount)*self.candleWidth+(self.needDrawKlineCount*self.candleWidth-self.subViewWidth))];
	            });
	            
	            [self delegateToReturnKlieArr];
	        }
	        
	    }else{
	        
	        
	        KlineModel *newsDataModel =  [self calulatePositionWithKlineModel:klineModel];
	        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.kLineModelArr.count-1 inSection:0];
	        
	        [self.kLineModelArr replaceObjectAtIndex:self.kLineModelArr.count-1 withObject:newsDataModel];
	        
	        
	        CGFloat oldMax = self.maxAssert;
	        CGFloat oldMin = self.minAssert;
	        
	        
	        [self calculateNeedDrawKlineArr];
	        [self calculateMaxAndMinValueWithNeedDrawArr:self.needDrawKlineArr];
	        //如果计算出来的最新的极值不在上一次计算的极值直接的话就重绘，否则就刷新最后一个即可
	        if (oldMax<self.maxAssert||oldMin>self.minAssert) {
	            
	            [self drawTopKline];
	            
	        }else{
	            
	            dispatch_async(dispatch_get_main_queue(), ^{
	                
	                [self.tableView beginUpdates];
	                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
	                [self.tableView endUpdates];
	                [self delegateToReturnKlieArr];
	            });
	            
	        }
	        
	    }
    
	}



实际使用过程中在insert或者reloadrows的时候，偶尔会出现崩溃,暂时还没解决,索性改为了直接重绘全屏了(我内心也是拒绝的),若是你们也不甘心让它直接重绘,可到--ZXMainView.m--- (void)handleNewestCellWhenScrollToBottomWithNewKlineModel:(KlineModel *)klineModel;打开注释的方法，终结了它;   



## 3.使用篇
## 3.1 基本使用 
* 基本的k线图的接入可以在demo中`SecondStepViewController`中看到,运行需在appDelegate中切换rootViewController;  
* `JoinUpSocketViewController`是接入socket实时绘制的demo,为了脱敏，控制器中的socket数据是随机产生的;  
* 具体的接入代码或者接口都可以在demo中看到,这里不做过多描述;  
   
## 3.2 使用注意  
### 3.2.1 历史数据转模型   
(详见`Reformer`---`ZXCandleDataReformer`)
本地历史数据格式为:  

	/*
     @[@"时间戳,收盘价,开盘价,最高价,最低价,成交量",
     @"时间戳,收盘价,开盘价,最高价,最低价,成交量",
     @"时间戳,收盘价,开盘价,最高价,最低价,成交量",
     @"...",
     @"..."];
     */  
     
相应的模型转换格式为:

	- (NSArray<KlineModel *>*)transformDataWithDataArr:(NSArray *)dataArr currentRequestType:(NSString *)currentRequestType
	{
	    self.currentRequestType = currentRequestType;
	    //修改数据格式  →  ↓↓↓↓↓↓↓终点到啦↓↓↓↓↓↓↓↓↓  ←
	    NSMutableArray *tempArr = [NSMutableArray array];
	    __weak typeof(self) weakSelf = self;
	    [dataArr enumerateObjectsUsingBlock:^(NSString *dataStr, NSUInteger idx, BOOL * _Nonnull stop) {
	        
	        NSArray *strArr = [dataStr componentsSeparatedByString:@","];
	        KlineModel *model = [KlineModel new];
	        model.timestamp  = [strArr[0] integerValue];
	        model.timeStr = [weakSelf setTime:strArr[0]];
	        model.closePrice = [strArr[1] doubleValue];
	        model.openPrice = [strArr[2] doubleValue];
	        model.highestPrice = [strArr[3] doubleValue];
	        model.lowestPrice = [strArr[4] doubleValue];
	        if (strArr.count>=6) {
	            
	            model.volumn = @([strArr[5] doubleValue]);
	        }else{
	            model.volumn = @(0);
	        }
	        
	        model.x = idx;
	        [tempArr addObject:model];
	        model = nil;
	    }];
	    return tempArr;
	}
  
`历史数据模型转换需要使用者根据请求历史数据的实际格式进行转换;`
### 3.2.2 Socket数据转模型 
(详见`ZXSocketDataReformer`)    
在socket结算的时候，若需要服务器时间结合socket返回的时间共同完成一个蜡烛的时候，这里需要改为获取服务器时间;  
 
	- (void)requestServiceTime:(void(^)(NSInteger timesamp))success
	{
	    
		    //这里Demo使用的本地时间代替;正确的应该取下面的服务器时间
		    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
		    NSTimeInterval timestamp = [date timeIntervalSince1970];
		    success(timestamp);
		    
		    //获取服务器时间
		//    NSString *urlStr = @"服务器时间校对地址";
		//
		//    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
		//    self.manager.responseSerializer.acceptableContentTypes = [self.manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
		//    [self.manager GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
		//
		//        NSString *time = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		//        success([time integerValue]);
		//        //        NSLog(@"ServiceTime=%@",time);
		//
		//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
		//
		//    }];
	    
	}
### 3.2.3 布局修改     
(详见`ZXHeader.h`)   

#### 整体布局修改的几个宏     

	/**
	 * 价格坐标系在右边？YES->右边；NO->左边
	 */
	#define PriceCoordinateIsInRight YES     
	
	/**
	 * 蜡烛的信息配置的位置：YES->单独的view显示在view顶部；NO->弹框覆盖在蜡烛上
	 */
	#define IsDisplayCandelInfoInTop NO
	
#### 约束   
![image](https://github.com/czhen09/ZXKline/blob/master/Resource/%E5%B8%83%E5%B1%80.png)   

* 其中CandleChartHeight、QuotaChartHeight、MiddleBlankSpace都是可变的，所以分了横竖屏分别定义；其他尺寸都是固定的。   
*  由于在内部就对各个控件的UI进行了组装，所以就预留了相关的尺寸约束或者颜色宏，可以在ZXHeader文件中进行修改，如若有不能修改之处，就只有去ZXAssemblyView.m文件中进行修改了；

`从某种角度上来说,很多约束可以不改，但是宏中的TotalHeight必须根据项目需求进行修改`
  
 
### 3.2.4 横竖屏适配   
小技巧:因为我这里横屏之后是全屏并且隐藏了状态栏和导航栏的,为了旋转之后和竖屏的其他控件互不干扰,可以将assenblyView实例添加在self.view的最顶层,然后旋转过去之后就直接将其他控件覆盖在底层


   
## 4 其他问题    
1. 关于历史k线和socket衔接处暂未进行处理, 衔接还存在误差;     
2. 未知bug?待挖掘;   
3. k线图UI很简单,除了k线没有其他定制,但是接口都是完善的，主要是觉得关乎UI部分我做得越少，通用性就越高;   
4. 感谢Star;  
5. 有任何其他问题欢迎[Issues](https://github.com/czhen09/ZXKline/issues)或者简书留言;  
6. 超链:           

* Json转模型Mac版[ESJsonFormatForMac](https://github.com/czhen09/ESJsonFormatForMac)     
* 简书地址[ZXKline](http://www.jianshu.com/p/67977c27abad)    
