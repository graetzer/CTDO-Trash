//
//  SGViewController.m
//  CTDO Trash
//
//  Created by Simon Grätzer on 01.06.13.
//  Copyright (c) 2013 Simon Peter Grätzer. All rights reserved.
//

#import "SGUploadController.h"
#import "SGAppDelegate.h"
#import "AFNetworking.h"
#import "DejalActivityView.h"

@implementation SGUploadController {
    NSArray *_validity;
    NSUInteger _validitySelection;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"knitting"]];
    
    _validity = @[@"30 Minuten", @"60 Minuten", @"12 Stunden", @"24 Stunden",
                  @"1 Woche", @"1 Monat", @"3 Monate", @"6 Monate", @"12 Monate"];
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    pickerView.showsSelectionIndicator = YES;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    self.validityField.inputView = pickerView;
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0,0, 320, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self action:@selector(inputAccessoryViewDidFinish:)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil action:nil];
    [toolbar setItems:@[space, doneButton] animated:NO];
    self.validityField.inputAccessoryView = toolbar;
    self.validityField.text = _validity[0];
    _validitySelection = 0;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeInteger:_validitySelection forKey:@"validitySelection"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    _validitySelection = [coder decodeIntegerForKey:@"validitySelection"];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return textField != self.validityField;
}

- (IBAction)inputAccessoryViewDidFinish:(id)sender {
    [self.validityField resignFirstResponder];
}

#pragma mark - Picker

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return _validity.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _validity[row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.validityField.text = _validity[row];
    _validitySelection = row;
}

#pragma  mark - Image Picker
- (IBAction)pickFromLibrary:(id)sender {
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
    if ([UIImagePickerController isSourceTypeAvailable:type] == NO)
        return;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = type;
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:type];
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = self;
    [self presentViewController:mediaUI animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        UIImage *originalImage, *editedImage, *imageToUse;
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        
        originalImage = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];
        
        if (editedImage) imageToUse = editedImage; 
        else imageToUse = originalImage;
        
        self.fileName = @"picture.png";
        self.mimeType = @"image/png";
        self.uploadData = UIImagePNGRepresentation(imageToUse);
        
        self.statusLabel.text = NSLocalizedString(@"Sie haben ein Bild gewählt", nil);
    }
    
    // Handle a movied picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *url = [info objectForKey: UIImagePickerControllerMediaURL];
        self.fileName = @"video.mov";//url.lastPathComponent;
        self.mimeType = @"video/mp4";
        self.uploadData = [NSData dataWithContentsOfURL:url];
        
        self.statusLabel.text = NSLocalizedString(@"Sie haben ein Video gewählt", nil);
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)upload:(id)sender {
    [DejalBezelActivityView activityViewForView:appDelegate.window.rootViewController.view];
    
    NSString *val = [NSString stringWithFormat:@"%d", _validitySelection+1];
    NSDictionary *params = @{@"action":@"upload",
                             @"validity":val};
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
                NSURL *url = op.response.URL;
                NSDictionary *result = @{@"url":url.absoluteString, @"date":[NSDate date]};
                self.completionHandler(result, nil);
            }

            [DejalBezelActivityView removeViewAnimated:YES];
            [self.navigationController popViewControllerAnimated:YES];
    }
                                     failure:^(AFHTTPRequestOperation *op, NSError *error){
                                         if (self.completionHandler) self.completionHandler(nil, error);
                                         [DejalBezelActivityView removeViewAnimated:YES];
                                         [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [appDelegate.httpClient enqueueHTTPRequestOperation:operation];
}

- (IBAction)chooseValidity:(id)sender {
    [self.validityField becomeFirstResponder];
}


@end
