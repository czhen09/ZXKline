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
#import "MDDeviceHelper.h"
#import "MDSuggestPopupView.h"
#import "MDSuggestTableView.h"
#import "MDTableViewCell.h"
#import "MDTextField.h"

@implementation MDSuggestPopupView {
  MDSuggestTableView *tableView;
  MDTextField *mdTextField;
  NSMutableArray *suggestionOptions;
  UIView *popupHolder;
  float keyboardHeight;
}

NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";

- (id)initWithTextField:(MDTextField *)textField {
  if (self = [super init]) {
    mdTextField = textField;
    tableView = [[MDSuggestTableView alloc] init];
    popupHolder = [[UIView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.bounces = NO;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    popupHolder.layer.shadowOpacity = 0.5;
    popupHolder.layer.shadowRadius = 8;
    popupHolder.layer.shadowColor = [[UIColor blackColor] CGColor];
    popupHolder.layer.shadowOffset = CGSizeMake(0, 2.5);

    suggestionOptions = [NSMutableArray array];
    [self addSubview:popupHolder];
    [popupHolder addSubview:tableView];
    [self addSelfToMainWindow];
    self.hidden = YES;
    [self addTarget:self
                  action:@selector(btnClick:)
        forControlEvents:UIControlEventTouchUpInside];
    [self registerForKeyboardNotifications];
  }
  return self;
}

- (void)btnClick:(id)sender {
  self.hidden = YES;
}

- (void)addSelfToMainWindow {
  UIView *rootView = [MDDeviceHelper getMainView];
  if (rootView != nil) {
    self.translatesAutoresizingMaskIntoConstraints = false;
    [self setFrame:rootView.bounds];
    [rootView addSubview:self];
    NSDictionary *viewsDictionary = @{ @"view" : self };

    NSArray *hConstraints =
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|"
                                                options:0
                                                metrics:nil
                                                  views:viewsDictionary];
    NSArray *vConstraints =
        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|"
                                                options:0
                                                metrics:nil
                                                  views:viewsDictionary];
    [rootView addConstraints:hConstraints];
    [rootView addConstraints:vConstraints];
  }
}

- (UIView *)getSuperView:(UIView *)view {
  UIView *temp = view;
  while (temp.superview)
    temp = temp.superview;
  return temp;
}

- (void)registerForKeyboardNotifications {
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(keyboardWasShown:)
             name:UIKeyboardDidShowNotification
           object:nil];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(keyboardWillBeHidden:)
             name:UIKeyboardWillHideNotification
           object:nil];
}

- (void)unregisterForKeyboardNotifications {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)textView:(MDTextField *)textField didChangeText:(NSString *)text {
  if (mdTextField.autoComplete) {
    if ([text length] >= 1) {
      [self searchSuggestionOptionsWithSubString:text];
      if ([suggestionOptions count] >= 1) {
        [tableView reloadData];
        [self calculateFrame];
        self.hidden = NO;
        return;
      }
    }
  }

  self.hidden = YES;
}

- (void)searchSuggestionOptionsWithSubString:(NSString *)subString {
  [suggestionOptions removeAllObjects];
  if (_suggestionsDictionary)
    for (NSString *curString in _suggestionsDictionary) {
      NSRange substringRange =
          [curString rangeOfString:subString options:NSCaseInsensitiveSearch];
      if (substringRange.location == 0) {
        [suggestionOptions addObject:curString];
      }
    }
}

- (void)calculateFrame {
  CGRect textFieldFrame =
      [mdTextField convertRect:mdTextField.bounds toView:self];
  CGSize contenSize = tableView.contentSize;

  float x, y, width, height;

  float spaceToTop = textFieldFrame.origin.y;
  float spaceToBottom = self.bounds.size.height - keyboardHeight -
                        (textFieldFrame.origin.y + textFieldFrame.size.height);
  if ((spaceToBottom < contenSize.height) && (spaceToTop > spaceToBottom)) {
    x = textFieldFrame.origin.x;

    width = textFieldFrame.size.width;
    if (spaceToTop > contenSize.height) {
      y = spaceToTop - contenSize.height;
      height = contenSize.height;
    } else {
      y = 0;
      height = spaceToTop;
    }
  } else {
    x = textFieldFrame.origin.x;
    y = textFieldFrame.origin.y + textFieldFrame.size.height;
    width = textFieldFrame.size.width;
    height = MIN(spaceToBottom, contenSize.height);
  }

  CGRect frame = CGRectMake(x, y, width, height);

  [popupHolder setFrame:frame];
  [tableView setFrame:CGRectMake(0, 0, width, height)];
}

#pragma mark - TableView data source
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return [suggestionOptions count];
}
- (UITableViewCell *)tableView:(UITableView *)tv
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  MDTableViewCell *cell =
      [tv dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];

  if (cell == nil) {
    cell = [[MDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:AutoCompleteRowIdentifier];
  }

  cell.textLabel.font = mdTextField.inputTextFont;
  cell.textLabel.adjustsFontSizeToFitWidth = NO;
  cell.textLabel.text = [suggestionOptions objectAtIndex:indexPath.row];
  return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [mdTextField setText:[suggestionOptions objectAtIndex:indexPath.row]];

  self.hidden = YES;
}

#pragma mark - keyboard notification

- (void)keyboardWasShown:(NSNotification *)aNotification {
  NSDictionary *info = [aNotification userInfo];
  CGSize kbSize =
      [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  keyboardHeight = kbSize.height;
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification {
  keyboardHeight = 0;
}

@end
