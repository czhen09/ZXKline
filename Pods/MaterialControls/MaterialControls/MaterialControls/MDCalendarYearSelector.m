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

#import <Foundation/Foundation.h>
#import "NSDate+MDExtension.h"
#import "MDCalendarYearSelector.h"
#import "MDCalendarYearSelectorViewCell.h"
#import "MDCalendar.h"

@interface MDCalendarYearSelector () <UITableViewDelegate,
UITableViewDataSource>
@property(nonatomic) NSMutableArray* dataArray;
@property(copy, nonatomic) NSDate* maximumDate;
@end

@implementation MDCalendarYearSelector {
}

- (instancetype)initWithFrame:(CGRect)frame
              withMiniminDate:(NSDate*)minDate
               andMaximumDate:(NSDate*)maxDate {
    self = [super initWithFrame:frame];
    if (self) {
        _minimumDate = minDate;
        _maximumDate = maxDate;
        
        [self setupDataArray];
        
        self.tableView =
        [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)
                                     style:UITableViewStylePlain];
        
        [self.tableView setShowsVerticalScrollIndicator:YES];
        self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.rowHeight = 70;
        [self addSubview:self.tableView];
        
        [self.tableView setDataSource:self];
        [self.tableView setDelegate:self];
    }
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView reloadData];
    
    [self relayout];
    return self;
}

- (void) setupDataArray;
{
  self.dataArray = [NSMutableArray new];
  for (int year = (int)[self.minimumDate mdYear]; year < (int)[self.maximumDate mdYear]; year++) {
    [self.dataArray addObject:[NSString stringWithFormat:@"%i", year]];
  }
}

- (void)layoutSubviews {
    // update selection rect when changed orientation
    NSIndexPath* newIndexPath =
    [NSIndexPath indexPathForRow:(_currentYear - [_minimumDate mdYear])
                       inSection:0];
    MDCalendarYearSelectorViewCell* cell = (MDCalendarYearSelectorViewCell*)
    [self.tableView cellForRowAtIndexPath:newIndexPath];
    cell.currentYear = YES;  // update rect
}
- (void)relayout {
    self.tableView.frame = self.frame;
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView*)theTableView
 numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell*)tableView:(UITableView*)theTableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    static NSString* cellIdentifier = @"yearCell";
    MDCalendarYearSelectorViewCell* cell = (MDCalendarYearSelectorViewCell*)
    [theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MDCalendarYearSelectorViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellIdentifier];
        cell.titleColors = _titleColors;
        cell.backgroundColors = _backgroundColors;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        CGRect frame = [theTableView rectForRowAtIndexPath:indexPath];
        cell.mdHeight = frame.size.height;  // use for selection rect
    }
   
    cell.currentYear = (_currentYear == [_minimumDate mdYear] + indexPath.item);
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.item];
    return cell;
}

- (void)setCurrentYear:(NSInteger)currentYear {
    if (_currentYear != currentYear) {
        NSIndexPath* newIndexPath =
        [NSIndexPath indexPathForRow:(_currentYear - [_minimumDate mdYear])
                           inSection:0];
        MDCalendarYearSelectorViewCell* cell = (MDCalendarYearSelectorViewCell*)
        [self.tableView cellForRowAtIndexPath:newIndexPath];
        cell.currentYear = NO;
        
        _currentYear = currentYear;
        newIndexPath =
        [NSIndexPath indexPathForRow:(currentYear - [_minimumDate mdYear])
                           inSection:0];
        cell = (MDCalendarYearSelectorViewCell*)
        [self.tableView cellForRowAtIndexPath:newIndexPath];
        cell.currentYear = YES;
    }
    NSIndexPath* newIndexPath =
    [NSIndexPath indexPathForRow:(_currentYear - [_minimumDate mdYear])
                       inSection:0];
    [self.tableView
     scrollToRowAtIndexPath:
     [NSIndexPath indexPathForRow:(currentYear - [_minimumDate mdYear])
                        inSection:newIndexPath.section]
     atScrollPosition:UITableViewScrollPositionMiddle
     animated:NO];
}

- (void) setMinimumDate:(NSDate *)minimumDate;
{
    _minimumDate = minimumDate;
    [self setupDataArray];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView*)theTableView
didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    if (_delegate) {
        [_delegate
         calendarYearDidSelected:([_minimumDate mdYear] + indexPath.item)];
    }
}
@end