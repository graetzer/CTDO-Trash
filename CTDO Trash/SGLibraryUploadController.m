//
//  SGViewController.m
//  CTDO Trash
//
//  Created by Simon Grätzer on 01.06.13.
//  Copyright (c) 2013 Simon Peter Grätzer. All rights reserved.
//

#import "SGLibraryUploadController.h"
#import "SGAppDelegate.h"
#import "AFNetworking.h"
#import "DejalActivityView.h"
#import "UIImage+Scaling.h"

@implementation SGLibraryUploadController {
    NSArray *_imageSizeStrings;
    NSUInteger _imageSizeSelection;
    
    NSArray *_expireStrings;
    NSUInteger _expireSelection;
    
    UIImage *_selectedImage;
    NSData *_data;
    NSString *_filename;
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
    
    // Picker for the resizing of images
    _imageSizeStrings = @[@"1/1", @"1/2", @"1/3", @"1/4", @"1/5"];
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    pickerView.showsSelectionIndicator = YES;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    self.imageSizeField.inputView = pickerView;
    self.imageSizeField.inputAccessoryView = toolbar;
    self.imageSizeField.text = _imageSizeStrings[0];
    _imageSizeSelection = 0;
    
    // Picker for the validity
    _expireStrings = @[@"30 Minuten", @"60 Minuten", @"12 Stunden", @"24 Stunden",
                  @"1 Woche", @"1 Monat", @"3 Monate", @"6 Monate", @"12 Monate"];
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    pickerView.showsSelectionIndicator = YES;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    self.expiresField.inputView = pickerView;
    self.expiresField.inputAccessoryView = toolbar;
    self.expiresField.text = _expireStrings[0];
    _expireSelection = 0;
    
    
//    if (self.uploadData != nil) {
//        self.selectFileButton.enabled = NO;
//        self.imageSizeField.enabled = NO;
//        self.imageSizeButton.enabled = NO;
//        
//        NSUInteger size = self.uploadData.length;
//        self.statusLabel.text =  NSLocalizedString(@"Sie haben bereits eine Datei gewählt", nil);
//        
//        if (size > 1024*1024) self.fileSizeLabel.text = [NSString stringWithFormat:@"Dateigröße: %.1f MBytes", size/(1024.*1024.)];
//        else self.fileSizeLabel.text = [NSString stringWithFormat:@"Dateigröße: %.1f KBytes", size/1024.];
//    } else {
        self.fileSizeLabel.text = nil;
//    }
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeInteger:_expireSelection forKey:@"expireSelection"];
    [coder encodeInteger:_imageSizeSelection forKey:@"imageSizeSelection"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    _expireSelection = [coder decodeIntegerForKey:@"expireSelection"];
    _imageSizeSelection = [coder decodeIntegerForKey:@"imageSizeSelection"];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return textField != self.expiresField;
}

- (IBAction)inputAccessoryViewDidFinish:(id)sender {
    if ([self.imageSizeField isFirstResponder]) [self.imageSizeField resignFirstResponder];
    
    if ([self.expiresField isFirstResponder]) [self.expiresField resignFirstResponder];
}

#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.imageSizeField.inputView == thePickerView) return _imageSizeStrings.count;
    if (self.expiresField.inputView == thePickerView) return _expireStrings.count;
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (self.imageSizeField.inputView == thePickerView) return _imageSizeStrings[row];
    if (self.expiresField.inputView == thePickerView) return _expireStrings[row];
    
    return nil;
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.imageSizeField.inputView == thePickerView) {
        self.imageSizeField.text = _imageSizeStrings[row];
        
        if (_imageSizeSelection != row) {
            _imageSizeSelection = row;
            _data = [self dataForScaledImage];
            if (_data) {
                NSUInteger byteCount = _data.length;
                if (byteCount > 1024*1024) self.fileSizeLabel.text = [NSString stringWithFormat:@"Dateigröße: %.1f MBytes", byteCount/(1024.*1024.)];
                else self.fileSizeLabel.text = [NSString stringWithFormat:@"Dateigröße: %.1f KBytes", byteCount/1024.];
            }
        }
        
    } else if (self.expiresField.inputView == thePickerView) {
        self.expiresField.text = _expireStrings[row];
        _expireSelection = row;
    }
}

