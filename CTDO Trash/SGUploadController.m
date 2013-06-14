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
    
    _expireStrings = @[@"30 Minuten", @"60 Minuten", @"12 Stunden", @"24 Stunden",
                  @"1 Woche", @"1 Monat", @"3 Monate", @"6 Monate", @"12 Monate"];
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    pickerView.showsSelectionIndicator = YES;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    self.expiresField.inputView = pickerView;
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0,0, 320, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self action:@selector(inputAccessoryViewDidFinish:)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil action:nil];
    [toolbar setItems:@[space, doneButton] animated:NO];
    self.expiresField.inputAccessoryView = toolbar;
    self.expiresField.text = _expireStrings[0];
    _expireSelection = 0;
    
    if (self.uploadData != nil) {
        self.selectFileButton.enabled = NO;
        self.statusLabel.text = NSLocalizedString(@"Sie haben bereits eine Datei gewählt", nil);
    }
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
    [self.expiresField resignFirstResponder];
}

#pragma mark - Picker

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return _expireStrings.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _expireStrings[row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.expiresField.text = _expireStrings[row];
    _expireSelection = row;
}

#pragma  mark - Image Picker
- (IBAction)pickFromLibrary:(id)sender {
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
    if ([UIImagePickerController isSourceTypeAvailable:type] == NO)
        return;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = type;
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:type];
    mediaUI.allowsEditing = NO;
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
//UIImage *imageToUse = [info objectForKey: UIImagePickerControllerOriginalImage];
        
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
    [DejalBezelActivityView activityViewForView:appDelegate.window.rootViewController.view
                                      withLabel:NSLocalizedString(@"Upload…", nil)];
    
    NSString *val = [NSString stringWithFormat:@"%d", _expireSelection+1];
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
                NSString *url = op.response.URL.absoluteString;
                NSRange r = [url rangeOfString:@"fileid="];
                NSString *fileID = [url substringFromIndex:r.location + r.length];
                
                NSString *urlString = [NSString stringWithFormat:@"http://trash.ctdo.de/b/%@", fileID];
                NSDictionary *result = @{@"url":urlString, @"date":[NSDate date], @"expires":self.expiresField.text};
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


@end
