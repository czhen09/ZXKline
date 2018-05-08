// The MIT License (MIT)
//
// Copyright (c) 2015 FPT Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MDTabBarViewController.h"

@interface MDTabBarViewController () <
    MDTabBarDelegate, UIPageViewControllerDelegate,
    UIPageViewControllerDataSource, UIScrollViewDelegate>
@end

@implementation MDTabBarViewController {
  UIPageViewController *pageController;
  NSMutableDictionary *viewControllers;
  NSUInteger lastIndex;
  BOOL disableDragging;
}

- (instancetype)initWithDelegate:(id)delegate {
  if (self = [super init]) {
    self.delegate = delegate;
    [self initContent];
  }

  return self;
}

- (void)initContent {
  _tabBar = [[MDTabBar alloc] init];
  _tabBar.delegate = self;

  // create page controller
  pageController = [[UIPageViewController alloc]
      initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
        navigationOrientation:
            UIPageViewControllerNavigationOrientationHorizontal
                      options:nil];
  pageController.delegate = self;
  pageController.dataSource = self;

  // delegate scrollview
  for (UIView *v in pageController.view.subviews) {
    if ([v isKindOfClass:[UIScrollView class]]) {
      ((UIScrollView *)v).delegate = self;
    }
  }

  // add page controller as child
  [self addChildViewController:pageController];
  [pageController didMoveToParentViewController:self];

  viewControllers = [[NSMutableDictionary alloc] init];
}

