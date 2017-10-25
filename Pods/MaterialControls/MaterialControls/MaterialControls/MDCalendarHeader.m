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

#import "MDCalendarHeader.h"
#import "MDCalendar.h"
#import "UIView+MDExtension.h"
#import "NSDate+MDExtension.h"
#import "NSCalendarHelper.h"
#import "NSDateHelper.h"

#define kBlueText                                                              \
  [UIColor colorWithRed:14 / 255.0 green:69 / 255.0 blue:221 / 255.0 alpha:1.0]

@interface MDCalendarHeader () <UICollectionViewDataSource,
                                UICollectionViewDelegate>

@property(copy, nonatomic) NSDateFormatter *dateFormatter;
@property(weak, nonatomic) UICollectionView *collectionView;
@property(weak, nonatomic) UICollectionViewFlowLayout *collectionViewFlowLayout;

@property(copy, nonatomic) NSDate *minimumDate;
@property(copy, nonatomic) NSDate *maximumDate;

@end

@implementation MDCalendarHeader

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self initialize];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self initialize];
  }
  return self;
}

- (void)initialize {
  _dateFormat = @"MMMM yyyy";
  _dateFormatter = [[NSDateFormatter alloc] init];
  _dateFormatter.dateFormat = _dateFormat;
  _scrollDirection = UICollectionViewScrollDirectionHorizontal;
  _minimumDate = [NSDateHelper mdDateWithYear:1970 month:1 day:1];
  _maximumDate = [NSDateHelper mdDateWithYear:2099 month:12 day:31];

  UICollectionViewFlowLayout *collectionViewFlowLayout =
      [[UICollectionViewFlowLayout alloc] init];
  collectionViewFlowLayout.scrollDirection =
      UICollectionViewScrollDirectionHorizontal;
  collectionViewFlowLayout.minimumInteritemSpacing = 0;
  collectionViewFlowLayout.minimumLineSpacing = 0;
  self.collectionViewFlowLayout = collectionViewFlowLayout;

  UICollectionView *collectionView =
      [[UICollectionView alloc] initWithFrame:CGRectZero
                         collectionViewLayout:_collectionViewFlowLayout];
  collectionView.scrollEnabled = NO;
  collectionView.userInteractionEnabled = NO;
  collectionView.backgroundColor = [UIColor clearColor];
  collectionView.dataSource = self;
  collectionView.delegate = self;
  [self addSubview:collectionView];
  [collectionView registerClass:[UICollectionViewCell class]
      forCellWithReuseIdentifier:@"cell"];
  [collectionView
      addObserver:self
       forKeyPath:@"contentSize"
          options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
          context:nil];
  self.collectionView = collectionView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if (object == _collectionView && [keyPath isEqualToString:@"contentSize"]) {
    [_collectionView removeObserver:self forKeyPath:@"contentSize"];
    CGFloat scrollOffset = self.scrollOffset;
    _scrollOffset = 0;
    self.scrollOffset = scrollOffset;
  }
}

- (void)layoutSubviews {
  [super layoutSubviews];
  _collectionViewFlowLayout.itemSize = CGSizeMake(self.mdWidth, self.mdHeight);
  _collectionView.frame = self.bounds;
}

- (NSInteger)numberOfSectionsInCollectionView:
    (UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return [_maximumDate mdMonthsFrom:_minimumDate] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewCell *cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:@"cell"
                                                forIndexPath:indexPath];
  UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
  if (!titleLabel) {
    titleLabel = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
    titleLabel.tag = 100;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:titleLabel];
  }
  titleLabel.font = self.titleFont;
  titleLabel.textColor = self.titleColor;
  NSDate *date = [_minimumDate mdDateByAddingMonths:indexPath.item];
  titleLabel.text = [_dateFormatter stringFromDate:date];

  return cell;
}

#pragma mark - Setter & Getter

- (void)setScrollOffset:(CGFloat)scrollOffset {
  if (_scrollOffset != scrollOffset) {
    _scrollOffset = scrollOffset;
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
      _collectionView.contentOffset = CGPointMake(
          (_scrollOffset)*_collectionViewFlowLayout.itemSize.width, 0);
    } else {
      _collectionView.contentOffset = CGPointMake(
          0, _scrollOffset * _collectionViewFlowLayout.itemSize.height);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      NSArray *cells = _collectionView.visibleCells;
      [cells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
      }];
    });
  }
}

- (void)setDateFormat:(NSString *)dateFormat {
  if (![_dateFormat isEqualToString:dateFormat]) {
    _dateFormat = [dateFormat copy];
    _dateFormatter.dateFormat = dateFormat;
    [self reloadData];
  }
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection {
  if (_scrollDirection != scrollDirection) {
    _scrollDirection = scrollDirection;
    _collectionViewFlowLayout.scrollDirection = scrollDirection;
    CGPoint newOffset = CGPointMake(
        scrollDirection == UICollectionViewScrollDirectionHorizontal
            ? (_scrollOffset - 0.5) * _collectionViewFlowLayout.itemSize.width
            : 0,
        scrollDirection == UICollectionViewScrollDirectionVertical
            ? _scrollOffset * _collectionViewFlowLayout.itemSize.height
            : 0);
    _collectionView.contentOffset = newOffset;
    if (scrollDirection == UICollectionViewScrollDirectionVertical) {
      _collectionViewFlowLayout.sectionInset =
          UIEdgeInsetsMake(0, self.mdWidth * 0.25, 0, self.mdWidth * 0.25);
    } else {
      _collectionViewFlowLayout.sectionInset = UIEdgeInsetsZero;
    }
    [_collectionView reloadData];
  }
}

#pragma mark - Public

- (void)reloadData {
  [_collectionView reloadData];
}

@end
