//
//  SGViewController.h
//  CTDO Trash
//
//  Created by Simon Grätzer on 01.06.13.
//  Copyright (c) 2013 Simon Peter Grätzer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "SGUploadsTableViewController.h"

@interface SGImagePickerController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate,
UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate, SGHandlerProtocol>

@property (weak, nonatomic) IBOutlet UITextField *imageSizeField;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *qualityLabel;
@property (weak, nonatomic) IBOutlet UIButton *imageSizeButton;
@property (weak, nonatomic) IBOutlet UIButton *selectFileButton;
@property (weak, nonatomic) IBOutlet UISlider *qualitySlider;

@property (copy, nonatomic) void (^completionHandler)(NSDictionary *, NSError *);

- (IBAction)pickFromLibrary:(id)sender;
- (IBAction)chooseImageSize:(id)sender;
- (IBAction)changeQuality:(id)sender;

@end
