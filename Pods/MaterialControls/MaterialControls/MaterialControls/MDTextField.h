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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MDTextFieldViewState) {
  MDTextFieldViewStateNormal,
  MDTextFieldViewStateHighlighted,
  MDTextFieldViewStateError,
  MDTextFieldViewStateDisabled
};

NS_ASSUME_NONNULL_BEGIN

@class AutoResizeTextView, MDTextField;

@protocol MDTextFieldDelegate <NSObject>

@optional

- (void)textFieldDidChange:(MDTextField *)textField;

- (BOOL)textFieldShouldBeginEditing:
    (MDTextField *)textField; // return NO to disallow editing.
- (void)textFieldDidBeginEditing:
    (MDTextField *)textField; // became first responder
- (BOOL)textFieldShouldEndEditing:
    (MDTextField *)textField; // return YES to allow editing to stop and to
                              // resign first responder status. NO to
                              // disallow the editing session to end
- (void)textFieldDidEndEditing:(MDTextField *)textField; // may be called if
                                                         // forced even if
                                                         // shouldEndEditing
                                                         // returns NO (e.g.
                                                         // view removed from
                                                         // window) or
                                                         // endEditing:YES
                                                         // called

- (BOOL)textField:(MDTextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:
                    (NSString *)string; // return NO to not change text

//- (BOOL)textFieldShouldClear:(MDTextField *)textField;               // called
// when clear button pressed. return NO to ignore (no notifications)
- (BOOL)textFieldShouldReturn:
    (MDTextField *)
        textField; // called when 'return' key pressed. return NO to ignore.

@end

NS_ASSUME_NONNULL_END
IB_DESIGNABLE
@interface MDTextField : UIControl

@property(null_unspecified, nonatomic) IBInspectable NSString *hint;
@property(null_unspecified, nonatomic) IBInspectable NSString *label;
@property(nonatomic) IBInspectable BOOL floatingLabel;
@property(nonatomic) IBInspectable BOOL highlightLabel;
@property(null_unspecified, nonatomic) IBInspectable NSString *errorMessage;
@property(nonatomic) IBInspectable NSInteger maxCharacterCount;

@property(null_unspecified, nonatomic) IBInspectable UIColor *normalColor;
@property(null_unspecified, nonatomic) IBInspectable UIColor *highlightColor;
@property(null_unspecified, nonatomic) IBInspectable UIColor *errorColor;
@property(null_unspecified, nonatomic) IBInspectable UIColor *disabledColor;
@property(null_unspecified, nonatomic) IBInspectable UIColor *textColor;
@property(null_unspecified, nonatomic) IBInspectable UIColor *hintColor;

@property(nonatomic, getter=isEnabled) IBInspectable BOOL enabled;
@property(nonatomic) IBInspectable BOOL autoComplete;
@property(nonatomic) IBInspectable BOOL singleLine;
@property(nonatomic) IBInspectable BOOL fullWidth;
@property(nonatomic) IBInspectable NSInteger minVisibleLines;
@property(nonatomic) IBInspectable NSInteger maxVisibleLines;
@property(null_unspecified, nonatomic) IBInspectable NSString *text;
@property(nonatomic) IBInspectable BOOL secureTextEntry;
@property(nonatomic) IBInspectable BOOL dividerAnimation;
@property(nonatomic) IBInspectable BOOL restrictInBounds;

@property(nonatomic) UIReturnKeyType returnKeyType;
@property(nonatomic) UIKeyboardType keyboardType;

@property(nonatomic) BOOL hasError;
@property(nonnull, nonatomic) UIFont *labelsFont;
@property(nonnull, nonatomic) UIFont *inputTextFont;
@property(nonnull, nonatomic) NSLayoutConstraint *textViewHeightConstraint;
@property(nullable, nonatomic) NSArray<NSString *> *suggestionsDictionary;

@property(nonatomic, nullable, weak) id<MDTextFieldDelegate> delegate;
@property(nonatomic, nullable, readwrite, strong) UIView *inputAccessoryView;

- (float)requiredHeightWithNumberOfTextLines:(NSUInteger)numberOfLines;

@end
