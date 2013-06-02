//
//  SGViewController.h
//  CTDO Trash
//
//  Created by Simon Grätzer on 01.06.13.
//  Copyright (c) 2013 Simon Peter Grätzer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface SGUploadController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSData *uploadData;

@property (weak, nonatomic) IBOutlet UITextView *asciiTextView;
@property (weak, nonatomic) IBOutlet UITextField *validityField;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (copy, nonatomic) void (^completionHandler)(NSDictionary *, NSError *error);

- (IBAction)pickFromLibrary:(id)sender;
- (IBAction)upload:(id)sender;
- (IBAction)chooseValidity:(id)sender;

@end
