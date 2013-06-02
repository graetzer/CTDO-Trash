//
//  UIPlaceHolderTextView.h
//  Witzmaschine
//
//  Created by Simon Grätzer on 28.05.13.
//  Copyright (c) 2013 Simon Peter Grätzer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

- (void)textChanged:(NSNotification*)notification;

@end