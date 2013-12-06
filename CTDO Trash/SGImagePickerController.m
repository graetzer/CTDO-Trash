//
//  SGViewController.m
//  CTDO Trash
//
//  Created by Simon Grätzer on 01.06.13.
//  Copyright (c) 2013 Simon Peter Grätzer. All rights reserved.
//

#import "SGImagePickerController.h"
#import "SGUploadController.h"
#import "SGAppDelegate.h"
#import "AFNetworking.h"
#import "DejalActivityView.h"
#import "UIImage+Scaling.h"

@implementation SGImagePickerController {
    NSArray *_imageSizeStrings;
    NSUInteger _imageSizeSelection;
    
    UIImage *_selectedImage;
    NSURL *_url;
    NSData *_data;
    NSString *_filename;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"creampaper"]];
    
    UIImage *border = [UIImage imageNamed:@"border"];
    border = [border resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [self.imageSizeButton setBackgroundImage:border forState:UIControlStateNormal];
    [self.selectFileButton setBackgroundImage:border forState:UIControlStateNormal];
    
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
    
    self.fileSizeLabel.text = nil;
    self.qualitySlider.enabled = NO;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeInteger:_imageSizeSelection forKey:@"imageSizeSelection"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    _imageSizeSelection = [coder decodeIntegerForKey:@"imageSizeSelection"];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return textField != self.imageSizeField;
}

- (IBAction)inputAccessoryViewDidFinish:(id)sender {
    if ([self.imageSizeField isFirstResponder]) [self.imageSizeField resignFirstResponder];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"showUploadForm"]
        && _filename == nil) {
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showUploadForm"]) {
        SGUploadController *up = segue.destinationViewController;
        up.fileName = _filename;
        up.mimeType = _selectedImage != nil ? @"image/jpeg" : @"video/mp4";
        up.uploadData = _data;
        up.completionHandler = self.completionHandler;
    }
}


#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.imageSizeField.inputView == thePickerView) return _imageSizeStrings.count;
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (self.imageSizeField.inputView == thePickerView) return _imageSizeStrings[row];
    
    return nil;
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.imageSizeField.inputView == thePickerView) {
        self.imageSizeField.text = _imageSizeStrings[row];
        
        if (_imageSizeSelection != row) {
            _imageSizeSelection = row;
            _data = [self dataForScaledImage];
            [self displayFileSize];
        }
        
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
    _url = info[UIImagePickerControllerReferenceURL];
    
    NSString *text;
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        UIImage *originalImage, *editedImage, *imageToUse;
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];
        if (editedImage) imageToUse = editedImage; 
        else imageToUse = originalImage;
        
        _filename = @"Image.jpeg";
        _selectedImage = imageToUse;
        _data = [self dataForScaledImage];
        text = NSLocalizedString(@"Sie haben ein Bild gewählt", nil);
        
        self.imageSizeField.enabled = YES;
        self.imageSizeButton.enabled = YES;
        self.qualitySlider.enabled = YES;
        
    } else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        _filename = @"Video.mov";
        _selectedImage = nil;
        _data = [NSData dataWithContentsOfURL:info[UIImagePickerControllerMediaURL]];
        text = NSLocalizedString(@"Sie haben ein Video gewählt", nil);
                
        self.imageSizeField.enabled = NO;
        self.imageSizeButton.enabled = NO;
        self.qualitySlider.enabled = NO;
    }
    
    self.statusLabel.text = text;
    [self displayFileSize];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)chooseImageSize:(id)sender {
    [self.imageSizeField becomeFirstResponder];
}

- (IBAction)changeQuality:(id)sender {
    _data = [self dataForScaledImage];
    [self displayFileSize];
    self.qualityLabel.text = [NSString stringWithFormat:@"%d%%",
                              (NSUInteger)(self.qualitySlider.value*100)];
}

#pragma mark - Utility

- (NSData *)dataForScaledImage {
    CGFloat q = self.qualitySlider.value;
    if (!_selectedImage) return nil;
    else if (_imageSizeSelection == 0) return UIImageJPEGRepresentation(_selectedImage, q);
        
    CGSize size = _selectedImage.size;
    CGFloat factor = 1.f/((CGFloat)_imageSizeSelection+1);
    size.height *= factor;
    size.width *= factor;
    
    UIImage *result = [_selectedImage scaleToSize:size];
    return UIImageJPEGRepresentation(result, q);
}

- (void)displayFileSize {
    if (_data) {
        NSUInteger byteCount = _data.length;
        if (byteCount > 1024*1024) self.fileSizeLabel.text = [NSString stringWithFormat:@"Dateigröße: %.1f MBytes", byteCount/(1024.*1024.)];
        else self.fileSizeLabel.text = [NSString stringWithFormat:@"Dateigröße: %.1f KBytes", byteCount/1024.];
    } else self.fileSizeLabel.text = nil;
}
@end
