//
//  SGLibraryUploadController.m
//  CTDO Trash
//
//  Created by Simon Grätzer on 25.07.13.
//  Copyright (c) 2013 Simon Peter Grätzer. All rights reserved.
//

#import "SGUploadController.h"
#import "SGAppDelegate.h"
#import "AFNetworking.h"
#import "DejalActivityView.h"

@implementation SGUploadController {
    NSArray *_expireStrings;
    NSUInteger _expireSelection;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"creampaper"]];
    
    UIImage *border = [UIImage imageNamed:@"border"];
    border = [border resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    for (UIButton *button in self.allButtons) {
        [button setBackgroundImage:border forState:UIControlStateNormal];
    }
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0,0, 320, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self action:@selector(inputAccessoryViewDidFinish:)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil action:nil];
    [toolbar setItems:@[space, doneButton] animated:NO];
    
    // Picker for the validity
    _expireStrings = @[@"30 Minuten", @"60 Minuten", @"12 Stunden", @"24 Stunden",
                       @"1 Woche", @"1 Monat", @"3 Monate", @"6 Monate", @"12 Monate"];
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    pickerView.showsSelectionIndicator = YES;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    self.expiresField.inputView = pickerView;
    self.expiresField.inputAccessoryView = toolbar;
    self.expiresField.text = _expireStrings[0];
    _expireSelection = 0;

    self.filenameLabel.text = [NSString stringWithFormat:@"Dateiname: %@", self.fileName];
    NSUInteger size = self.uploadData.length;
    
    if (size > 1024*1024) self.fileSizeLabel.text = [NSString stringWithFormat:@"Dateigröße: %.1f MBytes", size/(1024.*1024.)];
    else self.fileSizeLabel.text = [NSString stringWithFormat:@"Dateigröße: %.1f KBytes", size/1024.];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeInteger:_expireSelection forKey:@"expireSelection"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    _expireSelection = [coder decodeIntegerForKey:@"expireSelection"];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return textField != self.expiresField;
}

- (IBAction)inputAccessoryViewDidFinish:(id)sender {    
    if ([self.expiresField isFirstResponder]) [self.expiresField resignFirstResponder];
}

#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.expiresField.inputView == thePickerView) return _expireStrings.count;
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (self.expiresField.inputView == thePickerView) return _expireStrings[row];
    
    return nil;
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.expiresField.inputView == thePickerView) {
        self.expiresField.text = _expireStrings[row];
        _expireSelection = row;
    }
}

- (IBAction)upload:(id)sender {
    [DejalBezelActivityView activityViewForView:appDelegate.window.rootViewController.view
                                      withLabel:NSLocalizedString(@"Upload…", nil)];
    
    NSString *val = [NSString stringWithFormat:@"%d", _expireSelection+1];
    NSDictionary *params = @{@"action":@"upload", @"validity":val};
    NSMutableURLRequest *request = [appDelegate.httpClient multipartFormRequestWithMethod:@"POST"
                                                                                     path:@"/bintrash.php"
                                                                               parameters:params
                                                                constructingBodyWithBlock:^(id <AFMultipartFormData>formData) {
                                                                    [formData appendPartWithFileData:self.uploadData
                                                                                                name:@"upfile"
                                                                                            fileName:self.fileName
                                                                                            mimeType:self.mimeType];
                                                                }];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id respObj){
        if (self.completionHandler) {
            NSString *url = op.response.URL.absoluteString;
            NSRange r = [url rangeOfString:@"fileid="];
            NSString *fileID = [url substringFromIndex:r.location + r.length];
            
            NSString *urlString = [NSString stringWithFormat:@"http://trash.ctdo.de/b/%@", fileID];
            NSString *name = [NSString stringWithFormat:@"%@: %@", self.fileName, fileID];
            NSDictionary *result = @{@"url":urlString, @"date":[NSDate date], @"expires":self.expiresField.text, @"name":name};
            self.completionHandler(result, nil);
        }
        
        [DejalBezelActivityView removeViewAnimated:YES];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
                                     failure:^(AFHTTPRequestOperation *op, NSError *error){
                                         if (self.completionHandler) self.completionHandler(nil, error);
                                         [DejalBezelActivityView removeViewAnimated:YES];
                                         [self.navigationController popViewControllerAnimated:YES];
                                     }];
    
    [appDelegate.httpClient enqueueHTTPRequestOperation:operation];
}

- (IBAction)chooseValidity:(id)sender {
    [self.expiresField becomeFirstResponder];
}

@end