- (void)addConstraints {
  [_tabBar setTranslatesAutoresizingMaskIntoConstraints:NO];
  [pageController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
  [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];

  // create constraints
  UIView *parentView = self.view;
  UIView *pageControllerView = pageController.view;
  //  pageControllerView.backgroundColor = [UIColor blueColor];

  NSDictionary *viewsDictionary =
      NSDictionaryOfVariableBindings(parentView, _tabBar, pageControllerView);

  NSDictionary *metricsDictionary = @{ @"tabHeight" : @kMDTabBarHeight };

  [self.view addConstraints:[NSLayoutConstraint
                                constraintsWithVisualFormat:@"V:|-0-[_tabBar(=="
                                @"tabHeight)]-0-[pageControllerView]-0-|"
                                                    options:0
                                                    metrics:metricsDictionary
                                                      views:viewsDictionary]];
  [self.view addConstraints:[NSLayoutConstraint
                                constraintsWithVisualFormat:@"H:|[_tabBar]|"
                                                    options:0
                                                    metrics:metricsDictionary
                                                      views:viewsDictionary]];
  [self.view
      addConstraints:[NSLayoutConstraint
                         constraintsWithVisualFormat:@"H:|[pageControllerView]|"
                                             options:0
                                             metrics:metricsDictionary
                                               views:viewsDictionary]];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [self.view addSubview:pageController.view];
  [self.view addSubview:_tabBar];
  [self addConstraints];
  // first view controller
  id viewController =
      [self.delegate tabBarViewController:self
                    viewControllerAtIndex:_tabBar.selectedIndex];
  [viewControllers
      setObject:viewController
         forKey:[NSNumber numberWithInteger:_tabBar.selectedIndex]];

  __unsafe_unretained typeof(self) weakSelf = self;
  [pageController
      setViewControllers:@[ viewController ]
               direction:UIPageViewControllerNavigationDirectionForward
                animated:NO
              completion:^(BOOL finished) {
                if ([weakSelf->_delegate
                        respondsToSelector:@selector(tabBarViewController:
                                                           didMoveToIndex:)]) {
                  [weakSelf->_delegate
                      tabBarViewController:weakSelf
                            didMoveToIndex:weakSelf->_tabBar.selectedIndex];
                }
              }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma Public functions
- (void)setItems:(NSArray *)items {
  [_tabBar setItems:items];
}

#pragma PageViewControllerDataSource
- (UIViewController *)pageViewController:
                          (UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController {

  NSInteger index = _tabBar.selectedIndex;

  if (index++ < _tabBar.numberOfItems - 1) {

    UIViewController *nextViewController =
        [viewControllers objectForKey:[NSNumber numberWithInteger:index]];

    if (!nextViewController) {
      nextViewController =
          [self.delegate tabBarViewController:self viewControllerAtIndex:index];
      [viewControllers setObject:nextViewController
                          forKey:[NSNumber numberWithInteger:index]];
    }

    return nextViewController;
  }

  return nil;
}

- (UIViewController *)pageViewController:
                          (UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {

  NSInteger index = _tabBar.selectedIndex;

  if (index-- > 0) {
    UIViewController *nextViewController =
        [viewControllers objectForKey:[NSNumber numberWithInteger:index]];

    if (!nextViewController) {
      nextViewController =
          [self.delegate tabBarViewController:self viewControllerAtIndex:index];
      [viewControllers setObject:nextViewController
                          forKey:[NSNumber numberWithInteger:index]];
    }

    return nextViewController;
  }

  return nil;
}

#pragma mark Setters
- (void)setSelectedIndex:(NSUInteger)selectedIndex {
  _tabBar.selectedIndex = selectedIndex;
  [self moveToPage:selectedIndex];
}

#pragma mark Getter
- (NSUInteger)selectedIndex {
  return _tabBar.selectedIndex;
}

- (void)moveToPage:(NSUInteger)selectedIndex {
  UIViewController *viewController =
      [viewControllers objectForKey:[NSNumber numberWithInteger:selectedIndex]];

  if (!viewController) {
    viewController = [self.delegate tabBarViewController:self
                                   viewControllerAtIndex:selectedIndex];
    [viewControllers setObject:viewController
                        forKey:[NSNumber numberWithInteger:selectedIndex]];
  }

  UIPageViewControllerNavigationDirection animateDirection =
      selectedIndex > lastIndex
          ? UIPageViewControllerNavigationDirectionForward
          : UIPageViewControllerNavigationDirectionReverse;

  __unsafe_unretained typeof(self) weakSelf = self;
  disableDragging = YES;
  pageController.view.userInteractionEnabled = NO;
  [pageController
      setViewControllers:@[ viewController ]
               direction:animateDirection
                animated:YES
              completion:^(BOOL finished) {
                weakSelf->disableDragging = NO;
                weakSelf->pageController.view.userInteractionEnabled = YES;
                weakSelf->lastIndex = selectedIndex;

                if ([weakSelf->_delegate
                        respondsToSelector:@selector(tabBarViewController:
                                                           didMoveToIndex:)]) {
                  [weakSelf->_delegate tabBarViewController:weakSelf
                                             didMoveToIndex:selectedIndex];
                }
              }];
}

#pragma mark - PageViewController Delegate
- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed {
  if (!completed)
    return;

  id currentView = [pageViewController.viewControllers objectAtIndex:0];

  NSNumber *key = (NSNumber *)[viewControllers allKeysForObject:currentView][0];
  _tabBar.selectedIndex = [key integerValue];
  lastIndex = _tabBar.selectedIndex;

  // call delegate
  if ([self.delegate
          respondsToSelector:@selector(tabBarViewController:didMoveToIndex:)]) {
    [self.delegate tabBarViewController:self
                         didMoveToIndex:_tabBar.selectedIndex];
  }
}

#pragma mark - MDTabBar Delegate
- (void)tabBar:(MDTabBar *)tabBar
    didChangeSelectedIndex:(NSUInteger)selectedIndex {
  [self moveToPage:selectedIndex];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

  CGPoint offset = scrollView.contentOffset;

  CGFloat scrollViewWidth = scrollView.frame.size.width;

  int selectedIndex = (int)_tabBar.selectedIndex;

  if (!disableDragging) {
    float xDriff = offset.x - scrollViewWidth;
    UIView *selectedTab = (UIView *)[_tabBar tabs][selectedIndex];

    if (offset.x < scrollViewWidth) {
      if (_tabBar.selectedIndex == 0)
        return;

      UIView *leftTab = (UIView *)[_tabBar tabs][selectedIndex - 1];

      float widthDiff = selectedTab.frame.size.width - leftTab.frame.size.width;

      float newOriginX = selectedTab.frame.origin.x +
                         xDriff / scrollViewWidth * leftTab.frame.size.width;

      float newWidth =
          selectedTab.frame.size.width + xDriff / scrollViewWidth * widthDiff;

      CGRect frame =
          CGRectMake(newOriginX, kMDTabBarHeight - kMDIndicatorHeight, newWidth,
                     kMDIndicatorHeight);
      [_tabBar moveIndicatorToFrame:frame withAnimated:NO];

    } else {
      if (selectedIndex + 1 >= _tabBar.numberOfItems)
        return;

      UIView *rightTab = (UIView *)[_tabBar tabs][selectedIndex + 1];

      float widthDiff =
          rightTab.frame.size.width - selectedTab.frame.size.width;

      float newOriginX =
          selectedTab.frame.origin.x +
          xDriff / scrollViewWidth * selectedTab.frame.size.width;

      float newWidth =
          selectedTab.frame.size.width + xDriff / scrollViewWidth * widthDiff;

      CGRect frame =
          CGRectMake(newOriginX, kMDTabBarHeight - kMDIndicatorHeight, newWidth,
                     kMDIndicatorHeight);
      [_tabBar moveIndicatorToFrame:frame withAnimated:NO];
    }
  }
}

@end