#pragma  mark - Image Picker
- (IBAction)pickFromLibrary:(id)sender {
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
    if ([UIImagePickerController isSourceTypeAvailable:type] == NO) return;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = type;
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:type];
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = self;
    [self presentViewController:mediaUI animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    NSString *text;
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        UIImage *originalImage, *editedImage, *imageToUse;
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];
        if (editedImage) imageToUse = editedImage; 
        else imageToUse = originalImage;
        
        _filename = @"Image.png";
        _selectedImage = imageToUse;
        _data = [self dataForScaledImage];
        text = NSLocalizedString(@"Sie haben ein Bild gewählt", nil);
        
        self.imageSizeField.enabled = YES;
        self.imageSizeButton.enabled = YES;
        
    } else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        _filename = @"Video.mov";
        _selectedImage = nil;
        _data = [NSData dataWithContentsOfURL:info[UIImagePickerControllerMediaURL]];
        text = NSLocalizedString(@"Sie haben ein Video gewählt", nil);
                
        self.imageSizeField.enabled = NO;
        self.imageSizeButton.enabled = NO;
    }
    self.statusLabel.text = text;
    
    NSUInteger byteCount = _data.length;
    if (byteCount > 1024*1024) self.fileSizeLabel.text = [NSString stringWithFormat:@"Dateigröße: %.1f MBytes", byteCount/(1024.*1024.)];
    else self.fileSizeLabel.text = [NSString stringWithFormat:@"Dateigröße: %.1f KBytes", byteCount/1024.];

    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)upload:(id)sender {
    if (!_data) return;
    
    NSString *mime = @"video/mp4";
    if (_selectedImage) mime = @"image/png";
    
    [DejalBezelActivityView activityViewForView:appDelegate.window.rootViewController.view
                                      withLabel:NSLocalizedString(@"Upload…", nil)];

    
    NSString *val = [NSString stringWithFormat:@"%d", _expireSelection+1];
    NSDictionary *params = @{@"action":@"upload",
                             @"validity":val};
    NSMutableURLRequest *request = [appDelegate.httpClient multipartFormRequestWithMethod:@"POST"
                                                                                     path:@"/bintrash.php"
                                                                               parameters:params
                                                                constructingBodyWithBlock:^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:_data
                                    name:@"upfile"
                                fileName:_filename
                                mimeType:mime];
    }];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id respObj){
            if (self.completionHandler) {
                NSString *url = op.response.URL.absoluteString;
                NSRange r = [url rangeOfString:@"fileid="];
                NSString *fileID = [url substringFromIndex:r.location + r.length];
                
                NSString *urlString = [NSString stringWithFormat:@"http://trash.ctdo.de/b/%@", fileID];
                NSString *name = [NSString stringWithFormat:@"%@: %@", [_filename stringByDeletingPathExtension], fileID];
                NSDictionary *result = @{@"url":urlString, @"date":[NSDate date], @"expires":self.expiresField.text, @"name":name};
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
    [self.expiresField becomeFirstResponder];
}

- (IBAction)chooseImageSize:(id)sender {
    [self.imageSizeField becomeFirstResponder];
}

#pragma mark - Utility

- (NSData *)dataForScaledImage {
    if (!_selectedImage) return nil;
    else if (_imageSizeSelection == 0) return UIImagePNGRepresentation(_selectedImage);
    
    CGSize size = _selectedImage.size;
    CGFloat factor = 1.f/((CGFloat)_imageSizeSelection+1);
    size.height *= factor;
    size.width *= factor;
    
    UIImage *result = [_selectedImage scaleToSize:size];
    return UIImagePNGRepresentation(result);
}

@end
