//
//  SGLibraryUploadController.h
//  CTDO Trash
//
//  Created by Simon Grätzer on 25.07.13.
//  Copyright (c) 2013 Simon Peter Grätzer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "SGUploadsTableViewController.h"

@interface SGUploadController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, SGHandlerProtocol>

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSData *uploadData;

@property (weak, nonatomic) IBOutlet UILabel *filenameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (weak, nonatomic) IBOutlet UITextField *expiresField;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *allButtons;
@property (copy, nonatomic) void (^completionHandler)(NSDictionary *, NSError *);

- (IBAction)upload:(id)sender;
- (IBAction)chooseValidity:(id)sender;

@end
